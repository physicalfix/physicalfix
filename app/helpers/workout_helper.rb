module WorkoutHelper
  
  def workout_class(workout)
    if workout.viewed == 0
      return 'waiting'
    elsif workout.completed == 0
      return 'incomplete'
    else
      return 'complete'
    end
  end
  
  def workout_state(workout)
    if workout.viewed == 0
      return 'Ready'
    elsif workout.completed == 0
      return 'Incomplete'
    else
      return 'Completed'
    end
  end
  
end
