class Exercise < ActiveRecord::Base
  has_many :WorkoutLists
  has_many :exercise_clips
  belongs_to :musclegroup
  validates_presence_of :name, :musclegroup_id
end


