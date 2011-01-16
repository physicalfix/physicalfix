class CreateUserBuckets < ActiveRecord::Migration
  def self.up
    create_table :user_buckets do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
  end

  def self.down
    drop_table :user_buckets
  end
end
