class AddTrialperiodToSubscription < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :trial_period, :string, :default => "14 days"
  end

  def self.down
    remove_column :subscriptions, :trial_period, :string, :default => "14 days"
  end
end
