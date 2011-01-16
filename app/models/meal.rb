class Meal < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :food_name

  validates_presence_of :serving_description

  validates_numericality_of :calories

  validates_numericality_of :carbohydrate

  validates_numericality_of :protein

  validates_numericality_of :fat

  validates_numericality_of :sugar

  validates_numericality_of :saturated_fat, :if => Proc.new{|meal| meal.saturated_fat}
  validates_numericality_of :polyunsaturated_fat, :if => Proc.new{|meal| meal.polyunsaturated_fat}
  validates_numericality_of :monosaturated_fat, :if => Proc.new{|meal| meal.monosaturated_fat}
  validates_numericality_of :trans_fat, :if => Proc.new{|meal| meal.trans_fat}
  validates_numericality_of :cholesterol, :if => Proc.new{|meal| meal.cholesterol}
  validates_numericality_of :sodium, :if => Proc.new{|meal| meal.sodium}
  validates_numericality_of :potassium, :if => Proc.new{|meal| meal.potassium}
  validates_numericality_of :fiber, :if => Proc.new{|meal| meal.fiber}
  validates_numericality_of :vitamin_a, :if => Proc.new{|meal| meal.vitamin_a}
  validates_numericality_of :vitamin_c, :if => Proc.new{|meal| meal.vitamin_c}
  validates_numericality_of :calcium, :if => Proc.new{|meal| meal.calcium}
  validates_numericality_of :iron, :if => Proc.new{|meal| meal.iron}

  validates_numericality_of :servings

  validates_associated :user

  after_create :set_tdee

  def total_calories
    return 0.0 if !self.calories
    self.calories * self.servings
  end

  def total_carbohydrate
    return 0.0 if !self.carbohydrate
    self.carbohydrate * self.servings
  end

  def total_fat
    return 0.0 if !self.fat
    self.fat * self.servings
  end

  def total_protein
    return 0.0 if !self.protein
    self.protein * self.servings
  end

  def total_sugar
    return 0.0 if !self.sugar
    self.sugar * self.servings
  end

  def set_tdee
    user.set_tdee
  end

end
