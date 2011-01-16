require File.dirname(__FILE__) + '/../spec_helper'

describe FavoriteActivitiesController do
  fixtures :users, :activities
  
  before(:each) do
    @user = users(:valid_user)
    login(@user)
  end

  it_should_behave_like "controllers"

    describe "GET index" do
    before do
      FavoriteActivity.stub!(:find_all_by_user_id).and_return([])
    end

    it "should find all favorite activities" do
      FavoriteActivity.should_receive(:find_all_by_user_id).with(@user.id, :include => :activity).and_return([])
      get :index
    end

    it "shoudl assign @favorites" do
      get :index
      assigns[:favorites].should == []
    end

  end

  describe "POST create" do
    before(:each) do
      @activity = activities(:aerobics)
      Activity.stub!(:find).with("#{@activity.id}").and_return(@activity)
      @params = {:id => @activity.id}
    end
    
    it "should return if the activity is already a favorite" do
      @fa = mock_model(FavoriteActivity, :activity_id => @activity.id, :save => true)
      FavoriteActivity.stub!(:find_by_user_id_and_activity_id).and_return(@fa)
      FavoriteActivity.should_not_receive(:create)
      post :create, @params
    end
    
    it "should create a new FavoriteActivity if it isn't already a favorite" do
      FavoriteActivity.should_receive(:create).with({:activity_id => "#{@activity.id}", :user_id => @user.id})
      post :create, @params        
    end
    
    it "should assign activity" do
      @fa = mock_model(FavoriteActivity, :activity => @activity)
      FavoriteActivity.stub!(:create).and_return(@fa)
      post :create, @params
      assigns[:activity].should == @activity
    end

    it "should update update the page" do
      @fa = mock_model(FavoriteActivity, :activity => @activity)
      FavoriteActivity.stub!(:create).and_return(@fa)
      post :create, @params
      response.should have_rjs
    end
  end

  describe "DELETE destroy" do
    fixtures :activities
    before do
      @fa = mock_model(FavoriteActivity, :activity => activities(:aerobics), :map => [], :destroy => true)
      FavoriteActivity.stub!(:find).and_return(@fa)
    end

    it "should destroy the favorite activity" do
      @fa.should_receive(:destroy)
      delete :destroy, {:id => '12'}
    end

    it "should redirect to index if manage=true is passed in" do
      delete :destroy, {:id => '12', :manage => true}
      response.should redirect_to favorite_activities_path
    end

  end

end