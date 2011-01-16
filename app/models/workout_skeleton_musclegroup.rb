class WorkoutSkeletonMusclegroup < ActiveRecord::Base
  belongs_to :workout_skeleton
  belongs_to :musclegroup
end
