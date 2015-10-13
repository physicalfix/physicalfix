class Chargify::Subscription < Chargify::Base
  def migrate(attrs = {})
    post :migrations, attrs
  end
end

class Subscription < ActiveRecord::Base
  belongs_to :user
  
  FREE_SUBSCRIPTION = 'free'
  BASIC_SUBSCRIPTION = 'basic'
  PREMIUM_SUBSCRIPTION = 'premium'
  TRIAL_SUBSCRIPTION = 'trial'
  
  ##
  ## Start: Free 14-Day Trial Modifications
  ##
  TRIAL_STATE = 'trialing'
  ACTIVE_STATE = 'active'
  ##
  ## End: Free 14-Day Trial Modifications
  ##
  
  LIVE_STATES = ['trialing','assessing','active']
  PROBLEM_STATES = ['soft_failure','past_due']
  EOL_STATES = ['canceled','expired','suspended']
  
  def self.create_subscription(user, product, credit_card,coupon_code="")
    puts("=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
    puts(user.inspect)
    puts "-----------#{user.id}--#{self.get_next_billing_date(user.subscription)}-------------"
    
    Chargify::Subscription.create(
      :product_handle => product,
      :customer_attributes => {
        :first_name => user.first_name,
        :last_name => user.last_name,
        :email => user.email,
        :reference => user.id
      },
      :credit_card_attributes => {
        :first_name => credit_card.first_name,
        :last_name => credit_card.last_name,
        :expiration_month => credit_card.expiration.month,
        :expiration_year => credit_card.expiration.year,
        :full_number => credit_card.card_number,
        :cvv => credit_card.cvv 
      },
      :next_billing_at => self.get_next_billing_date(user.subscription),
      :coupon_code => coupon_code
    )
  end
  
  def self.get_next_billing_date(subscription)
    puts("------------------------")
    puts(subscription)
    puts "==get_next_billing_date===================="
    billing_date = Date.today
    if (subscription.present?)
      if (subscription.product == Subscription::BASIC_SUBSCRIPTION && subscription.state == Subscription::TRIAL_STATE)
        if subscription.trial_period == "14 days"
          remaning_days = (Date.today - subscription.created_at.to_date).to_i
          if remaning_days <= 14
            billing_date = (14 - remaning_days).days.from_now
          end        
        elsif subscription.trial_period == "1 month"
          remaning_days = (Date.today - subscription.created_at.to_date).to_i
          if remaning_days <= 30
            billing_date = (30 - remaning_days).days.from_now
          end        
        end
      end
    else
      billing_date = (30).days.from_now  
    end
    puts "==get_next_billing_date=========#{billing_date}==========="
    billing_date
  end
  
  def migrate(product)
    product_handle = "#{product}-subscription"
    chargify_subscription = Chargify::Subscription.find(chargify_id)    
    
    Subscription.transaction do

      unless product == FREE_SUBSCRIPTION
        chargify_subscription.migrate(:product_handle => product_handle)
      else
        chargify_subscription.cancel
      end
      
      sub = Subscription.new
      sub.user_id = user.id
      sub.state = product == FREE_SUBSCRIPTION ? nil : chargify_subscription.state
      sub.product = product
      sub.chargify_id = product == FREE_SUBSCRIPTION ? nil : chargify_subscription.id
      sub.save
      
    end
    self
  end

  def self.check_subscription(sub_id)
    begin
      subscription = Chargify::Subscription.find(sub_id)

      state = subscription.state
    
      product = subscription.product.handle.split('-')[0]
    
      # downgrade the subscription if it's at the end of it's life
      if EOL_STATES.include?(state)
        product = FREE_SUBSCRIPTION
      end
        
      Subscription.create(  :user_id => subscription.customer.reference,
                            :state => state, 
                            :product => product, 
                            :chargify_id => subscription.id)
    rescue ActiveResource::ResourceNotFound
    end
  end
  
  def unsubscribe
    return unless chargify_id
    
    begin
      sub = Chargify::Subscription.find(chargify_id)
    rescue ActiveResource::ResourceNotFound
    end
    
    Subscription.transaction do 
      
      if sub
        sub.cancel
        sub.reload
      end
      
      Subscription.create(
        :user_id => user.id, 
        :product => FREE_SUBSCRIPTION
      )
    end
    
  end
  
  def self.paid_subscription(type)
    if type == BASIC_SUBSCRIPTION
      return true
    elsif type == PREMIUM_SUBSCRIPTION
      return true
    end
    return false
  end
end
