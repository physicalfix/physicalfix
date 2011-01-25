class Chargify::Subscription < Chargify::Base
  def migrate(attrs = {})
    post :migrations, attrs
  end
end

class Subscription < ActiveRecord::Base
  belongs_to :user

  #########################
  ## Product Family: Free
  #########################
  FREE_SUBSCRIPTION = 'free'

  ########################
  ## Product Family: Basic
  ########################
  BASIC_FREE_SUBSCRIPTION = 'basic-free'
  BASIC_14_TRIAL_SUBSCRIPTION = 'basic-14-trial'
  BASIC_30_TRIAL_SUBSCRIPTION = 'basic-30-trial'
  BASIC_STANDARD_SUBSCRIPTION = 'basic-standard'

  ###########################
  ## Product Family: Premium
  ###########################
  PREMIUM_FREE_SUBSCRIPTION = 'premium-free'
  PREMIUM_30_TRIAL_SUBSCRIPTION = 'premium-30-trial'
  PREMIUM_STANDARD_SUBSCRIPTION = 'premium-standard'

  ###########################
  ## Valid Plans
  ###########################

  VALID_FREE_OR_TRIAL_PLANS =
  [
    FREE_SUBSCRIPTION,
    BASIC_14_TRIAL_SUBSCRIPTION,
    BASIC_30_TRIAL_SUBSCRIPTION,
    PREMIUM_30_TRIAL_SUBSCRIPTION
  ]

  VALID_14_TRIAL_PLANS =
  [
    BASIC_14_TRIAL_SUBSCRIPTION
  ]

  VALID_30_TRIAL_PLANS =
  [
    BASIC_30_TRIAL_SUBSCRIPTION,
    PREMIUM_30_TRIAL_SUBSCRIPTION
  ]

  VALID_TRIAL_PLANS =
  [
    BASIC_14_TRIAL_SUBSCRIPTION,
    BASIC_30_TRIAL_SUBSCRIPTION,
    PREMIUM_30_TRIAL_SUBSCRIPTION
  ]

  VALID_PAID_PLANS =
  [
    BASIC_STANDARD_SUBSCRIPTION,
    PREMIUM_STANDARD_SUBSCRIPTION
  ]

  VALID_FREEBY_PLANS =
  [
    BASIC_FREE_SUBSCRIPTION,
    BASIC_30_TRIAL_SUBSCRIPTION,
    PREMIUM_FREE_SUBSCRIPTION,
    PREMIUM_30_TRIAL_SUBSCRIPTION
  ]

  VALID_BASIC_PLANS =
  [
    BASIC_FREE_SUBSCRIPTION,
    BASIC_14_TRIAL_SUBSCRIPTION,
    BASIC_30_TRIAL_SUBSCRIPTION,
    BASIC_STANDARD_SUBSCRIPTION
  ]

  VALID_PREMIUM_PLANS =
  [
    PREMIUM_FREE_SUBSCRIPTION,
    PREMIUM_30_TRIAL_SUBSCRIPTION,
    PREMIUM_STANDARD_SUBSCRIPTION
  ]

  LIVE_STATES = ['trialing', 'assessing', 'active']
  PROBLEM_STATES = ['soft_failure', 'past_due']
  EOL_STATES = ['canceled', 'expired', 'suspended']

  #######################################
  ## Creating and Checking Susbcriptions
  #######################################

  def self.create_subscription(user, product, credit_card)
    if credit_card
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
      })
    else
      Chargify::Subscription.create(
        :product_handle => product,
        :customer_attributes => {
          :first_name => user.first_name,
          :last_name => user.last_name,
          :email => user.email,
          :reference => user.id
      })
    end
  end

  # Not precisely sure what this one does...
  def self.check_subscription(sub_id)
    begin
      subscription = Chargify::Subscription.find(sub_id)
      state = subscription.state
      product = subscription.product.handle
      # Downgrade the subscription if it's at the end of its life.
      if end_of_life?(state)
        product = FREE_SUBSCRIPTION
      end
      Subscription.create(
        :user_id => subscription.customer.reference,
        :state => state,
        :product => product,
      :chargify_id => subscription.id)
    rescue ActiveResource::ResourceNotFound
      # Do something here...
    end
  end

  #############################
  ## Subscription Type Helpers
  #############################

  def self.free?(product)
    FREE_SUBSCRIPTION == product
  end

  def self.free_or_trial?(product)
    VALID_FREE_OR_TRIAL_PLANS.include?(product)
  end

  def self.freeby?(product)
    VALID_FREEBY_PLANS.include?(product)
  end

  def self.basic?(product)
    VALID_BASIC_PLANS.include?(product)
  end

  def self.premium?(product)
    VALID_PREMIUM_PLANS.include?(product)
  end

  def self.paid?(product)
    VALID_PAID_PLANS.include?(product)
  end

  def self.day_14_trial?(product)
    VALID_14_TRIAL_PLANS.include?(product)
  end

  def self.day_30_trial?(product)
    VALID_30_TRIAL_PLANS.include?(product)
  end

  ##############################
  ## Other Subscription Actions
  ##############################

  def self.get_num_premiums
    User.all.count { |u|
      u.subscription &&
    Subscription.premium?(u.subscription.product) }
  end

  ################################
  ## Subscription Problem Helpers
  ################################

  def self.end_of_life?(state)
    EOL_STATES.include?(state)
  end

  def cc_problem?
    PROBLEM_STATES.include?(state)
  end

  def trial_expired?
    if VALID_TRIAL_PLANS.include?(product) && end_of_life?(state)
      unsubscribe
    else
      # Not a valid trial; not sure what to do here.
    end
  end

  ################################
  ## Subscription Change Methods
  ################################

  # Used to upgrade I believe.
  # TODO: might have to make some changes to this...
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

  # Unsubscribing gives a user a free subscription
  # TODO: might have to make some changes to this...
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
      Subscription.create(:user_id => user.id, :product => FREE_SUBSCRIPTION)
    end
  end

end
