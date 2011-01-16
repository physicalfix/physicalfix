require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ActivitiesController do
  fixtures :users, :roles, :user_roles, :activities, :medical_histories
  
  before(:each) do
    session[:uid] = session[:logged_in_as] = nil
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

    it "should get all activities" do
      Activity.should_receive(:all)
      get :index
    end
  end

  describe "GET new" do
    it "should have a new activity" do
      Activity.should_receive(:new)
      get :new
    end
  end

  describe "POST create" do
    it "should redirect to show on create" do
      @activity = mock_model(Activity, :valid? => true, :save => true)
      Activity.should_receive(:new).and_return(@activity)
      post :create
      response.should redirect_to(admin_activities_path)
    end

    it "should render new on invalid activity" do
      @activity = mock_model(Activity, :valid? => false, :save => false)
      Activity.should_receive(:new).and_return(@activity)
      post :create
      response.should render_template(:new)
    end

  end

  describe "GET edit" do
    it "should do something" do
      @activity = mock_model(Activity, :name => 'Aerobics', :update_attributes => true)
      Activity.stub!(:find).and_return(@activity)
      get :edit, :id => @activity.id
      response.should render_template(:new)
    end
  end

  describe "PUT update" do
    it "should redirect to activity on save" do
      @activity = mock_model(Activity, :name => 'Aerobics', :update_attributes => true)
      Activity.stub!(:find).and_return(@activity)
      put :update
      response.should redirect_to(admin_activity_path(@activity))
    end

    it "should render new templae on error" do
      @activity = mock_model(Activity, :name => 'Aerobics', :update_attributes => false)
      Activity.stub!(:find).and_return(@activity)
      put :update
      response.should render_template(:new)
    end

  end

  describe "DETELE destroy" do
    it "should delete activity" do
      @activity = mock_model(Activity, :name => 'Aerobics', :update_attributes => false)
      @activity.should_receive(:destroy)
      Activity.stub!(:find).and_return(@activity)
      delete :destroy, :id => @activity.id
    end
  end

end