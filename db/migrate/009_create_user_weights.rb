class CreateUserWeights < ActiveRecord::Migration
  def self.up
    create_table :user_weights do |t|
      t.integer :user_id, :weight, :weight_image_file_size
      t.string  :weight_image_file_name,  :weight_image_content_type
      t.datetime :weight_image_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :user_weights
  end
end
