class Admin::ExerciseClipsController < AdminAreaController
  
  def index
  end
  
  def show
  end
  
  def new
    @exercise = Exercise.find(params[:exercise_id])
    @exercise_clip = ExerciseClip.new(:exercise_id => @exercise.id)
  end
  
  def create
    @exercise_clip = ExerciseClip.new(params[:exercise_clip])
    if @exercise_clip.save
      redirect_to admin_exercise_path(@exercise_clip.exercise)
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end
  
end