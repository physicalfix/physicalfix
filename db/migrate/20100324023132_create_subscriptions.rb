class CreateSubscriptions < ActiveRecord::Migration
  def self.up
     create_table :subscriptions do |t|
      t.references :user
      t.integer :chargify_id
      t.string :state, :product
      t.timestamps
    end
    
    User.all.each do |u|
      if u.has_role?('Free')
        Subscription.create(:user_id => u.id, :product => 'free', :state => 'active')
        u.remove_role('Free')                  
      elsif u.has_role?('Basic')               
        Subscription.create(:user_id => u.id, :product => 'basic', :state => 'active')
        u.remove_role('Basic')                 
      elsif u.has_role?('Premium')             
        Subscription.create(:user_id => u.id, :product => 'premium', :state => 'active')
        u.remove_role('Premium')
      end
    end
    
  end

  def self.down
    
    Subscription.all.each do |s|
      if s.product == Subscription::FREE_SUBSCRIPTION
        User.find(s.user_id).add_role('Free')
      elsif s.product == Subscription::BASIC_SUBSCRIPTION
        User.find(s.user_id).add_role('Basic')
      elsif s.product == Subscription::PREMIUM_SUBSCRIPTION
        User.find(s.user_id).add_role('Premium')
      end
    end
    
    drop_table :subscriptions
  end
end
