class WorkoutList < ActiveRecord::Base
  set_table_name "exercises_workouts"
  belongs_to :workout
  belongs_to :exercise
  belongs_to :exercise_clip
  
  def length
    return 0 unless exercise_clip
    return exercise_clip.seconds.to_i + delay_time.to_i
  end

  def ready?
    ec = !exercise_clip_id.nil?
    if exercise.name.downcase.include?('dumbbell')
      w = !weight.nil? && !weight.empty?
    else
      w = true
    end
    return ec && w
  end
end
