require File.dirname(__FILE__) + '/../spec_helper'

describe Notifier do

  describe "login_nag_email"  do
    it "should send email" do
      @user = mock_model(User, :email => 'test@example.com', :first_name => 'test')
      Notifier.deliver_login_nag_email(@user, 12)
    end
  end

  describe "nag_digest_email" do
    it "should send email" do
      @user = mock_model(User, :email => 'test@example.com', :first_name => 'test')
      Notifier.deliver_nag_digest_email([])
    end
  end

  describe "premium_signup_notification" do
    it "should send email" do
      @user = mock_model(User, :email => 'test@example.com', :first_name => 'test')
      Notifier.deliver_premium_signup_notification(@user)
    end
  end
end

