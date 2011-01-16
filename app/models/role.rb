class Role < ActiveRecord::Base
  validates_uniqueness_of :name
  belongs_to :user
  has_many :user_roles
  has_many :users, :through => :user_roles
end