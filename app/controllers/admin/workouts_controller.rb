class Admin::WorkoutsController < AdminAreaController
  
  skip_before_filter :verify_authenticity_token, :only => [:comment]
  
  before_filter :find_workout, :except => [:index, :new, :create]

  def index
    @title = "Admin :: Workouts"

    find_params = {
            :order => 'id DESC',
            :page => params[:page],
            :include => [:user, :workout_sessions]
    }

    if params[:user_id]
      find_params.merge!({:conditions => ['user_id = ? and workout_skeleton_id IS NULL', params[:user_id]]})
    elsif params[:approved]
      find_params.merge!({:conditions => ['approved = ? and workout_skeleton_id IS NULL', true]})
    elsif params[:unapproved]
      find_params.merge!({:conditions => ['approved = ? and workout_skeleton_id IS NULL', false]})
    elsif params[:completed]
      find_params.merge!({:conditions => 'comment IS NOT NULL and workout_skeleton_id IS NULL'})
    else
      find_params.merge!({:conditions => 'workout_skeleton_id IS NULL'})
    end
    
    @workouts = Workout.paginate(find_params)
  end

  def new
    @title = "Admin :: Exercises :: New"
    @workout = Workout.new
    if params[:user_id]
      @user = User.find(params[:user_id])
    end
  end
  
  def create
    params[:workout][:week_of] = Date.commercial(params[:date][:year].to_i, params[:date][:week].to_i, 1)
    @workout = Workout.new(params[:workout])
    if @workout.save
      redirect_to edit_admin_workout_path(@workout)
    else
      render :action => :new, :user_id => params[:user_id]
    end
  end
  
  def destroy
    @workout.destroy
    flash[:info] = 'Workout Deleted'
    redirect_to admin_workouts_path
  end

  def edit
    @title = "Admin :: Exercises :: Edit"
    @musclegroups = Musclegroup.find(:all, :include => :exercises)
    @user = @workout.user
    @equipment = @user.equipment

  end

  def update
    params[:workout] = Hash.new if !params[:workout]
    
    if params[:date]
      params[:workout][:week_of] = Date.commercial(params[:date][:year].to_i, params[:date][:week].to_i, 1)
    end

    if params[:approve]
      params[:workout][:approved] = true;
    end

    @workout.update_attributes(params[:workout])

    respond_to do |format|
      format.html {
        flash[:info] = 'Workout Approved!'
        redirect_to admin_workouts_path
      }
      format.js
    end

  end

  def comment
    @comment = @workout.comment.to_s
    render :layout => false
  end

  def show
    redirect_to edit_admin_workout_path(@workout)
  end
  
  def record_note
    @workout_id = params[:id]
    render :layout => false
  end
  
  private
  def find_workout
    @workout = Workout.find(params[:id])
  end

end
