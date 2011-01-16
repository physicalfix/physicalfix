require File.dirname(__FILE__) + '/../spec_helper'

describe ActivityLogController do
 fixtures :users, :roles, :user_roles, :medical_histories, :subscriptions

  before(:each) do
    @user = users(:valid_user)
    @user.stub!(:subscription).and_return(nil)
    login(@user)
  end
  
  it_should_behave_like "controllers"

  describe "GET index" do
    it "should require login" do
      request.session[:uid] = nil
      get :index
      response.should redirect_to(login_path)
    end
    it "should redirect if no medical_history" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @subscription = mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION )
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      get :index
      response.should redirect_to(new_account_medical_history_path)
    end
    
    it "should not redirect if no medical_history but not premium" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @subscription = mock_model(Subscription, :product => Subscription::BASIC_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      @user.stub!(:user_activities).and_return(mock('ua', :all => []))
      @user.stub!(:favorite_activities).and_return([])
      User.stub!(:find).and_return(@user)
      get :index
      response.should_not be_redirect
    end

    it "should have no results for a date without activites" do
      get :index
      assigns(:activities).should == []
    end
    
    it "should get totals" do
      @ua = mock('user_activites', :all => [
        mock_model(UserActivity, :duration => 10, :calories => 10, :name => 'foo'),
        mock_model(UserActivity, :duration => nil, :calories => 10, :name => 'Daily Energy Expenditure')
        ])
      @user.stub!(:user_activities).and_return(@ua)
      User.stub!(:find).with(@user.id).and_return(@user)
      get :index
    end
    
  end

  describe "POST create" do
    fixtures :activities, :users, :subscriptions
    before(:each) do
      login(users(:valid_user))
      UserActivity.stub!(:new).and_return(@ua = mock_model(UserActivity, :save => true, :user_id= => true))
    end

    def valid_activity_params
      {
        "activity_id" => activities(:aerobics).id,
        "user_id" => users(:valid_user).id,
        "duration" => 20,
        "activity_date" => Time.zone.now.to_date.to_datetime
      }
    end

    def do_post
       post :create, {:user_activity => valid_activity_params}
    end
    it "should redirect if no medical_history" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @subscription = mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      do_post
      response.should redirect_to(new_account_medical_history_path)
    end
    
    it "should not redirect if no medical_history but not premium" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @subscription = mock_model(Subscription, :product => Subscription::BASIC_SUBSCRIPTION )
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      do_post
      response.should_not redirect_to(new_account_medical_history_path)
    end
    
    it "should save the activity" do
      UserActivity.should_receive(:new).with(valid_activity_params).and_return(@ua)
      @ua.should_receive(:user_id=)
      @ua.should_receive(:save).and_return(true)
      do_post
      response.should redirect_to(activity_log_index_path)
    end
    
    it "should redirect to index if not able to save activity" do
      @ua = mock_model(UserActivity, :save => false, :user_id= => true, :errors => mock('error_proxy', :on => true))
      UserActivity.stub!(:new).and_return(@ua)
      do_post
      response.should redirect_to activity_log_index_path
    end

  end

  describe "GET show" do
    it "should set the date based on id" do
      get :show, {:id => "2009-10-10"}
      assigns(:date).should == Date.parse("2009-10-10")
    end
    it "should redirect if no medical_history" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @subscription = mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      get :show
      response.should redirect_to(new_account_medical_history_path)
    end
    it "should grab proper activities based on id" do
      get :show, {:id => "2008-10-10"}
      assigns(:activities).should == []
    end
  end

  describe "DELETE destroy" do
    before do
      @ua = mock_model(UserActivity, :destroy => true)
    end
    
    it "should find the user activity" do
      UserActivity.should_receive(:find).with(@ua.id.to_s).and_return(@ua)
      delete :destroy, :id => @ua.id, :date => '2009-03-13'
    end
    
    it "should redirect to index if date is today" do
      UserActivity.stub!(:find).and_return(@ua)
      delete :destroy, :id => @ua.id, :date => Time.zone.now.to_date.to_s
      response.should redirect_to(activity_log_index_path)
    end
    
    it "should redirect to show with date if date isn't today" do
      UserActivity.stub!(:find).and_return(@ua)
      delete :destroy, :id => @ua.id, :date => '2009-03-13'
      response.should redirect_to(activity_log_path('2009-03-13'))
    end
  end

  describe "GET quick_add" do
    it "should find the activity" do
      @fa = mock_model(FavoriteActivity, :activity => 'test')
      FavoriteActivity.should_receive(:find).with(@fa.id.to_s).and_return(@fa)
      get :quick_add, :id => @fa.id
    end
    
    it "should assign the activity" do
      @fa = mock_model(FavoriteActivity, :activity => 'test')
      FavoriteActivity.stub!(:find).and_return(@fa)
      get :quick_add, :id => @fa.id
      assigns[:activity].should == 'test'
    end
    
  end
  
end
