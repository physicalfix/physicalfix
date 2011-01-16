class FavoriteFoodsController < ApplicationController
  before_filter :require_login

  def index
    @favorites = FavoriteFood.find_all_by_user_id(current_user.id, :include => :food_items)
  end

  def create
    favorite_food = FavoriteFood.new
    if params[:id]
      @food = Food.find(params[:id])
      favorite_food.name = @food.display_name
    elsif params[:meal_id]
      @food = Meal.find(params[:meal_id])
      favorite_food.name = @food.food_name
    end

    favorite_food.user_id = current_user.id

    if favorite_food.save
      food_item = FoodItem.new
      food_item.user_id = current_user.id
      food_item.favorite_food_id = favorite_food.id.to_s
      if params[:meal_id]
        food_item.meal_id = @food.id
        id = "favorite-meal-#{params[:meal_id]}"
        obj = {'meal_id' => params[:meal_id]}
      else
        food_item.food_id = @food.id.to_s
        id = "favorite-food-#{@food.id.to_s}"
        obj = {'food_id' => @food.id.to_s}
      end
      food_item.save
      favorite_food.food_items << food_item
    end
    
    render :update do |page|
      page.replace_html(id, :partial =>'/foods/favorite_link', :object => obj)
      page.replace_html("favoritetable", :partial => "/foods/favorite", :collection => current_user.favorite_foods)
    end
  end

  def destroy
    FavoriteFood.find(params[:id]).destroy
    unless params[:manage]
      if params[:food_id]
        @food = Food.find(params[:food_id])
        id = "favorite-food-#{params[:food_id]}"
        obj = {'food_id' => params[:food_id]}
      else
        @food = Meal.find(params[:meal_id])
        id = "favorite-meal-#{params[:meal_id]}"
        obj = {'meal_id' => params[:meal_id]}
      end
      
      render :update do |page|
        page.replace_html(id, :partial =>'/foods/favorite_link', :object => obj)
        page.replace_html("favoritetable", :partial => "/foods/favorite", :collection => current_user.favorite_foods)
      end
    else
      redirect_to :action => :index
    end
  end
end
