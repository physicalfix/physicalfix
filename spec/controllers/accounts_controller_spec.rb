require File.dirname(__FILE__) + '/../spec_helper'

describe AccountsController do
  fixtures :users, :roles, :user_buckets

  it_should_behave_like "controllers"
  
  describe "GET index" do
    it "should render splash layout" do
      get :index
      response.layout.should == 'layouts/splash'
    end
  end
  
  describe "GET show" do
    fixtures :users
    before(:each) do
      login(users(:valid_user))
      @user = users(:valid_user)
    end

    it "should require login" do
      request.session[:uid] = nil
      get :show
      response.should redirect_to(login_path)
    end

    it "should get user" do
      get :show
      if user = instance_variable_get("@user")
        user.should_not be_nil
        assigns(:user).should == user
      else
        assigns(:user).should_not be_nil
      end
    end
    
    it "should assign title" do
      get :show 
      assigns(:page_title).should == "Account Info"
    end
    
    it "should assign height_feet" do
      get :show
      assigns(:height_feet).should == 5
    end
    
    it "should assign height_inches" do
      get :show
      assigns(:height_inches).should == 11
    end
    
  end

  describe "GET new" do
    it "should work" do
      get :new
    end
    
    it "should save plan type in the session" do
      get :new, :plan => 'basic'
      session[:plan].should == 'basic'
    end    
    
    it "should not save plan type in the session if it's not a valid plan type" do
      get :new, :plan => 'foo'
      session[:plan].should == nil
    end
    
    it "should render splash layout" do
      get :index
      response.layout.should == 'layouts/splash'
    end
    
  end

  describe "POST create" do
    before(:all) do
      @params ={
        :user => {},
        :credit_card => {},
        :height_feet => '5',
        :height_inches => '11'
      }
    end
    describe "all users" do
      it "should fail on invalid user" do
        User.stub!(:new).and_return(mock_model(User, :valid? => false))
        post :create, @params
        response.should render_template(:new)
      end
    end
    
    describe "a free user" do
      before do
        session[:plan] = 'free'
      end
      it "should create a new user" do
        @user = mock_model(User, :valid? => true, :save => true, :reload => true, :user_weights => [], :weight => '140', :send_signup_notification => true)
        User.stub!(:new).and_return(@user)
        User.stub!(:find).and_return(@user)
        @user.should_receive(:save)
        post :create, @params
      end
      
      it "should create a free subscription" do
        @user = mock_model(User, :valid? => true, :save => true, :reload => true, :user_weights => [], :weight => '140', :send_signup_notification => true)
        User.stub!(:new).and_return(@user)
        User.stub!(:find).and_return(@user)
        Subscription.should_receive(:create).with(:user_id => @user.id, :product => 'free', :state => 'active')
        post :create, @params
      end
      
      it "should reload user" do
        @user = mock_model(User, :valid? => true, :save => true, :user_weights => [], :weight => '140', :send_signup_notification => true)
        User.stub!(:new).and_return(@user)
        User.stub!(:find).and_return(@user)
        @user.should_receive(:reload)
        post :create, @params
      end
      
      it "should login user" do
        @user = mock_model(User, :valid? => true, :save => true, :reload => true, :user_weights => [], :weight => '140', :send_signup_notification => true)
        User.stub!(:new).and_return(@user)
        User.stub!(:find).and_return(@user)
        post :create, @params
        session[:uid].should == @user.id
      end
      
      it "should add weight" do
        @user = mock_model(User, :valid? => true, :save => true, :reload => true, :weight => '140', :send_signup_notification => true)
        uw = mock('user weight proxy', :size => 0)
        uw.should_receive(:<<)
        @user.stub!(:user_weights).and_return(uw)
        User.stub!(:new).and_return(@user)
        User.stub!(:find).and_return(@user)
        
        post :create, @params
      end
      
      it "should send email" do
        @user = mock_model(User, :valid? => true, :save => true, :reload => true, :user_weights => [], :weight => '140')
        User.stub!(:new).and_return(@user)
        User.stub!(:find).and_return(@user)
        @user.should_receive(:send_signup_notification)
        post :create, @params
      end
      
      it "should redirect to thank_you" do
        @user = mock_model(User, :valid? => true, :save => true, :reload => true, :user_weights => [], :weight => '140', :send_signup_notification => true)
        User.stub!(:new).and_return(@user)
        User.stub!(:find).and_return(@user)
        post :create, @params
        response.should redirect_to(thank_you_path)
      end
      
    end
    
    describe "a paid user" do
      before do
        session[:plan] = 'basic'
        @good_user = mock_model(User, 
          :valid? => true, 
          :save => true, 
          :reload => true, 
          :user_weights => [], 
          :weight => '140', 
          :send_signup_notification => true,
          :first_name => 'test',
          :last_name => 'user')
        @good_card = mock_model(CreditCard, :valid? => true)
        @bad_card = mock_model(CreditCard, :valid? => false)
        @good_sub = mock_model(Chargify::Subscription, :state => 'active', :errors => mock('errors_proxy', :errors => {}))
      end
      
      it "should fail on invalid credit card" do
        CreditCard.stub!(:new).and_return(@bad_card)
        User.stub!(:new).and_return(@good_user)
        post :create, @params
        response.should render_template(:new)
      end
      
      it "should create a new user on success" do
        CreditCard.stub!(:new).and_return(@good_card)
        Subscription.stub!(:create_subscription).and_return(@good_sub)
        User.stub!(:new).and_return(@good_user)
        User.stub!(:find).and_return(@good_user)
        @good_user.should_receive(:save)
        post :create, @params
      end
      
      it "should fail on credit card failure" do
        CreditCard.stub!(:new).and_return(@good_card)
        User.stub!(:new).and_return(@good_user)
        User.stub!(:find).and_return(@good_user)
        Subscription.stub!(:create_subscription).and_return(mock_model(Chargify::Subscription, :errors => mock('errors_proxy', :errors => {:not => 'empty'}, :full_messages => ['you', 'suck'])))
        post :create, @params
        response.should render_template(:new)
      end
      
      it "should create a subscription on a valid cc" do
        CreditCard.stub!(:new).and_return(@good_card)
        User.stub!(:new).and_return(@good_user)
        User.stub!(:find).and_return(@good_user)
        Subscription.stub!(:create_subscription).and_return(@good_sub)
        Subscription.should_receive(:create).with(:user_id => @good_user.id, :product => 'basic', :state => 'active', :chargify_id => @good_sub.id)
        post :create, @params
      end
      
      it "should reload user" do
        CreditCard.stub!(:new).and_return(@good_card)
        User.stub!(:new).and_return(@good_user)
        User.stub!(:find).and_return(@good_user)
        @good_user.should_receive(:reload)
        Subscription.stub!(:create_subscription).and_return(@good_sub)
        post :create, @params
      end
      
      it "should login user" do
        CreditCard.stub!(:new).and_return(@good_card)
        User.stub!(:new).and_return(@good_user)
        User.stub!(:find).and_return(@good_user)
        Subscription.stub!(:create_subscription).and_return(@good_sub)
        post :create, @params
        session[:uid].should == @good_user.id
      end
      
      it "should add weight" do
        CreditCard.stub!(:new).and_return(@good_card)
        User.stub!(:new).and_return(@good_user)
        User.stub!(:find).and_return(@good_user)
        uw = mock('user weight proxy', :size => 0)
        uw.should_receive(:<<)
        @good_user.stub!(:user_weights).and_return(uw)
        Subscription.stub!(:create_subscription).and_return(@good_sub)
        post :create, @params
      end
      
      it "should send email" do
        CreditCard.stub!(:new).and_return(@good_card)
        User.stub!(:new).and_return(@good_user)
        User.stub!(:find).and_return(@good_user)
        Subscription.stub!(:create_subscription).and_return(@good_sub)
        @good_user.should_receive(:send_signup_notification)
        post :create, @params
      end
      
      it "should redirect to thank_you" do
        CreditCard.stub!(:new).and_return(@good_card)
        User.stub!(:new).and_return(@good_user)
        User.stub!(:find).and_return(@good_user)
        Subscription.stub!(:create_subscription).and_return(@good_sub)
        post :create, @params
        response.should redirect_to(thank_you_path
        )
      end
      
    end
  end

  describe "GET edit" do
    before(:each) do
      login(users(:valid_user))
      @user = users(:valid_user)
      @height_feet = 5
      @height_inches = 11
    end

    it "should require login" do
      request.session[:uid] = nil
      get :edit
      response.should redirect_to(login_path)
    end

    it "should assign user" do
      get :edit
      if user = instance_variable_get("@user")
        user.should_not be_nil
        assigns(:user).should == user
      else
        assigns(:user).should_not be_nil
      end
    end

    it "should assign height_feet" do
      get :edit
      if height_feet = instance_variable_get("@height_feet")
        height_feet.should_not be_nil
        assigns(:height_feet).should == height_feet
      else
        assigns(:height_feet).should_not be_nil
      end
    end

    it "should assign height_inches" do
      get :edit
      if height_inches = instance_variable_get("@height_inches")
        height_inches.should_not be_nil
        assigns(:height_inches).should == height_inches
      else
        assigns(:height_inches).should_not be_nil
      end
    end

  end

  describe "PUT update" do
    before(:each) do
      login(users(:valid_user))
      @user_params = {
        :cell_phone => "6666666666",
        :weight => "150",
        :target_weight => "170",
        :birthday => 26.years.ago.to_date,
        :goals => "hello",
        :equipment => ["cheese","crackers"],
        :home_phone => "4444444444",
        :fitness_level => 'Poor'
      }
    end

    it "should require login" do
      request.session[:uid] = nil
      put :update, {:user => @user_params, :height_feet => 6, :height_inches => 2}
      response.should redirect_to(login_path)
    end

    it "should render edit template on error" do
      put :update, {:user => {:fitness_level => ''}}
      response.should render_template(:show)
    end

    it "should update info" do
      put :update, {:user => @user_params, :height_feet => 6, :height_inches => 2}
      @user = User.find(request.session[:uid])
      @user.cell_phone.should == "6666666666"
      @user.weight.should == 150
      @user.target_weight.should == 170
      @user.birthday.should == 26.years.ago.to_date
      @user.goals.should == "hello"
      @user.equipment.should == "cheese|crackers"
      @user.home_phone.should == "4444444444"
      @user.height.should == "6' 2\""
    end

    it "should redirect on success" do
      put :update, {:user => @user_params, :height_feet => 6, :height_inches => 2}
      response.should redirect_to(account_path)
    end
        
    it "should redirect to workouts if updating user bucket from workout path" do
      put :update, {:update_user_bucket_on_workout => true, :user => {:user_bucket_id => 11, :workout_difficulty => 'easy'}}
      response.should redirect_to(workouts_path)
    end
  end

  describe "GET thank_you" do
    before(:each) do
      login(users(:valid_user))
      @user = users(:valid_user)
    end
    
    it "should require login" do
      request.session[:uid] = nil
      get :show
      response.should redirect_to(login_path)
    end
    
    it "should redirect to root unless session is set" do
      get :thank_you
      response.should redirect_to(root_path)
    end
    
    it "should not redirect if session is set" do 
      session[:plan] = Subscription::FREE_SUBSCRIPTION
      get :thank_you
      response.should_not be_redirect
    end
    
  end
end
