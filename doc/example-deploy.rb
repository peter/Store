require File.dirname(__FILE__) + '/../config/environment'

set :application, "events"
set :deploy_to, "/var/www/apps/#{application}"
set :rails_env, (ENV['env'] || "production")
default_domain = case rails_env
                 when "production"
                   "simplesignup.se"
                 when "staging"
                   "209.20.76.43"
                 else
                   raise "Don't know how to deploy to environment #{rails_env}"
                 end
set :domain, (ENV['DOMAIN'] || default_domain)
set :user, "deploy"
set :repository, "git@github.com:peter/simplesignup.git"
set :scm, :git
set :branch, (ENV['branch'] || "master")
# Use a copy cache to speed up deployments, mostly relevant if subversion is used
set :copy_strategy, :export
set :deploy_via, :remote_cache
set :monit_group, 'mongrel'
set :ssh_options, {:port => 8547}
set :apache_proxy_port, 8020
set :use_sudo, false

role :web, domain
role :app, domain
role :db,  domain, :primary => true
role :scm, domain

# ===========================================================================
# Development
# ===========================================================================  

desc "Copy database and uploaded files from production to development"
task :update_dev do
  db.update_dev
  files.update_dev
end

# ===========================================================================
# Deployment
# ===========================================================================  

namespace :deploy do
  desc "Deploy a minor change and don't run the tests"
  task :minor do
    ENV['SKIP_TESTS'] = "1"
    ENV['SKIP_EVENT_HOME'] = "1"
    deploy.default
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Run the full tests on the deployed app." 
  task :run_tests_and_specs do
    run "cd #{release_path} && rake && cat /dev/null > log/test.log" 
  end

  desc "Copy in server specific configuration files and setup symlinks to shared files"
  task :setup_shared do
    run <<-END
      cp #{shared_path}/server.rb #{release_path}/config &&
      cp #{shared_path}/versioned/database.yml.example #{release_path}/config &&
      cp #{shared_path}/versioned/initializers/* #{release_path}/config/initializers &&
      ln -s #{shared_path}/files #{release_path}/public &&
      ln -s /backup/events_production.hourly.dmp.gz #{release_path}/public &&
      ln -s /backup/events_production_files.tar.gz #{release_path}/public
    END
  end

  desc "Checkout external Git plugins under vendor/plugins"
  task :checkout_plugins do
    run <<-END
      cd #{release_path}/vendor/plugins && git clone git://github.com/peter/git_plugins.git &&
      cd #{release_path} && rake git:plugins:checkout
    END
  end

  desc "Use the server_config plugin to write config files"
  task :write_server_config do
    run <<-END
      cd #{release_path} && rake server_config:write    
    END
  end

  task :after_update_code, :roles => :app do
    setup_shared
    checkout_plugins
    write_server_config
    db.backup if rails_env == "production"
  end  

  task :update_event_home, :roles => :app do
    run <<-END
      cd ~/events && git pull
    END
  end

  task :before_symlink, :roles => :app do
    run_tests_and_specs unless ENV['SKIP_TESTS']
    update_event_home unless ENV['SKIP_EVENT_HOME']
  end

  desc "Clear out old code trees. Only keep 5 latest releases around"
  task :after_deploy do
    cleanup
  end
end

# ===========================================================================
# Database
# ===========================================================================  

namespace :db do
  desc "Backup production database to local file."
  task :backup, :roles => :app do
    prod = ::ActiveRecord::Base.configurations['production']
    backup_type = (ENV['FREQUENCY'] || "pre_deploy") 
    run <<-CMD
      mysqldump #{mysql_options(prod)} --set-charset #{prod['database']} > #{backup_db_path} && gzip -c #{backup_db_path} > #{backup_db_path}.gz
    CMD
  end

  desc "Copy production database to development database"
  task :update_dev, :roles => :db do
    require File.dirname(__FILE__) + '/../config/environment'
    prod = ::ActiveRecord::Base.configurations['production']
    prod_db = prod['database']
    dev_db = ::ActiveRecord::Base.configurations['development']['database']
    run <<-CMD
      mysqldump #{mysql_options(prod)} --set-charset #{prod_db} > /tmp/#{prod_db}.dmp
    CMD
    system("scp #{user}@#{domain}:/tmp/#{prod_db}.dmp ~/tmp")
    system("rake db:drop db:create")
    system("mysql -u root #{dev_db} < ~/tmp/#{prod_db}.dmp")
  end
