require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::UserBucketsController do
  fixtures :users, :roles, :user_roles, :user_buckets

  it_should_behave_like "controllers"

  before do
    @admin_user = users(:admin_user)
    login(@admin_user)
  end
  
  describe "GET index" do
    it "should get all user buckets" do
      UserBucket.should_receive(:all)
      get :index
    end
  end
  
  describe "GET show" do
    it "should get user bucket" do
      ub = user_buckets(:big_bucket)
      UserBucket.should_receive(:find).with(ub.id.to_s)
      get :show, :id => ub.id
    end
    it "should get muscle groups" do
      ub = user_buckets(:big_bucket)
      Musclegroup.should_receive(:find).with(:all, :include => :exercises)
      get :show, :id => ub.id
    end
  end
  
  describe "GET new" do
    it "should assign a new user bucket" do
      UserBucket.should_receive(:new)
      get :new
    end
  end
  
  describe "POST create" do
    it "should create a new user bucket" do
      UserBucket.should_receive(:new).with({"name" => 'test', "description" => 'test'}).and_return(mock_model(UserBucket, :save => true))
      post :create, :user_bucket => {:name => 'test', :description => 'test'}
    end
    
    it "should redirect to index if save is good" do
      UserBucket.stub!(:new).and_return(mock_model(UserBucket, :save => true))
      post :create, :user_bucket => {:name => 'test', :description => 'test'}
      response.should redirect_to(admin_user_buckets_path)
    end
    
    it "should render new if save returns false" do
      UserBucket.stub!(:new).and_return(mock_model(UserBucket, :save => false))
      post :create, :user_bucket => {:name => 'test', :description => 'test'}
      response.should render_template(:new)
    end
    
    
  end
  
  describe "GET edit" do
    it "should find the user bucket" do
      ub = user_buckets(:big_bucket)
      UserBucket.should_receive(:find).with(ub.id.to_s)
      get :edit, :id => ub.id
    end
  end
  
  describe "PUT update" do
    before do
      @ub = mock_model(UserBucket)
    end
    
    it "should find the user bucket" do
      @ub.stub!(:update_attributes => true)
      UserBucket.should_receive(:find).with(@ub.id.to_s).and_return(@ub)
      put :update, :id => @ub.id
    end
    
    it "should redirect to the show page if update is successful" do
      @ub.stub!(:update_attributes => true)
      UserBucket.should_receive(:find).with(@ub.id.to_s).and_return(@ub)
      put :update, :id => @ub.id
      response.should redirect_to(admin_user_buckets_path)
    end
    
    it "should render edit if the update fails" do
      @ub.stub!(:update_attributes => false)
      UserBucket.should_receive(:find).with(@ub.id.to_s).and_return(@ub)
      put :update, :id => @ub.id
      response.should render_template(:edit)
    end
  end
  
  describe "DELETE destroy" do
    before do
      @ub = mock_model(UserBucket, :destroy => true)
    end
    
    it "should find the bucket" do
      UserBucket.should_receive(:find).with(@ub.id.to_s).and_return(@ub)
      delete :destroy, :id => @ub.id
    end
    
    it "should destroy the bucket" do
      UserBucket.stub!(:find).with(@ub.id.to_s).and_return(@ub)
      @ub.should_receive(:destroy)
      delete :destroy, :id => @ub.id
    end
    
    it "should redirect to index" do
      UserBucket.should_receive(:find).with(@ub.id.to_s).and_return(@ub)
      delete :destroy, :id => @ub.id
      response.should redirect_to(admin_user_buckets_path)
    end
    
  end

  
end