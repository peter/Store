set :application, "store"
set :repository,  "git://github.com/peter/Store.git "
set :deploy_to, "/var/www/apps/#{application}"
set :user, "deploy"

set :scm, :git

set :domain, "marklunds.com"
role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
