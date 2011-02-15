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

  def days_of_week_between(day_of_week, start_date, end_date)
    ((start_date..end_date).select{ |d| d.wday == day_of_week }).count
  end

end
