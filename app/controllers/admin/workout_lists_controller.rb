class Admin::WorkoutListsController < AdminAreaController
  before_filter :find_workout
  before_filter :find_workout_list, :only => [:update, :destroy]

  def create
    display_order =  @workout.workout_lists.size
    @workout_list = WorkoutList.create(
                              :workout_id => params[:workout_id],
                              :exercise_id => params[:id],
                              :display_order => display_order)
  end

  def update_order
        params[:workout_list].each_with_index  {
           |id,idx| WorkoutList.update(id, :display_order => idx)
        }
        render :template => '/admin/workout_lists/create.js.rjs'
  end
  
  def update
    if params['workout_list[]']
      params[:workout_list].each_with_index  {
         |id,idx| WorkoutList.update(id, :display_order => idx)
      }
    else
      @workout_list.update_attributes(params[:workout_list])
    end
    render :template => '/admin/workout_lists/create.js.rjs'
  end

  def destroy
    @workout_list.destroy
    render :template => '/admin/workout_lists/create.js.rjs'
  end

  private
  def find_workout
    id = params[:workout_id] || params[:id]
    @workout = Workout.find(id)
  end

  def find_workout_list
    @workout_list = WorkoutList.find(params[:id])
  end

end
