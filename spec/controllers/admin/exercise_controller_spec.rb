require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ExercisesController do
  fixtures :users, :roles, :user_roles, :exercises

  before(:each) do
    @user = users(:admin_user)
    login(@user)
  end

  it_should_behave_like "controllers"

  describe "GET index" do
    it "should require admin" do
      login(users(:valid_user))
      get :index
      response.should redirect_to(account_path)
    end

    it "should filter by muscle groups if passed" do
      Exercise.should_receive(:find_all_by_musclegroup_id).with('1')
      get :index, :muscle_group_id => 1
    end
    
    it "should get all exercises" do
      Exercise.should_receive(:find).with(:all)
      get :index
    end
  end
  
  describe "GET show" do
    it "should do something" do
      @e = mock_model(Exercise, :name => 'test')
      Exercise.stub!(:find).and_return(@e)
      get :show, :id => @e.id
    end
  end
  
  describe "GET new" do
    it "should have a new exercise" do
      Exercise.should_receive(:new)
      get :new
    end
  end

  describe "POST create" do
    it "should redirect to show on create" do
      @exercise = mock_model(Exercise, :valid? => true, :save => true)
      Exercise.should_receive(:new).and_return(@exercise)
      post :create
      response.should redirect_to(admin_exercise_path(@exercise))
    end

    it "should render new on invalid exercise" do
      @exercise = mock_model(Exercise, :valid? => false, :save => false)
      Exercise.should_receive(:new).and_return(@exercise)
      post :create
      response.should render_template(:new)
    end

  end

  describe "GET edit" do
   it "should do something" do
     @e = mock_model(Exercise, :name => 'test')
     Exercise.stub!(:find).and_return(@e)
     get :edit, :id => @e.id
     response.should render_template(:new) 
   end
  end
  
  describe "PUT update" do
    it "should redirect to exercise on save" do
      @exercise = mock_model(Exercise, :name => 'pushups', :update_attributes => true)
      Exercise.stub!(:find).and_return(@exercise)
      put :update
      response.should redirect_to(admin_exercise_path(@exercise))
    end

    it "should render new templae on error" do
      @exercise = mock_model(Exercise, :name => 'pushups', :update_attributes => false)
      Exercise.stub!(:find).and_return(@exercise)
      put :update
      response.should render_template(:new)
    end
    
  end

  describe "DETELE destroy" do
    it "should delte exercise" do
      @exercise = mock_model(Exercise, :name => 'pushups', :update_attributes => false)
      @exercise.should_receive(:destroy)
      Exercise.stub!(:find).and_return(@exercise)
      delete :destroy
    end
  end

end