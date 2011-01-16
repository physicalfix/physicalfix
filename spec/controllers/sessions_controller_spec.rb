require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do

  it_should_behave_like "controllers"
  
  describe "POST sudo" do
    fixtures :users
    
    it "should be the user defined in session[:logged_in_as] if user is admin" do
      @user = mock_model(User, :time_zone => 'UTC')
      @admin_user = mock_model(User, :has_role? => true, :time_zone => 'UTC')
      User.should_receive(:find).any_number_of_times.with(@user.id.to_s).and_return(@user)
      User.should_receive(:find).any_number_of_times.with(@admin_user.id).and_return(@admin_user)
      login(@admin_user)
      post :sudo, {:user_id => @user.id}
      assigns[:logged_in_as].should == @user
    end
    
    it "should redirect to root if the user isn't an admin" do
      @user = mock_model(User, :time_zone => 'UTC')
      @u = mock_model(User, :has_role? => false, :time_zone => 'UTC')
      User.should_receive(:find).any_number_of_times.with(@user.id.to_s).and_return(@user)
      User.should_receive(:find).any_number_of_times.with(@u.id).and_return(@u)
      login(@u)
      post :sudo, {:user_id => @user.id}
      response.should redirect_to(root_path)
    end
    
  end
  
  describe "POST unsudo" do
    fixtures :users
    it 'should set current user back to the admin user' do
      @user = users(:valid_user)
      @admin_user = users(:admin_user)
      login(@admin_user)
      session[:logged_in_as] = @user.id
      post :unsudo
      session[:logged_in_as].should be_nil
    end
  end
  
  describe "POST create" do
    before do
      @subscription = mock_model(Subscription,
                                 :product => Subscription::PREMIUM_SUBSCRIPTION,
                                 :state => 'active')
      @user = mock_model(User, :password_is? => true,
                               :has_role? => false,
                               :medical_history => true,
                               :first_name => 'Adam',
                               :update_attribute => true, :time_zone => 'UTC',
                               :roles_string => 'Premium',
                               :subscription => @subscription
      )

      User.stub!(:find_by_email).and_return(@user)
    end

    it "should render new template if invalid login" do
      User.stub!(:find_by_email).and_return(nil)
      post :create
      response.should render_template(:new)
    end

    it "should render new template if invalid password" do
      @user.stub!(:password_is?).and_return(false)
      post :create
      response.should render_template(:new)
    end

    it "should redirect to new medical history path if there is no medical history and the user is a premium user" do
      User.stub!(:find).and_return(@user)
      @subscription.stub!(:product).and_return(Subscription::PREMIUM_SUBSCRIPTION)
      @user.stub!(:medical_history).and_return(nil)
      post :create
      response.should redirect_to(new_account_medical_history_path)
    end

    it "should not redirect to new medical history path if there is no medical history and the user is not a premium user" do
      User.stub!(:find).and_return(@user)
      @subscription.stub!(:product).and_return(Subscription::BASIC_SUBSCRIPTION)
      @user.stub!(:medical_history).and_return(nil)
      post :create
      response.should_not redirect_to(new_account_medical_history_path)
    end

    it "should set cc problem in session if the state is in a problem state" do
      User.stub!(:find).and_return(@user)
      @subscription.stub!(:product).and_return(Subscription::BASIC_SUBSCRIPTION)
      @subscription.stub!(:state).and_return('past_due')
      post :create
      session[:cc_problem].should == true
    end

    it "should redirect to return path if it exists" do
      User.stub!(:find).and_return(@user)
      session[:return_to] = "/account"
      post :create
      response.should redirect_to(account_path)
    end
    
    it "should redirect to food log if the user is a free user" do
      User.stub!(:find).and_return(@user)
      @subscription.stub!(:product).and_return(Subscription::FREE_SUBSCRIPTION)
      post :create
      response.should redirect_to(food_log_index_path)
    end
    
    it "should redirect to workouts if no return path" do
      User.stub!(:find).and_return(@user)
      post :create
      response.should redirect_to(workouts_path)
    end

    it "should redirect to admin section if user is admin" do
      User.stub!(:find).and_return(@user)
      @user.stub!(:has_role?).and_return(true)
      post :create
      response.should redirect_to(admin_path)
    end

    it "should assigin session user id" do
      User.stub!(:find).and_return(@user)
      post :create
      session[:uid].should == @user.id
    end
    
  end

  describe "DELETE destroy" do
    fixtures :users

    before do
      login(users(:valid_user))
    end

    it "should set session user id to nil" do
      delete :destroy
      session[:uid].should be_nil
    end
    
    it "should redirect to root" do
      delete :destroy
      response.should redirect_to(root_path)
    end
    
    it "should reset session[:logged_in_as]" do
      session[:logged_in_as] = users(:valid_user).id
      delete :destroy
      session[:logged_in_as].should be_nil
    end
    
  end

end