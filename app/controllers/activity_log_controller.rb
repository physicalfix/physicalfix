class ActivityLogController < ApplicationController
  before_filter :require_login
  before_filter :require_medical_history
  before_filter :find_activities_by_date, :only => [:index, :show]
  before_filter :setup, :only => [:index, :show]

  def index
  end

  def show
    render :template => '/activity_log/index'
  end

  def create
    @ua = UserActivity.new(params[:user_activity])
    @ua.user_id = current_user.id

    if @ua.save
      flash[:info] = "Activity Added!"
    else
      if @ua.errors.on(:duration)
        flash[:error] = "Please enter a valid duration"
      elsif @ua.errors.on(:activity)
        flash[:error] = "Please select an activity"
      end
    end
    redirect_to activity_log_index_path
  end

  def destroy
    UserActivity.find(params[:id]).destroy
    if Date.parse(params[:date]) != Time.zone.now.to_date
      redirect_to activity_log_path(params[:date])
    else
      redirect_to activity_log_index_path
    end
  end

  def quick_add
    favorite = FavoriteActivity.find(params[:id])

    @activity = favorite.activity

    render :layout => false
  end

  private
  def find_activities_by_date
    if params[:id]
      @date = Time.parse(params[:id])
    else
      @date = Time.now
    end

    @activities = current_user.user_activities.all(:order => 'activity_date ASC', :conditions => ['activity_date BETWEEN ? and ?', @date.beginning_of_day.utc, @date.end_of_day.utc])

    @date = @date.to_date
    calc_activity_info
  end
  
  def calc_activity_info
    @activity_duration_total = @activities.inject(0) do |s,activity|
      
      if activity.duration
        s += activity.duration
      else
        s += 0
      end
    end

    @total_calories = @activities.inject(0) do |s, activity|
      s += activity.calories
    end

    @activity_calorie_total = @activities.inject(0) do |s, activity|
      if activity.name != 'Daily Energy Expenditure'
        s += activity.calories
      else
        s += 0
      end
    end
  end
  
  def setup
    @activities_list = Activity.all(:order => 'name ASC')
    @user_activity = UserActivity.new
    @user = current_user
    @favorites = current_user.favorite_activities
  end
end
