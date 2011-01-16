require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::WorkoutSkeletonsController do
  fixtures :users, :user_roles
  
  it_should_behave_like "controllers"
  
  before do
    @admin_user = users(:admin_user)
    login(@admin_user)
  end
  
  describe "GET index" do
    it "should get all workout skeletons" do
      WorkoutSkeleton.should_receive(:all)
      get :index
    end
  end
  
  describe "GET show" do
    it "should get the workout skeleton" do
      @ws = mock_model(WorkoutSkeleton)
      WorkoutSkeleton.should_receive(:find).with(@ws.id.to_s)
      get :show, :id => @ws.id
    end
    it "should get all the musclgroups" do
      @ws = mock_model(WorkoutSkeleton)
      WorkoutSkeleton.stub!(:find).and_return(@ws)
      Musclegroup.should_receive(:all)
      get :show, :id => @ws.id
    end
  end
  
  describe "GET new" do 
    it "should assign a new workout_skeleton" do
      @ws = mock_model(WorkoutSkeleton)
      WorkoutSkeleton.should_receive(:new).and_return(@ws)
      get :new
      assigns[:workout_skeleton].should == @ws
    end
  end
  
  describe "POST create" do
    it "should create new workout skeleton" do
      @ws = mock_model(WorkoutSkeleton, :save => true)
      WorkoutSkeleton.should_receive(:new).with({"name" => 'test', "description" => 'test'}).and_return(@ws)
      post :create, {:workout_skeleton => {:name => 'test', :description => 'test'}}
    end
    
    it "should redirect on a successful save" do
      @ws = mock_model(WorkoutSkeleton, :save => true)
      WorkoutSkeleton.stub!(:new).and_return(@ws)
      post :create, {:workout_skeleton => {:name => 'test', :description => 'test'}}
      response.should redirect_to(admin_workout_skeletons_path)
    end
    
    it "should render new on a failed save" do 
      @ws = mock_model(WorkoutSkeleton, :save => false)
      WorkoutSkeleton.stub!(:new).and_return(@ws)
      post :create, {:workout_skeleton => {:name => 'test', :description => 'test'}}
      response.should render_template(:new)
    end
    
  end
  
  describe "GET edit" do
    it "should find the workout" do
      @ws = mock_model(WorkoutSkeleton)
      WorkoutSkeleton.should_receive(:find).with(@ws.id.to_s)
      get :edit, :id => @ws.id
    end
  end
  
  describe "PUT update" do
    it "should find the workout" do
      @ws = mock_model(WorkoutSkeleton, :update_attributes => true)
      WorkoutSkeleton.should_receive(:find).with(@ws.id.to_s).and_return(@ws)
      put :update, :id => @ws.id, :workout_skeleton => {:name => 'test', :description => 'test'}
    end
    
    it "should update the workout" do
      @ws = mock_model(WorkoutSkeleton)
      @ws.should_receive(:update_attributes).with({"name" => 'test', "description" => 'test'})
      WorkoutSkeleton.stub!(:find).and_return(@ws)
      put :update, :id => @ws.id, :workout_skeleton => {:name => 'test', :description => 'test'}
    end
    
    it "should redirect on a successful update" do
      @ws = mock_model(WorkoutSkeleton, :update_attributes => true)
      WorkoutSkeleton.stub!(:find).and_return(@ws)
      put :update, :id => @ws.id, :workout_skeleton => {:name => 'test', :description => 'test'}
      response.should redirect_to(admin_workout_skeleton_path(@ws))
    end
    
    it "should render edit on a failed update" do
      @ws = mock_model(WorkoutSkeleton, :update_attributes => false)
      WorkoutSkeleton.stub!(:find).and_return(@ws)
      put :update, :id => @ws.id, :workout_skeleton => {:name => 'test', :description => 'test'}
      response.should render_template(:edit)
    end
  end
  
  describe "DELETE destroy" do
    it "should find the workout skeleton" do
      @ws = mock_model(WorkoutSkeleton, :destroy => true)
      WorkoutSkeleton.should_receive(:find).with(@ws.id.to_s).and_return(@ws)
      delete :destroy, :id => @ws.id
    end
    
    it "should destroy the workout" do
      @ws = mock_model(WorkoutSkeleton)
      @ws.should_receive(:destroy)
      WorkoutSkeleton.stub!(:find).and_return(@ws)
      delete :destroy, :id => @ws.id
    end
    
    it "should redirect to index" do
      @ws = mock_model(WorkoutSkeleton, :destroy => true)
      WorkoutSkeleton.stub!(:find).and_return(@ws)
      delete :destroy, :id => @ws.id
      response.should redirect_to(admin_workout_skeletons_path)
    end
  end
  
end