class UserBucketExercise < ActiveRecord::Base
  belongs_to :user_bucket
  belongs_to :exercise
end
