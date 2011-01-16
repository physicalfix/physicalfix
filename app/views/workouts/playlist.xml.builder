xml.instruct!
xml.workout do
  xml.totaltime  @workout.total_length
  xml.exercises do
    @workout.workout_exercises.each do |wl|
      ec = wl.exercise_clip
      xml.exercise do
        xml.name wl.exercise.name
        xml.musclegroup wl.exercise.musclegroup.name.downcase
        xml.delay wl.delay_time
        xml.weight wl.weight
        xml.reps ec.reps
        xml.time wl.length - wl.delay_time
        xml.src ec.clip.url
      end
    end
  end
end