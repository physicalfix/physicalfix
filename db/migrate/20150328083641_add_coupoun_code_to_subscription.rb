class AddCoupounCodeToSubscription < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :coupon_code, :string
  end

  def self.down
    remove_column :subscriptions, :coupon_code, :string
  end
end
