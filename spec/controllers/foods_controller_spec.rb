require File.dirname(__FILE__) + '/../spec_helper'

describe FoodsController do
  fixtures :users, :meals

  before(:each) do
    @user = users(:valid_user)
    login(@user)
  end
  
  it_should_behave_like "controllers"

  describe "GET index" do

    it "should require login" do
      request.session[:uid] = nil
      get :index
      response.should redirect_to(login_path)
    end

    it "should redirect to food_log with no params" do
      get :index
      response.should redirect_to(food_log_index_path)
    end

    it "should get foods based on search" do
Sunspot.should_receive(:search).and_return(mock_model(Sunspot::Search::StandardSearch, :results => mock_model(WillPaginate::Collection, :[] => [])))
      get :index, {:food => 'butter'}
    end
  end
  
  describe "GET quick_add" do
    it "should find the favorite" do
      @meal = meals(:yummy_meal)
      @ff = mock_model(FavoriteFood, :food_items => [mock_model(FoodItem, :meal_id => @meal.id)])
      FavoriteFood.should_receive(:find).with(@ff.id.to_s).and_return(@ff)
      get :quick_add, :id => @ff.id
    end
    
    it "should find the meal if the favorite is a meal" do
      @meal = meals(:yummy_meal)
      @ff = mock_model(FavoriteFood, :food_items => [mock_model(FoodItem, :meal_id => @meal.id)])
      FavoriteFood.stub!(:find).with(@ff.id.to_s).and_return(@ff)
      Meal.should_receive(:find).with(@meal.id).and_return(@meal)
      get :quick_add, :id => @ff.id
    end
    
    it "should find the food if the favorite is a food" do
      @ff = mock_model(FavoriteFood, :food_items => [mock_model(FoodItem, :meal_id => nil, :food_id => 12)])
      FavoriteFood.stub!(:find).with(@ff.id.to_s).and_return(@ff)
      Food.should_receive(:find).with(12).and_return(mock_model(Food, :display_name => 'cheese', :servings =>[mock_model(Serving, :description => 'test')]))
      get :quick_add, :id => @ff.id
    end

    it "should iterate through all of the servings" do
      @ff = mock_model(FavoriteFood, :food_items => [mock_model(FoodItem, :meal_id => nil, :food_id => 12)])
      FavoriteFood.stub!(:find).with(@ff.id.to_s).and_return(@ff)
      Food.should_receive(:find).with(12).and_return(mock_model(Food, :display_name => 'cheese', :servings =>[mock_model(Serving, :description => 'test')]))
      get :quick_add, :id => @ff.id
    end
  end
  
  describe "GET food_details" do
    it "should find the food" do
      @ff = mock_model(FavoriteFood, :food_items => [mock_model(FoodItem, :food_id => 12)])
      @user.favorite_foods.stub!(:find).and_return([@ff])
      User.stub!(:find).with(@user.id).and_return(@user)
      Food.should_receive(:find).with('234').and_return(mock_model(Food, :servings => [mock_model(Serving)]))
      get :food_details, :food_id => 234
    end
  end
    
end