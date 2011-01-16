require File.dirname(__FILE__) + '/../spec_helper'

describe Subscription do
  describe "#create_subscription" do
    fixtures :users
    
    it "should call Chargify::Subscription.create" do
      user =  users(:valid_user)
      Chargify::Subscription.should_receive(:create)
      Subscription.create_subscription(user, 'basic',  mock_model(CreditCard, {
        :first_name => 'credit_card.first_name',
        :last_name => 'credit_card.last_name',
        :expiration => (Date.today + 1.year),
        :card_number => 1,
        :cvv => 123
      }))
    end
  end
  
  describe "#check_subscription" do
    
    it "should find the subscription" do
      Subscription.stub!(:create).and_return(true)
      Chargify::Subscription.should_receive(:find).and_return(
        mock_model(Chargify::Subscription, 
          :state => 'active',
          :product => mock('product', :handle => 'basic-subscription'),
          :customer => mock('customer', :reference => 2)))
      Subscription.check_subscription(12)
    end
    
   it "should create a new subscription entry" do
      sub = mock_model(Chargify::Subscription, 
        :customer => mock('customer', :reference => 2), 
        :state => 'active',
        :product => mock('product', :handle => 'basic-subscription'))
      
      Chargify::Subscription.stub!(:find).and_return(sub)
      
      Subscription.should_receive(:create).with(:user_id => 2, :product => 'basic', :state => 'active', :chargify_id => sub.id)
      Subscription.check_subscription(12)
    end
    
    it "should return if the subscription can not be found" do
      Subscription.should_not_receive(:create)
      Subscription.check_subscription(123)    
    end
    
    it "should downgrade the user to a free subscription if the state is in the end of life" do
       sub = mock_model(Chargify::Subscription, 
          :customer => mock('customer', :reference => 2), 
          :state => 'canceled',
          :product => mock('product', :handle => 'basic-subscription'))

        Chargify::Subscription.stub!(:find).and_return(sub)

        Subscription.should_receive(:create).with(:user_id => 2, :product => 'free', :state => 'canceled', :chargify_id => sub.id)
        Subscription.check_subscription(12)
    end
    
  end
  
  describe "#paid_subscription" do
    it "should return true if the product type is a basic subscription" do
      Subscription.paid_subscription('basic').should be_true
    end

    it "should return true if the product type is a premium subscription" do
      Subscription.paid_subscription('premium').should be_true
    end
    
    it "should return false if the product type is free subscription" do
      Subscription.paid_subscription('free').should be_false
    end
  end
  
  describe ".unsubscribe" do
    fixtures :subscriptions
    it "should find and cancel the subscription" do
      subscription = subscriptions(:basic_user_sub)
      sub = mock_model(Chargify::Subscription, :cancel => true, :reload => true)
      Chargify::Subscription.should_receive(:find).and_return(sub)
      subscription.unsubscribe
    end
  end
  
  describe ".migrate" do
    fixtures :subscriptions
    it "should call migrate on Chargify::Subscription" do
      sub = subscriptions(:basic_user_sub)
      s = mock_model(Chargify::Subscription, :state => 'active')
      Chargify::Subscription.stub!(:find).and_return(s)
      s.should_receive(:migrate).with({:product_handle => 'premium-subscription'})
      sub.migrate('premium')
    end
  end
  
end