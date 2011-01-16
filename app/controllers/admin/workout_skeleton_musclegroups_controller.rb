class Admin::WorkoutSkeletonMusclegroupsController < ApplicationController
  def create
    @workout_skeleton = WorkoutSkeleton.find(params[:workout_skeleton_id])
  
    display_order =  @workout_skeleton.workout_skeleton_musclegroups.size
  
    @workout_skeleton_musclegroup = WorkoutSkeletonMusclegroup.create(
                              :workout_skeleton_id => @workout_skeleton.id,
                              :musclegroup_id => params[:id],
                              :display_order => display_order)
  end

  def update_order
    @workout_skeleton = WorkoutSkeleton.find(params[:id])
    
    params[:workout_list].each_with_index  {
       |id,idx| WorkoutSkeletonMusclegroup.update(id, :display_order => idx)
    }
    
    render :template => '/admin/workout_skeleton_musclegroups/create.js.rjs'
  end
  
  def destroy
    wsmg = WorkoutSkeletonMusclegroup.find(params[:id])
    @workout_skeleton = wsmg.workout_skeleton
    wsmg.destroy
    render :template => '/admin/workout_skeleton_musclegroups/create.js.rjs'
  end
  
end