end

# ===========================================================================
# Uploaded files
# ===========================================================================  

namespace :files do
  desc "Backup uploaded files to a local tar file"
  task :backup, :roles => :app do
    run <<-CMD
      tar czvf #{backup_dir}/events_production_files.tar.gz #{shared_path}/files/production
    CMD
  end
  
  desc "Copy production files to local development environment"
  task :update_dev, :roles => :db do
    filename = "events_production_files.tar.gz"
    run <<-CMD
      cd #{shared_path}/files && tar czf /tmp/#{filename} production
    CMD
    system <<-CMD
      scp #{user}@#{domain}:/tmp/#{filename} ~/tmp &&
      cd public/files && tar xzf ~/tmp/#{filename} &&
      rm -rf development && mv production development
    CMD
  end
end

# ===========================================================================
# Monit
# ===========================================================================  

namespace :monit do  
  desc "Restart Monit"
  task :restart do
    sudo "/etc/init.d/monit restart"
  end

  desc "Show status"
  task :status do
    sudo "monit status" do |ch, st, data| 
      print data 
    end
  end
  
  desc "Overwrite monit configs and restart"
  task :update_config do
    checkout_path = "/home/deploy/events"
    sudo_commands = [
      "mv /etc/monit/monitrc /etc/monit/monitrc.bak",
      "cp #{checkout_path}/config/monit/monitrc /etc/monit",
      "chmod 600 /etc/monit/monitrc",
      "rm -rf /etc/monit.d.bak",
      "mv /etc/monit.d /etc/monit.d.bak",
      "cp -r #{checkout_path}/config/monit/monit.d /etc"
    ]
    sudo_commands.each { |command| sudo command }
    restart
  end  
end

# ===========================================================================
# Nginx
# ===========================================================================  

namespace :nginx do
  desc "Restart Nginx web server"
  task :restart do
    sudo "/etc/init.d/nginx restart"
  end

  desc "Overwrite nginx.conf and restart"
  task :update_config do
    run <<-END
      cp /opt/nginx/conf/nginx.conf /opt/nginx/conf/nginx.conf.bak &&
      cp #{current_path}/config/nginx.conf /opt/nginx/conf/nginx.conf
    END
    restart
  end
end

# ===========================================================================
# Monitoring
# ===========================================================================  

desc "Show backup files" 
task :show_backups, :roles => :app do 
  run "ls -lSdh /backup/*" do |ch, st, data| 
    print data
  end 
end 

# ===========================================================================
# Log
# ===========================================================================  

namespace :log do
  desc "Show tail of log" 
  task :tail, :roles => :app do 
    run "tail -n 200 #{current_path}/log/production.log" do |ch, st, data| 
      print data
    end 
  end

  desc "Show log files" 
  task :ls, :roles => :app do 
    run "ls -ldth #{current_path}/log/production.log*" do |ch, st, data| 
      print data
    end 
  end

  desc "Analyze Rails Log remotely - response time statistics" 
  task :analyze, :roles => :app do 
    run "pl_analyze #{shared_path}/log/#{rails_env}.log" do |ch, st, data| 
      print data 
    end 
  end 
end

# ===========================================================================
# Server Config
# ===========================================================================  

namespace :server_config do
  desc "Deploy config/server.rb file"
  task :deploy do
    system(
      <<-END
        scp config/server.rb #{user}@simplesignup.se:#{shared_path}
        scp config/server.rb #{user}@simplestaging:#{shared_path}
      END
    )
  end
end

# ===========================================================================
# Helper methods
# ===========================================================================  

def backup_dir
  "/backup"
end

def backup_db_path
  prod = ::ActiveRecord::Base.configurations['production']
  backup_type = (ENV['FREQUENCY'] || "pre_deploy") 
  "#{backup_dir}/#{prod['database']}.#{backup_type}.dmp"
end

def mysql_options(conf)
  password_option = conf['password'].blank? ? '' : "-p#{conf['password']}"
  "-u #{conf['username']} #{password_option}"
end
