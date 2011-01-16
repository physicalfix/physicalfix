require File.dirname(__FILE__) + '/../spec_helper'

describe Meal do
  fixtures :users
  before(:each) do
    #@meal = meals(:yummy_meal)
  end

  
  it "should set user tdee on create" do
    @user = users(:valid_user)
    @meal = Meal.new(:user_id => @user.id,
                     :servings => 3,
                     :food_name => 'some food',
                     :serving_description => 'lots',
                     :calories => 5,
                     :carbohydrate => 5,
                     :protein => 6,
                     :fat => 8,
                     :sugar => 12)
    @meal.should_receive(:set_tdee)
    @meal.save
  end
  

end

