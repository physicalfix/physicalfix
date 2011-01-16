require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::UsersController do
  fixtures :users

  before do
    @admin_user = users(:admin_user)
    login(@admin_user)
    User.stub!(:find).with(@admin_user.id).and_return(@admin_user)
    @admin_user.stub!(:has_role?).and_return(true)
  end

  it_should_behave_like "controllers"

  describe "GET index" do

    it "should find all users" do
      User.should_receive(:paginate)
      get :index
    end
    
    it "should find users needing workouts" do
      User.should_receive(:users_needing_workouts)
      get :index, :unw => 'true'
    end
  end

  describe "GET medical_history" do
    it "should get medical history" do
      @mh = mock_model(MedicalHistory)
      @u = mock_model(User, :email => 'some_email', :medical_history => @mh, :time_zone => 'UTC')
      User.stub!(:find).with("2").and_return(@u)
      get :medical_history, :id => 2
      #response.headers["Status"].to_i.should == 200
    end
  end

  describe "GET show" do
    it "should find the user" do
      @u = mock_model(User, :email => 'foo')
      User.should_receive(:find).with(@u.id.to_s)
      get :show, :id => @u.id
    end
    
  end

end