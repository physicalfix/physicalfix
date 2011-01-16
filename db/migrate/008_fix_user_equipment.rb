class FixUserEquipment < ActiveRecord::Migration
  def self.up
    change_column :users, :equipment, :text
  end

  def self.down
    change_column :users, :equipment, :string
  end
end
