class AddTrialperiodToSubscription < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :trial_period, :string
    Subscription.find(:all).each do |s|
      if (s.product == Subscription::BASIC_SUBSCRIPTION && s.state == Subscription::TRIAL_STATE )
        s.update_attribute("trial_period","14 days")
      end
    end

  end

  def self.down
    remove_column :subscriptions, :trial_period, :string
  end
end
