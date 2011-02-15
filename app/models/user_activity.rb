class UserActivity < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity
  validates_presence_of :activity
  validates_presence_of :duration
  validates_numericality_of :duration
  def calories
    if calories_burned
      return calories_burned
    elsif activity
      return (user.current_weight * activity.calories_burned_per_pound_per_minute * duration).round
    else
      return 0
    end
  end
end
