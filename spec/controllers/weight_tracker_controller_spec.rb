require File.dirname(__FILE__) + '/../spec_helper'

describe WeightTrackerController do
  
  it_should_behave_like "controllers"

  fixtures :users, :roles, :user_roles, :medical_histories

  before do
    @user = users(:valid_user)
    login(@user)
  end

  describe "GET index" do
     it "should redirect if no medical_history" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @subscription = mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      get :index
      response.should redirect_to(new_account_medical_history_path)
    end
    
     it "should redirect if no medical_history" do
      @subscription = mock_model(Subscription, :product => Subscription::BASIC_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      get :index
      response.should_not be_redirect
    end
    
    
    
    it "should work" do
      get :index
    end
    
  end

  describe "POST create" do
    before do
      @uw = mock_model(UserWeight, :valid? => true, :save => true)
      UserWeight.stub!(:new).and_return(@uw)
    end

    it "should redirect if no medical_history" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @subscription = mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      post :create, :weight_tracker => {:target_weight => 150}
      response.should redirect_to(new_account_medical_history_path)
    end
    
    
    it "should not redirect if no medical history but not premium" do
      @subscription = mock_model(Subscription, :product => Subscription::BASIC_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      post :create, :weight_tracker => {:target_weight => 150}
      response.should redirect_to(weight_tracker_index_path)
    end

    it "should update target weight if there is none" do
      @user = mock_model(User, :medical_history =>{}, :time_zone => 'UTC')
      User.stub!(:find).and_return(@user)
      @user.should_receive(:update_attribute).with(:target_weight, 150).and_return(true)
      post :create, :weight_tracker => {:target_weight => 150}
    end

    it "should create new weight entry if valid" do
      @uw.should_receive(:save).and_return(true)
      post :create, {:weight_tracker => {:weight => 120}}
    end

    it "should warn on invalid entry" do
      @uw.stub!(:valid?).and_return(false)
      post :create, {:weight_tracker => {:weight => 120}}
      flash[:error].should_not be_empty
    end

    it "should always redirect to index" do
      post :create,  {:weight_tracker => {:weight => 120}}
      response.should redirect_to(weight_tracker_index_path)
    end
  end

  describe "GET show" do
    it "should get user weight" do
      UserWeight.should_receive(:find)
      get :show, :id => 1
    end
     it "should redirect if no medical_history" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @subscription = mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      get :show, :id => 1
      response.should redirect_to(new_account_medical_history_path)
    end
    it "should not redirect if no medical_history but not premium" do
      @subscription = mock_model(Subscription, :product => Subscription::BASIC_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      UserWeight.stub!(:find).with("1").and_return(mock_model(UserWeight, :user => @user, :weight => 124))
      get :show, :id => 1
      response.should_not be_redirect
    end
  end

end