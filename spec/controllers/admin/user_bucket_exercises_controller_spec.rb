require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::UserBucketExercisesController do
  fixtures :users, :roles, :user_roles
  
  it_should_behave_like "controllers"

  before do
    @admin_user = users(:admin_user)
    login(@admin_user)
  end
  
  describe 'POST create' do
    fixtures :exercises, :user_buckets
    
    before do
      @exercise = exercises(:exercises_016)
      @user_bucket = user_buckets(:dumbell_bucket)
    end
    
    it "should find user bucket" do
      UserBucket.should_receive(:find).with(@user_bucket.id.to_s).and_return(@user_bucket)
      post :create, {:user_bucket_id => @user_bucket.id, :exercise_id => @exercise.id, :format => 'js'}
    end
    
    it "should find exercise" do
      Exercise.should_receive(:find).with(@exercise.id.to_s).and_return(@exercise)
      post :create, {:user_bucket_id => @user_bucket.id, :exercise_id => @exercise.id, :format => 'js'}
    end
    
    it "should add exercise to the user bucket" do
      post :create, {:user_bucket_id => @user_bucket.id, :exercise_id => @exercise.id, :format => 'js'}
      @user_bucket.reload
      @user_bucket.exercises.should include(@exercise)
    end
  end
  
  describe 'DELETE destroy' do
    fixtures :exercises, :user_buckets
    
    before do
      @exercise = exercises(:exercises_016)
      @user_bucket = user_buckets(:dumbell_bucket)
      @user_bucket_exercise = mock_model(UserBucketExercise, :user_bucket => @user_bucket, :exercise => @exercise)
      UserBucketExercise.stub!(:find).and_return(@user_bucket_exercise)
    end
        
    it "should destory user bucket exercise" do
      @user_bucket_exercise.should_receive(:destroy)
      delete :destroy, :user_bucket_exercise_id => @user_bucket_exercise.id
    end
    
  end
  
end