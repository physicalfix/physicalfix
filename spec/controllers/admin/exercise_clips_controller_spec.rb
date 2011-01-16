require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ExerciseClipsController do
  fixtures :users, :exercises, :roles, :user_roles
  
  before(:each) do
    @user = users(:admin_user)
    login(@user)
  end

  it_should_behave_like "controllers"
  
  describe "GET new" do
    it "should assign exercise" do
      Exercise.stub!(:find).and_return(@e = mock_model(Exercise))
      get(:new, :exercise_id => @e.id)
      assigns(:exercise).should == @e
    end
    
    it "should assign exercise clip" do
      Exercise.stub!(:find).and_return(@e = mock_model(Exercise))
      ExerciseClip.should_receive(:new).with(:exercise_id => @e.id)
      get(:new, :exercise_id => @e.id)
    end
  end
  
  describe "POST create" do
    it "should render new if unsuccessful" do
      ExerciseClip.stub!(:new).and_return(mock_model(ExerciseClip, :save => false))
      post(:create)
      response.should render_template(:new)
    end
    
    it "should redirect if successful" do
      @e = mock_model(Exercise)
      @ec = mock_model(ExerciseClip, :save => true, :exercise => @e)
      ExerciseClip.stub!(:new).and_return(@ec)
      post(:create)
      response.should redirect_to(admin_exercise_path(@e))
    end
    
  end
    
end