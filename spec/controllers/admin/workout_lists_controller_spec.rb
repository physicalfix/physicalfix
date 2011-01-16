require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::WorkoutListsController do

  before do
    @admin_user = mock_model(User, :has_password? => true, :has_role? => true, :time_zone => 'UTC')
    session[:uid] = @admin_user.id
    User.stub!(:find).with(@admin_user.id).and_return(@admin_user)
    Workout.stub!(:find).and_return(mock_model(Workout, :workout_exercises => [], :workout_lists => []))
  end

  describe "POST create" do
    it "should create new workout list" do
      WorkoutList.should_receive(:create).with({:exercise_id => "2", :workout_id => "5", :display_order => 0})
      post :create, {:id => 2, :workout_id => 5, :format => 'js'}
    end
  end

  describe "PUT update" do
    before do
      @wl = mock_model(WorkoutList)
      WorkoutList.stub!(:find).and_return(@wl)
    end

    it "should update list order if passed in" do
      WorkoutList.should_receive(:update).exactly(4).times
      put :update, {'workout_list[]' => 'something', 'workout_list' => [2,3,4,5], :id => @wl.id}
    end

    it "should udpate exercise attributes if not ordering" do
      @wl.should_receive(:update_attributes)
      put :update, {:id => @wl.id, :workout_list => {:weight => 150}}
    end
  end

  describe "DELETE destory" do
    before do
      @wl = mock_model(WorkoutList)
      WorkoutList.stub!(:find).and_return(@wl)
    end
    it "should destroy the workout list" do
      @wl.should_receive(:destroy)
      delete :destroy, {:id => @wl}
    end
  end

  describe "POST update_order" do
    before do 
      @wl = mock_model(WorkoutList)
      WorkoutList.stub!(:find).and_return(@wl)
      @workout = mock_model(Workout)
      Workout.stub!(:find).and_return(@workout)
    end
        
    it "should update all of the items" do
      WorkoutList.should_receive(:update).with(12, :display_order => 0).ordered
      WorkoutList.should_receive(:update).with(13, :display_order => 1).ordered
      WorkoutList.should_receive(:update).with(35, :display_order => 2).ordered
      WorkoutList.should_receive(:update).with(23, :display_order => 3).ordered
      post 'update_order', :id => @wl.id, :workout_list => [12,13,35,23]
    end
  end

end