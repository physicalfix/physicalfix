class FoodLogController < ApplicationController
  before_filter :require_login
  before_filter :require_medical_history
  before_filter :find_meals_by_date, :only => [:index, :show]
  before_filter :find_favorites, :only => [:index, :show]

  def index
  end

  def show
    render :template => '/food_log/index'
  end

  def new
    @meal = Meal.new
  end

  def create
    meal_id = params[:meal][:meal_id]
    params[:meal].delete(:meal_id)

    @meal = Meal.new(params[:meal])
    @meal.user = current_user
    @meal.eaten_at = @meal.eaten_at.utc
    
    if params[:meal][:food_id]
      create_fs_meal
    elsif !meal_id.nil?
      @old_meal = Meal.find(meal_id)
      @mts = @old_meal.clone
      @mts.eaten_at = @meal.eaten_at
      @mts.servings = @meal.servings
      @meal = @mts
      @meal.save
    else
      @meal.save
    end

    if !@meal.errors.empty?
      if params[:meal][:food_id]
        redirect_to food_log_index_path
      else
        render :controller => :food_log, :action => :new
      end
      return
    else
      food_date = @meal.eaten_at
      if food_date.to_date == Time.zone.now.to_date
        redirect_to food_log_index_path
      else
        redirect_to food_log_path(food_date.to_date.to_s)
      end
    end
  end

  def destroy
    @meal = Meal.find(params[:id])
    @meal.destroy
    if Date.parse(params[:date]) == Time.zone.now.to_date
      redirect_to food_log_index_path
    else
      redirect_to food_log_path(params[:date])
    end
  end

  private
  def find_meals_by_date
    if params[:id]
      @date = Time.parse(params[:id])
    else
      @date = Time.zone.now
    end
    @meals = current_user.meals.all(:order => 'eaten_at ASC', :conditions => ['eaten_at between ? and ?', @date.beginning_of_day.utc, @date.end_of_day.utc])
    
    calc_meal_stats
    @date = @date.to_date
  end
  
  def calc_meal_stats
    @totals = {
      :calories => 0,
      :carbohydrates => 0,
      :fat => 0,
      :protein => 0,
      :sugar => 0
    }

    @meals.each do |meal|
      @totals[:calories] += meal.total_calories
      @totals[:carbohydrates] += meal.total_carbohydrate
      @totals[:fat] += meal.total_fat
      @totals[:protein] += meal.total_protein
      @totals[:sugar] += meal.total_sugar
    end
    
    @calorie_percentage = (@totals[:calories]/current_user.daily_calorie_allotment)
    @calorie_percentage = 1 if @calorie_percentage > 1
    
    @carbo_percentage = (@totals[:carbohydrates]/current_user.daily_carbohydrate_allotment)
    @carbo_percentage = 1 if @carbo_percentage > 1
    
    @fat_percentage = (@totals[:fat]/current_user.daily_fat_allotment)
    @fat_percentage = 1 if @fat_percentage > 1
    
    @protein_percentage = (@totals[:protein]/current_user.daily_protein_allotment)
    @protein_percentage = 1 if @protein_percentage > 1
  end

  def find_favorites
    @favorites = current_user.favorite_foods
  end

  def create_fs_meal
    begin
      food = Food.find(params[:meal][:food_id])
    rescue BSON::InvalidObjectID
      flash[:error] = 'Food not found'
      return
    end
    
    serving = food.servings[params[:meal][:serving_id].to_i]
    
    @meal.food_id = food.id.to_s
    @meal.food_name = food.name
    @meal.food_type = food.brand == 'generic' ? 'generic' : 'brand'
    @meal.serving_description = serving.description
    @meal.serving_amount = params[:meal][:servings]
    @meal.meal_name = params[:meal][:meal_name]
    @meal.brand_name = food.brand
    @meal.calories = serving.calories || 0
    @meal.carbohydrate = serving.carbohydrates || 0
    @meal.protein = serving.protein || 0
    @meal.fat = serving.fat || 0
    @meal.saturated_fat = serving.saturated_fat || 0
    @meal.cholesterol = serving.cholesterol || 0
    @meal.sodium = serving.sodium || 0
    @meal.sugar = serving.sugar || 0

    if @meal.save
      flash[:info] = "Food Added!"
    end

  end

end
