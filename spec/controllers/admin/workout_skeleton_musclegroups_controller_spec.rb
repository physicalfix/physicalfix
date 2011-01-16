require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::WorkoutSkeletonMusclegroupsController do
  fixtures :user_buckets, :musclegroups, :workout_skeletons, :workout_skeleton_musclegroups
  
  describe "POST create" do
    before do
      @ws = workout_skeletons(:workout_skeleton_one)
    end
    
    it "should find the workout_skeleton" do
      WorkoutSkeleton.should_receive(:find).with(@ws.id.to_s).and_return(@ws)
      post 'create', :workout_skeleton_id => @ws.id, :format => 'js'
    end
    
    it "should create a workout_skeleton_musclegroup" do
      mg = musclegroups(:back)
      display_order = @ws.workout_skeleton_musclegroups.length
      
      WorkoutSkeleton.stub!(:find).and_return(@ws)
      WorkoutSkeletonMusclegroup.should_receive(:create).with({
        :workout_skeleton_id => @ws.id,
        :musclegroup_id => mg.id.to_s,
        :display_order => display_order
      })
      
      post 'create', :workout_skeleton_id => @ws.id, :id => mg.id, :format => 'js'
    end
  end
  
  describe "PUT update_order" do
    before do 
      @ws = workout_skeletons(:workout_skeleton_one)
    end
    
    it "should find the workout_skeleton" do
      WorkoutSkeletonMusclegroup.stub!(:update).and_return(true)
      WorkoutSkeleton.should_receive(:find).with(@ws.id.to_s).and_return(@ws)
      put 'update_order', :id => @ws.id, :workout_list => '12,13,35,23'
    end
    
    it "should update all of the items" do
      WorkoutSkeletonMusclegroup.should_receive(:update).with(12, :display_order => 0).ordered
      WorkoutSkeletonMusclegroup.should_receive(:update).with(13, :display_order => 1).ordered
      WorkoutSkeletonMusclegroup.should_receive(:update).with(35, :display_order => 2).ordered
      WorkoutSkeletonMusclegroup.should_receive(:update).with(23, :display_order => 3).ordered
      WorkoutSkeleton.should_receive(:find).with(@ws.id.to_s).and_return(@ws)
      put 'update_order', :id => @ws.id, :workout_list => [12,13,35,23]
    end
  end
  
  describe "DELETE destroy" do
    it "should destroy the workout_skeleton_musclegroup" do
      @wsmg = mock_model(WorkoutSkeletonMusclegroup, :destroy => true, :workout_skeleton => mock_model(WorkoutSkeleton))
      @wsmg.should_receive(:destroy)
      WorkoutSkeletonMusclegroup.should_receive(:find).with("12").and_return(@wsmg)
      delete :destroy, :id => 12
    end
  end
end