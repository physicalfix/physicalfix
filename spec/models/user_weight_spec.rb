require File.dirname(__FILE__) + '/../spec_helper'

describe UserWeight do
  fixtures :users
  before(:each) do
    @user_weight = UserWeight.new
  end

  it "should should be valid on first" do
    @user_weight.weight = 150
    @user_weight.user = users(:valid_user)
    @user_weight.should be_valid
  end

  it "should not validate on second on the same day" do
    @user_weight.weight = 150
    @user_weight.user = users(:valid_user)
    @user_weight.save

    @new_user_weight = UserWeight.new
    @new_user_weight.weight = 150
    @new_user_weight.user = users(:valid_user)
    @new_user_weight.should_not be_valid
  end
end