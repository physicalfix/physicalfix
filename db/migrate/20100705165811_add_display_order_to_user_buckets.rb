class AddDisplayOrderToUserBuckets < ActiveRecord::Migration
  def self.up
    add_column :user_buckets, :display_order, :integer
  end

  def self.down
    remove_column :user_buckets, :display_order
  end
end
