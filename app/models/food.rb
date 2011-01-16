class Food
  require 'sunspot'
  require 'sunspot_helper'
  
  include MongoMapper::Document
    
  key :name, String
  key :brand, String
  key :category, String
  
  many :servings
  
  Sunspot::Adapters::InstanceAdapter.register(SunspotHelper::InstanceAdapter, Food)
  Sunspot::Adapters::DataAccessor.register(SunspotHelper::DataAccessor, Food)
  
  Sunspot.setup(Food) do
    text :name, :boost => 2.0
    text :brand, :boost => 2.0
    text :category
  end
  
  def display_name
    "#{self.category}: #{self.name} by #{self.brand}"
  end
  
end