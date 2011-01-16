require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::HomeController do
  fixtures :users, :user_roles

  before do
    @user = users(:admin_user)
    login(@user)
  end

  it_should_behave_like "controllers"

  describe "GET index" do
    it "should do something" do
      get :index
    end
  end

end