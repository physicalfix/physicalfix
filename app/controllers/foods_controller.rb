class FoodsController < ApplicationController
  before_filter :require_login
  before_filter :find_favorites, :only => [:index, :food_details]
  
  def index
    if !params[:food]
      redirect_to food_log_index_path
      return
    end

    #if params[:page]
    #  @foods = FsFood.find_all_by_name(params[:food], params[:page].to_i-1)
    #else
    #  @foods = FsFood.find_all_by_name(params[:food])
    #end
    #
    #unless @foods['error']
    #  @total_pages = (@foods['foods']['total_results'].to_f/@foods['foods']['max_results'].to_i).ceil
    #  @current_page = @foods['foods']['page_number'].to_i + 1
    #
    #  if @foods['foods'] && @foods['foods']['food']
    #    @foods = @foods['foods']['food']
    #    @foods = [@foods] if @foods.is_a?(Hash)
    #  else
    #    @foods = []
    #  end
    #else
    #  @total_pages = 0
    #  @current_page = 0
    #  @foods = []
    #end
    
    page_number = params[:page] || 1
    
    search = Sunspot.search(Food) do |query|
      query.keywords params[:food]
      query.paginate :page => page_number, :per_page => 30
    end

    @foods = search.results
    
    spelling = Spell.correct(params[:food])
    @suggestion = spelling if spelling != params[:food]

    render :file =>'foods/show.html.haml', :layout =>'application' 
  end

  def show
  # @favorites = current_user.favorite_foods
  # @food = FsFood.find(params[:id])['food']
  # if @food['servings']['serving'].class == Array
  #   if params[:meal] && params[:meal][:serving_id]
  #     @food['servings']['serving'].each do |serving|
  #       @serving = serving if serving["serving_id"] == params[:meal][:serving_id]
  #     end
  #   else
  #     @serving = @food['servings']['serving'].first
  #   end
  #   @servings = @food['servings']['serving'].collect{ |w|
  #     [w['serving_description'], w['serving_id']]
  #   }
  # else
  #   @serving = @food['servings']['serving']
  #   @servings = [[@food['servings']['serving']['serving_description'], @food['servings']['serving']['serving_id']]]
  # end
  # 
  #respond_to do |format|
  #  format.html
  #  format.js {
  #    render :update do |page|
  #      page.replace_html 'nutrition_facts', :partial => 'food', :object => @food, :include => {:serving => @serving}
  #    end
  #  }
  #end
  end

  def create
  end

  def quick_add
    favorite = FavoriteFood.find(params[:id])
    if favorite.food_items.first.meal_id
      @food = Meal.find(favorite.food_items.first.meal_id)
      @servings = [[@food.serving_description]]
      @display_name = @food.food_name
    else
      @food = Food.find(favorite.food_items.first.food_id)
      @display_name = @food.display_name
      @servings = []
      
      count = 0
      
      @food.servings.each do |s|
        @servings.push([s.description, count])
        count+=1
      end
    end

    render :layout => false
  end


  def food_details
    food = Food.find(params[:food_id])
    serving = food.servings[params[:serving_id].to_i]
    render :partial => '/foods/details', :layout => false, :object => {:food => food, :serving => serving}
  end

  def find_favorites
    @favorites = current_user.favorite_foods.find(:all, :include => :food_items)

    @favorite_ids = {}

    @favorites.each do |f|
      @favorite_ids[f.food_items[0].food_id] = f
    end
  end

end
