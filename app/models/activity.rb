class Activity < ActiveRecord::Base
  has_many :user_activities
  has_many :users, :through => :user_activities
  belongs_to :favorite_activity

  validates_uniqueness_of :name
end
