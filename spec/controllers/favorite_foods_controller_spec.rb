require File.dirname(__FILE__) + '/../spec_helper'

describe FavoriteFoodsController do
  fixtures :users
  
  before(:each) do
    @user = users(:valid_user)
    login(@user)
  end

  it_should_behave_like "controllers"

  describe "GET index" do
    before do
      FavoriteFood.stub!(:find_all_by_user_id).and_return([])
    end

    it "should find all favorite activities" do
      FavoriteFood.should_receive(:find_all_by_user_id).with(@user.id, :include => :food_items).and_return([])
      get :index
    end

    it "shoudl assign @favorites" do
      get :index
      assigns[:favorites].should == []
    end

  end

  describe "POST create" do
    before(:each) do
      @food = mock_model(Food, :name => "yummy food", :display_name => "display name")
      Food.stub!(:find).and_return(@food)
      @params = {:id => @food.id}
    end

    it "should create a new FavoriteFood" do
      @ff = mock_model(FavoriteFood, :save => true, :food_items => [], :name= => true, :user_id= => true)
      FavoriteFood.should_receive(:new).and_return(@ff)
      post :create, @params        
    end

    it "should create a new FoodItem" do
      @ff = mock_model(FavoriteFood, :save => true, :food_items => [], :name= => true, :user_id= => true)
      FavoriteFood.stub!(:new).and_return(@ff)
      @fi = mock_model(FoodItem, :save => true, :user_id= => true, :favorite_food_id= => true, :food_id= => true)
      FoodItem.should_receive(:new).and_return(@fi)
      post :create, @params
    end

    it "should update update the page" do
      @ff = mock_model(FavoriteFood, :save => true, :food_items => [], :name= => true, :user_id= => true)
      FavoriteFood.stub!(:new).and_return(@ff)
      FoodItem.stub!(:create).and_return(mock_model(FoodItem))
      post :create, @params
      response.should have_rjs
    end
    
    it "should create a favorite out of a meal" do
      @meal = mock_model(Meal, :food_name => 'test')
      Meal.should_receive(:find).with(@meal.id.to_s).and_return(@meal)
      post :create, :meal_id => @meal.id
    end
    
  end

  describe "DELETE destroy" do
    before do
      @food = mock_model(Food, :name => 'yummy food', :display_name => "display name")
      Food.stub!(:find).and_return(@food)
      @ff = mock_model(FavoriteFood, :map => [], :destroy => true)
      FavoriteFood.stub!(:find).and_return(@ff)
    end
    it "should destroy the favorite food" do
      @ff.should_receive(:destroy)
      delete :destroy, {:id => '12', :food_id => @food.id}
    end

    it "should redirect to index if manage=true is passed in" do
      delete :destroy, {:id => '12', :manage => true}
      response.should redirect_to favorite_foods_path
    end
    
    it "should find the meal if meal_id is passed in" do
      @meal = mock_model(Meal)
      Meal.should_receive(:find).with(@meal.id.to_s).and_return(@meal)
      delete :destroy, {:id => '12', :meal_id => @meal.id}
    end

  end

end