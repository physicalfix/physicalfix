module ActivityLogHelper
  def activity_class(activity)
    return if activity.name.nil?
    if activity.name == 'Daily Energy Expenditure'
      return 'tdee'
    elsif activity.name.starts_with?('Workout')
      return 'workout'
    end
  end
end
