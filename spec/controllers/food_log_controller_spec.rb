require File.dirname(__FILE__) + '/../spec_helper'

describe FoodLogController do
  fixtures :users, :roles, :user_roles, :medical_histories, :subscriptions

  before(:each) do
    @user = users(:valid_user)
    login(@user)
  end

  it_should_behave_like "controllers"

  describe "GET index" do
    fixtures :meals, :users
    it "should redirect if no medical_history" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @subscription = mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      get :index
      response.should redirect_to(new_account_medical_history_path)
    end
    
    it "should not redirect if no medical_history but not premium" do
      @subscription = mock_model(Subscription, :product => Subscription::BASIC_SUBSCRIPTION)
      User.stub!(:find).and_return(@user)
      get :index
      response.should_not be_redirect
    end
    
    it "should require login" do
      request.session[:uid] = nil
      get :index
      response.should redirect_to(login_path)
    end
    
    it "should have no results for a date without meals" do
      get :index
      assigns(:meals).should == []
    end
  end
  describe "GET new" do
    it "should assign a new @meal" do
      get :new
      assigns[:meal].should be_new_record
    end
  end
  
  describe "POST create" do
    fixtures :users, :medical_histories, :meals

    before(:each) do
      @user = users(:valid_user)
      login(@user)
      Food.stub!(:find).and_return(mock_model(Food,
        :name => "Bacon",
        :brand => "generic",
        :servings => [
          mock_model(Serving, 
            :description => "1 thin slice (yield after cooking)",
            :calcium => 0,
            :fat => 2.09,
            :sugar => 0,
            :fiber => 0,
            :protein => 1.85,
            :calories => 27,
            :carbohydrates => 0.07,
            :saturated_fat => 0.687,
            :cholesterol => 6,
            :sodium => 116
          )]))
    end
    
    def valid_meal_params
      {
        "food_id" => '1517',
        "serving_id" => 0,
        "servings" => 1,
        "eaten_at" => Time.zone.now
      }
    end
    
    def do_post
       post :create, {:meal => valid_meal_params}
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
      @subscription = mock_model(Subscription, :product => Subscription::BASIC_SUBSCRIPTION)
      User.stub!(:find).and_return(@user)
      do_post
      response.should_not redirect_to(new_account_medical_history_path)
    end

    it "should create a new meal" do
      @meal = Meal.new(valid_meal_params)
      Meal.should_receive(:new).and_return(@meal)
      @meal.should_receive(:save).and_return(true)
      do_post
    end

    it "should assign all of the meal attributes" do
      do_post
      assigns[:meal].fat.should == 2.09
    end

    it "should redirect to food log index" do
      do_post
      response.should redirect_to food_log_index_path
    end

    it "should redirect to food log for different day if food eaten at a different day" do
      new_params = valid_meal_params
      new_params["eaten_at"] = Time.zone.now - 5.days
      post :create, {:meal => new_params}
      response.should redirect_to food_log_path(new_params["eaten_at"].to_date.to_s)
    end

    it "should set flash on invalid food_id" do
      Food.stub!(:find).and_raise(BSON::InvalidObjectID)
      do_post
      flash[:error].should == 'Food not found'
    end
    
    it "should add a meal if a meal id is passed in (favorite custom foods)" do
      @meal = meals(:yummy_meal)
      Meal.stub!(:find).and_return(@meal)
      post :create, {:meal => {:meal_id => @meal, :eaten_at => Time.now, :servings => 1}}
      assigns[:meal].fat.should == @meal.fat
    end
    
  end
  
  describe "GET show" do
    fixtures :meals, :users
    it "should redirect if no medical_history" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @subscription = mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      get :show
      response.should redirect_to(new_account_medical_history_path)
    end
    
    it "should not redirect if no medical_history but premium" do
      @subscription.stub!(:product).and_return(Subscription::FREE_SUBSCRIPTION)
      User.stub!(:find).and_return(@user)
      get :show
      response.should_not be_redirect
    end
    
    it "should set the date based on id" do
      get :show, {:id => "2009-10-10"}
      assigns(:date).should == Date.parse("2009-10-10")
    end

    it "should grab proper meals based on id" do
      get :show, {:id => "2008-10-10"}
      assigns(:meals).should == [meals(:yummy_meal)]
    end

    it "should calculate totals" do
      get :index, {:id => '2008-10-10'}
      assigns(:totals)[:fat].should == 10
    end



  end

  describe "DELETE destroy" do
    before(:each) do
      @meal = mock_model(Meal)
      @meal.should_receive(:destroy)
      Meal.should_receive(:find).and_return(@meal)
    end
    
    it "should destroy the meal" do
      delete :destroy, {:date => Time.zone.now.to_date.to_s(:short)}
    end
    
    it "should redirect to the index if the date passed in is today" do
      delete :destroy, {:date => Time.zone.now.to_date.to_s(:short)}
      response.should redirect_to food_log_index_path
    end

    it "should redirect to a given date if passed in" do
      d = Time.zone.now.to_date - 3.days
      delete :destroy, {:date => d.to_s(:short)}
      response.should redirect_to food_log_path(d.to_s(:short))
    end
  end

end

