class CreateFavoriteFoods < ActiveRecord::Migration
  def self.up
    create_table :favorite_foods do |t|
      t.references :user
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :favorite_foods
  end
end
