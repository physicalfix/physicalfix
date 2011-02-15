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

  def trial_week_number(day_of_week, start_date, end_date)
    days = days_of_week_between(day_of_week, start_date, end_date)
    case days
    when 1
      if start_date.wday == day_of_week
        return 1
      else
        return 2
      end
    else
      days += 1
    end
    return days
  end

  # Make sure dates passed are actually dates.
  def days_of_week_between(day_of_week, start_date, end_date)
    ((start_date..end_date).select{ |d| d.wday == day_of_week }).count
  end

end
