class Admin::ActivitiesController < AdminAreaController

  before_filter :find_activity, :only => [:show, :edit, :update, :destroy]

  def index
    @activities = Activity.all
  end

  def show
    
  end
  
  def new
    @activity = Activity.new
  end
  
  def create
    @activity = Activity.new(params[:activity])
    if @activity.save
      flash[:info] = 'Activity added'
      redirect_to admin_activities_path
    else
      render :action => 'new'
    end
  end

  def edit
    render :template => 'admin/activities/new'
  end

  def update
    if @activity.update_attributes(params[:activity])
      flash[:info] = 'Changes Saved'
      redirect_to admin_activity_path(@activity)
    else
       render :action => 'new'
    end

  end

  def destroy
    @activity.destroy
    flash[:info] = 'Exercise Deleted'
    redirect_to admin_activities_path
  end

  private
  def find_activity
    @activity = Activity.find(params[:id])
  end

end
