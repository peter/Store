class User < ActiveRecord::Base
  acts_as_authentic
  has_many :contents, :class_name => "content", :foreign_key => "author_id"
end
