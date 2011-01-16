class Admin::WorkoutSkeletonsController < AdminAreaController
  
  def index
    @workout_skeletons = WorkoutSkeleton.all(:include => :user_bucket)
  end
  
  def show
    @musclegroups = Musclegroup.all
    @workout_skeleton = WorkoutSkeleton.find(params[:id])
  end
  
  def new
    @workout_skeleton = WorkoutSkeleton.new
  end
  
  def create
    @workout_skeleton = WorkoutSkeleton.new(params[:workout_skeleton])
    if @workout_skeleton.save
      redirect_to admin_workout_skeletons_path
    else
      render :action => :new
    end
  end
  
  def edit
    @workout_skeleton = WorkoutSkeleton.find(params[:id])
  end
  
  def update
    @workout_skeleton = WorkoutSkeleton.find(params[:id])
    if @workout_skeleton.update_attributes(params[:workout_skeleton])
      redirect_to admin_workout_skeleton_path(@workout_skeleton)
    else
      render :action => :edit
    end
  end
  
  def destroy
    ws = WorkoutSkeleton.find(params[:id])
    ws.destroy
    redirect_to admin_workout_skeletons_path
  end
  
end
