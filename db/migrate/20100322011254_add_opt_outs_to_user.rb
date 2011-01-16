class AddOptOutsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :reminder_emails, :boolean, :default => 1
    add_column :users, :promotional_emails, :boolean, :default => 1
  end

  def self.down
    remove_column :users, :promotional_emails
    remove_column :users, :reminder_emails
  end
end
