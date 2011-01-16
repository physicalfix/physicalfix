class Musclegroup < ActiveRecord::Base
  has_many :exercises
  validates_presence_of :name
  validates_uniqueness_of :name
end
