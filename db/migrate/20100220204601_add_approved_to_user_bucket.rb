class AddApprovedToUserBucket < ActiveRecord::Migration
  def self.up
    add_column :user_buckets, :approved, :boolean, :default => false
  end

  def self.down
    remove_column :user_buckets, :approved
  end
end
