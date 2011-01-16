class AddUserBucketIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :user_bucket_id, :integer
  end

  def self.down
    remove_column :users, :user_bucket_id
  end
end
