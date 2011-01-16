require File.dirname(__FILE__) + '/../spec_helper'

describe PasswordsController do

  fixtures :users

  before do
    @logged_in_user = users(:valid_user)
    login(@logged_in_user)
  end

  it_should_behave_like "controllers"

  describe "GET new" do
    it "should render the sign_in layout" do
      get :new
      response.layout.should == 'layouts/sign_in' 
    end
  end

  describe "POST create" do
    it "should send reset email for valid email" do
      Notifier.should_receive(:deliver_password_recovery).once
      post :create, :email => users(:valid_user).email
    end

    it "should redirect to root for valid email" do
      post :create, :email => users(:valid_user).email
      response.should redirect_to(root_path) 
    end

    it "should warn for an invalid email" do
      post :create, :email => 'foo'
      flash[:error].should_not be_empty
      response.should render_template(:new)
    end
  end

  describe "GET edit" do
    it "should redirect on invalid key if id passed" do
      get :edit, :id => '12345'
      response.should redirect_to(root_path)
    end

    it "should require login if no id passed" do
      session[:uid] = nil
      get :edit
      response.should redirect_to(login_path)
    end

    it "should set flash if key is valid" do
      Crypto.stub!(:decrypt).and_return("1:1")
      @user = mock_model(User, :time_zone => 'UTC')
      User.stub!(:find).and_return(@user)
      get :edit, :id => '12345'
      flash[:info].should_not be_empty
    end

  end

  describe "PUT update" do
    it "should redirect to root on invalid key" do
      put :update, :id => '1234'
      response.should redirect_to(root_path)
    end

    it "should render edit template on invalid old password" do
      put :update, :old_password => 'bad_password'
      response.should render_template(:edit)
    end
    
    it "should redirect to login when updating with key" do
      session[:uid] = nil
      Crypto.stub!(:decrypt).and_return("1:1")
      @user = mock_model(User, :time_zone => 'UTC')
      User.stub!(:find).and_return(@user)
      @user.stub!(:update_attributes).and_return(true)
      put :update, :id => 'some_key'
      response.should redirect_to(login_path)
    end

    it "should redirect to account page when updating when logged in" do
      @user = mock_model(User, :time_zone => 'UTC')
      User.stub!(:find).and_return(@user)
      @user.stub!(:password_is?).and_return(true)
      @user.stub!(:update_attributes).and_return(true)
      put :update, :old_password => 'some_password'
      response.should redirect_to(account_path)
    end

    it "should render edit on non matching passwords" do
      @user = mock_model(User, :time_zone => 'UTC')
      User.stub!(:find).and_return(@user)
      @user.stub!(:password_is?).and_return(true)
      @user.stub!(:update_attributes).and_return(false)
      put :update, :old_password => 'some_password'
      response.should render_template(:edit)
    end
  end

end