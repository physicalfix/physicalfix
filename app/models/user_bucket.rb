class UserBucket < ActiveRecord::Base
  has_many :users
  has_many :user_bucket_exercises
  has_many :exercises, :through => :user_bucket_exercises
  has_many :workout_skeletons
  validates_presence_of :name
  validates_presence_of :description
  
  named_scope :approved, :conditions => 'approved = true', :order => 'display_order'
  
  def enough_equipment?(equipment)
    workout_skeletons.all? do |ws|
      ws.enough_equipment?(equipment)
    end
  end
  
  def needed_equipment(equipment)
    re = []
    has_db = equipment.include?('Dumbbell')
    has_band = equipment.include?('Band')
    
    enough_band = true
    enough_dumbbells = true
    enough_both = true
    
    workout_skeletons.each do |ws|
      enough_band = enough_band && ws.enough_equipment?('Band')
      enough_dumbbells = enough_dumbbells && ws.enough_equipment?('Dumbbell')
      enough_both = enough_both && ws.enough_equipment?('Band|Dumbbell')
    end
    
    if has_db && !has_band
      re.push('Exercise Band') if (enough_band || enough_both) && !enough_dumbbells 
    elsif has_band && !has_db
      re.push('Dumbbells') if (enough_dumbbells || enough_both) && !enough_band
    elsif !has_band && ! has_db
      re.push('Dumbbells') if enough_dumbbells && !enough_band && !enough_both
      re.push('Exercise Band') if enough_band && !enough_dumbbells && !enough_both
      re.push('Exercise Band or Dumbbells') if enough_band && enough_dumbbells && enough_both 
      re.push('Exercise Band and Dumbbells') if enough_both && !enough_band && !enough_dumbbells
    end
    return re.uniq
  end
  
end
