class AddFitnessLevelToUser < ActiveRecord::Migration

  class User < ActiveRecord::Base
    has_one :medical_history
  end

  class MedicalHistory < ActiveRecord::Base
    belongs_to :user
  end
  
  def self.up
    add_column :users, :fitness_level, :string
    
    #migrate the fitness level from the medical history
    MedicalHistory.all.each do |mh|
      mh.user.update_attribute(:fitness_level, mh.fitness) if mh.user && mh.fitness
    end

  end

  def self.down
    remove_column :users, :fitness_level
  end
end
