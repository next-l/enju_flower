class UserHasRole < ActiveRecord::Base
  attr_accessible :user_id, :role_id
  belongs_to :user
  belongs_to :role
end
