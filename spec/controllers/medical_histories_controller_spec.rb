require File.dirname(__FILE__) + '/../spec_helper'

describe MedicalHistoriesController do

  fixtures :users, :roles, :user_roles

  before do
    login(users(:valid_user))
  end
  
  it_should_behave_like "controllers"

  describe "GET new" do

    it "should require login" do
      session[:uid] = nil
      get :new
      response.should redirect_to(login_path)
    end

    it "should require no medical history" do
      @mh = mock_model(MedicalHistory)
      @user = mock_model(User, :medical_history => @mh, :time_zone => 'UTC')
      session[:uid] = @user.id
      User.stub!(:find).with(@user.id).and_return(@user)
      get :new
      response.should redirect_to(account_path)
    end
    
    it "should just do new" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      session[:uid] = @user.id
      User.stub!(:find).with(@user.id).and_return(@user)
      MedicalHistory.should_receive(:new)
      get :new
    end

  end

  describe "POST create" do

    before do
      @mh = mock_model(MedicalHistory)
      
    end

    it "should create new record" do
      MedicalHistory.stub!(:new).and_return(@mh)
      @mh.should_receive(:save).and_return(true)
      post :create, {:medical_history => {}}
    end

    it "should redirect to workouts path on valid medical history" do
      MedicalHistory.stub!(:new).and_return(@mh)
      @mh.stub!(:save).and_return(true)
      post :create, {:medical_history => {}}
      response.should redirect_to(workouts_path)
    end

    it "should error on invalid medical history" do
      MedicalHistory.stub!(:new).and_return(@mh)
      @mh.stub!(:save).and_return(false)
      @mh.errors.stub!(:full_messages).and_return([])
      post :create, {:medical_history => {}}
      response.should render_template('/medical_histories/new')
    end

    it "should cleanup input" do
      post :create, {:medical_history => {
          :experience => ["difficulty walking due to dizziness", "fainting"],
          :diagnose => ["one", "two", ""]
        }}
      assigns[:medical_history].experience.should == "difficulty walking due to dizziness|fainting"
      assigns[:medical_history].diagnose.should == "one|two"
    end

  end

end