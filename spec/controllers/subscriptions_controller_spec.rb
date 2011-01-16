require File.dirname(__FILE__) + '/../spec_helper'

describe SubscriptionsController do
  it_should_behave_like "controllers"
  
  fixtures :users, :subscriptions
  
  before do
    @user = users(:basic_user)
    login(@user)
    User.stub!(:find).and_return(@user)
  end
  
  describe "GET index" do
  end
  
  describe "GET show" do
  end
  
  describe "GET new" do
    it "should make a new credit card" do
      @cc == CreditCard.new
      CreditCard.should_receive(:new).and_return(@cc)
      get :new
      assigns[:credit_card].should == @cc
    end
  end
  
  describe "POST create" do
    it "should render new again if invalid credit card" do
      CreditCard.stub!(:new).and_return(mock_model(CreditCard, :valid? => false))
      post :create, :credit_card => {}
      response.should redirect_to(new_subscription_path)
    end
    
    it "should call subscription manager create subscription if cc is valid" do
      CreditCard.stub!(:new).and_return(mock_model(CreditCard, :valid? => true))
      Subscription.should_receive(:create_subscription).and_return(mock_model(Chargify::Subscription, :state => 'active', :errors => mock('errors_proxy', :errors => {})))
      post :create
    end
    
    it "should render new again if there was an error creating the subscription" do
      CreditCard.stub!(:new).and_return(mock_model(CreditCard, :valid? => true))
      Subscription.stub!(:create_subscription).and_return(mock_model(Chargify::Subscription, :errors => mock('errors_proxy', :errors => {:not => 'empty'})))
      post :create
      response.should redirect_to(new_subscription_path)
    end
    
    it "should create a new subscription record if the subscription was successfully created at chargify" do
      CreditCard.stub!(:new).and_return(mock_model(CreditCard, :valid? => true))
      @sub = mock_model(Chargify::Subscription, :state => 'active', :errors => mock('errors_proxy', :errors => {}))
      Subscription.stub!(:create_subscription).and_return(@sub)
      Subscription.should_receive(:create).with(:product => 'basic', :state => @sub.state, :chargify_id => @sub.id, :user_id => @user.id)
      post :create
    end
    
    it "should redirect to thank_you path if the subscription was successfully created" do
      CreditCard.stub!(:new).and_return(mock_model(CreditCard, :valid? => true))
      @sub = mock_model(Chargify::Subscription, :state => 'active', :errors => mock('errors_proxy', :errors => {}))
      Subscription.should_receive(:create_subscription).and_return(@sub)
      post :create
      response.should redirect_to(thank_you_path)
    end
    
  end
  
  describe "GET edit" do
  end
  
  describe "PUT update" do
    describe "chargify callback" do
      it "should call subscription manager to check subscriptions" do
        Subscription.should_receive(:send_later).with(:check_subscription, 8081).once
        post :update, :_method => 'put', :_json => [8081, 8081]
      end
    end
    
    describe "normal update" do
      it "should migrate the subscription" do
        sub = subscriptions(:basic_user_sub)
        @user.stub!(:subscription).and_return(sub)
        sub.should_receive(:migrate).with('basic')
        put :update, :product => 'basic'
      end
    end
  end
  
  describe "DELETE destroy" do
  end
   
end
