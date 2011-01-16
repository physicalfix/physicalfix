class Admin::ExercisesController < AdminAreaController  

  before_filter :find_exercise, :only => [:show, :edit, :update, :destroy]

  def index
    @title = "Admin :: Exercises"
    @user_bucket = UserBucket.find(params[:user_bucket_id]) if params[:user_bucket_id]
    if params[:muscle_group_id]
      @exercises = Exercise.find_all_by_musclegroup_id(params[:muscle_group_id])
    else
      @exercises = Exercise.find(:all)
    end
  end
  
  def show
    @title = "Admin :: Exercises :: #{@exercise.name}"
  end

  def new
    @title = "Admin :: Exercises :: New"
    @exercise = Exercise.new
  end
  
  def create
    @exercise = Exercise.new(params[:exercise])
    if @exercise.save
      flash[:info] = 'Exercise added'
      redirect_to admin_exercise_path(@exercise)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @title = "Admin :: Exercises :: Edit :: #{@exercise.name}"
    render :template => 'admin/exercises/new'
  end

  def update
     if @exercise.update_attributes(params[:exercise])
      flash[:info] = 'Changes Saved'
      redirect_to admin_exercise_path(@exercise)
    else
       render :action => 'new'
    end
  end
  
  def destroy
    @exercise.destroy
    flash[:info] = 'Exercise Deleted'
    redirect_to admin_exercises_path
  end

  private
  def find_exercise
    @exercise = Exercise.find(params[:id])
  end
  
end
