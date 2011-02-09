class User < ActiveRecord::Base
  has_many :workouts, :dependent => :destroy
  has_many :workout_sessions, :through => :workouts
  has_many :user_roles, :dependent => :destroy
  has_many :roles, :through => :user_roles
  has_many :user_weights, :dependent => :destroy
  has_many :meals, :dependent => :destroy
  has_many :user_activities, :dependent => :destroy
  has_many :activities, :through => :user_activities
  has_many :favorite_foods, :dependent => :destroy
  has_many :food_items, :dependent => :destroy
  has_many :favorite_activities, :dependent => :destroy
  has_one :subscription, :order => "created_at DESC"
  has_many :subscriptions, :dependent => :destroy
  belongs_to :user_bucket

  has_one :medical_history

  validates_format_of :password, :with => /^([\x20-\x7E]){4,16}$/,
                        :message => "must be 4 to 16 characters",
                        :unless => :password_is_not_being_updated?
                        
  validates_presence_of :first_name, :last_name, :email, :weight, :target_weight, :height, :birthday, :goals, :fitness_level
  validates_uniqueness_of :email, :case_sensitive => false
  validates_confirmation_of :password, :email, :on => :create
  
  validates_numericality_of :weight, :target_weight
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  validates_length_of :cell_phone, :within => 5..16, :if => Proc.new{|user| user.cell_phone && user.cell_phone.length > 0}
  validates_format_of :cell_phone, :with => /^[+\/\- () 0-9]+$/, :if => Proc.new{|user| user.cell_phone && user.cell_phone.length > 0}

  validates_length_of :home_phone, :within => 5..16, :if => Proc.new {|user| user.home_phone && user.home_phone.length > 0}
  validates_format_of :home_phone, :with => /^[+\/\- () 0-9]+$/, :if => Proc.new {|user| user.home_phone && user.home_phone.length > 0}
  
  validates_acceptance_of :terms
  
  attr_reader :password

  # TODO: move to notifier.rb?
  NAGS = {
    :login => "Our system shows that you haven't signed in to your profile page in {days} days.\nIf there is a problem with the sign up process please contact me immediately so I can rectify the problem and continue striving toward your fitness goals. It is consistency that can make or break a workout routine.",
    :workout => "Our system shows that you haven't completed a workout in {days} days.\nIf you feel as though these workouts are not perfect for you please contact me immediately so I can make the necessary changes to ensure you are satisfied.\nFollow this link to go directly to your workouts: {workout_link}",
    :weight => "Our system shows that you haven’t entered your weight in the past {days} days.\nKeeping track of your weight allows you to not only set realistic “soft” goals but to also visually see your progress.\nFollow this link to go directly to your weight tracker: {weight_link}",
    :food => "Our system shows that you haven’t recorded any food in your journal in {days} days.\nA recent study has proven that individuals that keep a food journal are twice as likely to lose weight!\nFollow this link to go directly to your food log: {food_link}",
    :activity => "Our system shows that you haven’t entered any activities in {days} days.\nConsistency is key in any exercise regimen and keeping track of the number of days you get in your workouts is an important motivational key!\nFollow this link to go directly to your activity log: {activity_link}"
  }

  # roles ==========================================================================================
  def has_role?(role)
    roles.count(:conditions => ['name = ?', role]) > 0
  end

  def roles_string
    user_roles.collect{ |ur| "#{ur.role.name},"}.to_s.chop
  end
  
  def add_role(role)
    return if has_role?(role)
    roles << Role.find_by_name(role)
  end
  
  def remove_role(role)
    return if !has_role?(role)
    r = Role.find_by_name(role)
    user_roles.find_all_by_role_id(r.id).each do |ur|
      ur.destroy
    end
  end

  #password ========================================================================================
  # if the password isn't being updated, don't run the validation
  def password_is_not_being_updated?
      self.id and !self.password
  end
  
  def password=(pw)
    @password = pw #used by confirmation validator
    unless password_is_not_being_updated?
      salt = [Array.new(6){rand(256).chr}.join].pack('m').chomp #2^48 combos
      self.password_salt, self.password_hash = salt, Digest::MD5.hexdigest(pw + salt)
    end
  end
  
  def password_is?(pw)
    Digest::MD5.hexdigest(pw + password_salt) == password_hash
  end

  # workouts =======================================================================================
  # A user needs workouts if they don't have three workouts for the coming week and they meet the
  # cutoff for receiving workouts for the coming week
  def needs_workouts?
    meets_cutoff = true
    if created_at > 7.days.ago
      meets_cutoff = created_at < (Time.zone.now.end_of_week - 24.hours)
    end
    !has_role?('Admin') &&
            subscription && subscription.product == Subscription::PREMIUM_SUBSCRIPTION &&
            !medical_history.nil? && meets_cutoff &&
            !has_all_workouts?
  end

  # A user has all workouts if they have three workouts for the coming week
  def has_all_workouts?
    week_start = (Time.zone.now + 1.week).beginning_of_week.to_date
    workouts.count(:conditions => ['week_of = ?', week_start.to_s(:db)]) >= 3
  end

  # Returns an array of all the users needing workouts for the coming week
  def self.users_needing_workouts
    users = User.all
    users.reject! do |user|
      !user.needs_workouts?
    end
    users
  end

  # A count of the users started workouts
  def started_workouts
    @started = 0
    workouts.each { |w|
      @started += w.workout_sessions.size
    }
    @started
  end

  # A count of the users completed workouts
  def completed_workouts
    @completed = 0
    workouts.each { |w|
      w.workout_sessions.each { |ws|
        @completed += 1 if ws.complete
      }
    }
    @completed
  end
  
  def generate_workouts
    # only basic users get generated workouts
    return false unless subscription && subscription.product == Subscription::BASIC_SUBSCRIPTION
    
    # prevent getting stuck in look by double checking the equipment in a user bucket
    return 'bad bucket' unless user_bucket.enough_equipment?(equipment)
    
    # workouts are generate on login for the current week
    week = Time.zone.now.beginning_of_week
    
    return if workouts.find_all_by_week_of(week.to_date).size >= user_bucket.workout_skeletons.size
    
    # loop through the skeletons and generate a workout for each one
    user_bucket.workout_skeletons.each do |skeleton|
      skeleton.generate_workout(self, week)
    end
    
  end
  
  # emails =========================================================================================
  
  # determines if a user will get a workout ready email
  def get_reminder?
    signed_up_over_a_week_ago = created_at < 7.days.ago
    signed_up_before_cutoff = (created_at > 7.days.ago && created_at < Time.zone.now.end_of_week - 24.hours)
    return (signed_up_over_a_week_ago ||
            signed_up_before_cutoff) &&
            subscription && subscription.product != Subscription::FREE_SUBSCRIPTION
  end


  # Sends out the workouts are ready emails to all users who have met the cutoff for that week
  # TODO: have this check to see if the user actually has all of their workouts?
  def self.send_reminders
    User.find(:all).each do |u|
        Notifier.deliver_reminder_email(u) if u.get_reminder?
    end
  end
  
  # trial =========================================================================================
  
  def self.check_expired_trials
    User.find(:all).each do |u|
      if u.trial_expired?
        u.downgrade_to_free
        Notifier.deliver_trial_expired_notification(u)
      end
    end
  end
  
  def downgrade_to_free
    subs = subscription
    subs.product = Subscription::FREE_SUBSCRIPTION
    subs.state = Subscription::ACTIVE_STATE
    subs.save
  end
  
  def trial_expired?
    subs = subscription
    return (subs &&
      subs.product == Subscription::BASIC_SUBSCRIPTION && 
      subs.state == Subscription::TRIAL_STATE &&
      subs.created_at < 14.days.ago)
  end

  # The number of days since the user has started a workout (used for nag emails)
  def days_since_last_workout
    if workout_sessions.size == 0
      return 0
    else
      return ((Time.zone.now - workout_sessions.last.updated_at)/1.day).to_i
    end
  end

  # The number of days since the user entered a weight (used for nag emails)
  def days_since_last_weight
    if user_weights.size == 0
      return 0
    else
      time_since_last_weight = ((Time.zone.now - user_weights.last.created_at)/1.day).to_i
      return time_since_last_weight
    end
  end

  # The number of days since the user entered a meal (used for nag emails)
  def days_since_last_meal
    if meals.size == 0
      return 0
    else
      time_since_last_meal = ((Time.zone.now - meals.last.created_at)/1.day).to_i
      return time_since_last_meal
    end
  end

  # The number of days since the user entered an activity (used for nag emails)
  def days_since_last_activity
    if activities.size == 0
      return 0
    else
      return ((Time.zone.now - activities.last.created_at)/1.day).to_i
    end
  end

  # The number of days since the user last logged in (used for nag emails)
  def days_since_last_login
    if last_logged_in_at
      return ((Time.zone.now - last_logged_in_at)/1.day).to_i
    else
      return 0
    end
  end
  
  # Sends out a progress email. A user will receive a generated progress email after 2 months of 
  # using the service
  def self.send_progress_email
    User.all.each do |user|
      Notifier.deliver_progress_email(user) if user.created_at.to_date == (Date.today - 2.months)
    end
  end

  # Sends out all nag emails. A user will receive a nag after three, six, and nine days. After nine
  # days they will cease to receive an email. If the user hasn't logged in, they will only get the
  # login nag, otherwise they will receive a digest of nags
  def self.send_nag_emails
    
    login_users = []
    workout_users = []
    weight_users = []
    meal_users = []
    activity_users = []
    
    User.all.each do |user|
      # skip if the user has no subscription type
      next if user.subscription_type.nil?
      next if user.reminder_emails == false
      
      if user.days_since_last_login > 0 && user.days_since_last_login % 3 == 0 && user.days_since_last_login <= 9
        # deliver nag email to user
        Notifier.deliver_login_nag_email(user, user.days_since_last_login)

        # if it's been 9 days add it to the digest
        if user.days_since_last_login == 9
         login_users << user
        end
        
        # don't worry about the rest of the nags. it's obvious if they haven't
        # logged in yet.
        next
        
      end
          
      nags = ""

      if user.subscription_type != Subscription::FREE_SUBSCRIPTION
        if user.days_since_last_workout > 0 && user.days_since_last_workout % 3 == 0 && user.days_since_last_workout <= 9
          nags += NAGS[:workout].gsub("{days}", user.days_since_last_workout.to_s) + "\n\n"
          if user.days_since_last_workout == 9
            workout_users << user
          end
        end
      end
      
      if user.days_since_last_weight > 0 && user.days_since_last_weight % 3 == 0 && user.days_since_last_weight <= 9
        nags += NAGS[:weight].gsub("{days}", user.days_since_last_weight.to_s) + "\n\n"
        if user.days_since_last_weight == 9
          weight_users << user
        end
      end
      
      if user.days_since_last_meal > 0 && user.days_since_last_meal  % 3 == 0 && user.days_since_last_meal <= 9
        nags += NAGS[:food].gsub("{days}", user.days_since_last_meal.to_s) + "\n\n"
        if user.days_since_last_meal == 9
          meal_users << user
        end
      end
      
      if user.days_since_last_activity > 0 && user.days_since_last_activity % 3 == 0 && user.days_since_last_activity <= 9
        nags += NAGS[:activity].gsub("{days}", user.days_since_last_activity.to_s) + "\n\n"
        if user.days_since_last_activity == 9
          activity_users << user
        end
      end
      
      if !nags.empty?
        Notifier.deliver_nag_email(user, nags)
      end  
    end
    
    if login_users.size > 0 || workout_users.size > 0 ||  weight_users.size > 0 || meal_users.size > 0 || activity_users.size > 0
      Notifier.deliver_nag_digest_email({
        :users_who_have_not_logged_in_for_nine_days => login_users, 
        :users_who_have_not_viewed_a_workout_in_nine_days => workout_users, 
        :users_who_have_not_entered_a_weight_in_nine_days => weight_users, 
        :users_who_have_not_entered_a_meal_in_nine_days => meal_users, 
        :users_who_have_not_entered_an_activity_in_nine_days => activity_users
      })
    end
    
    
  end

  # Sends out a welcome email based on the after_create filter
  # TODO: move to a background process
  # TODO: make HTML and pretty
  def send_signup_notification
    return unless subscription
    if subscription.product == Subscription::PREMIUM_SUBSCRIPTION
      Notifier.send_later(:deliver_premium_signup_notification, self)
    elsif subscription.product == Subscription::BASIC_SUBSCRIPTION && subscription.state == Subscription::ACTIVE_STATE
      Notifier.send_later(:deliver_basic_signup_notification, self)
    elsif subscription.product == Subscription::BASIC_SUBSCRIPTION && subscription.state == Subscription::TRIAL_STATE
      Notifier.send_later(:deliver_trial_signup_notification, self)
    elsif subscription.product == Subscription::FREE_SUBSCRIPTION
      Notifier.send_later(:deliver_free_signup_notification, self)
    end
  end

  # weight =========================================================================================
  # The current weight of the user based on the last user_weight entered for that user
  def current_weight
    return weight if user_weights.length == 0
    return user_weights.last.weight
  end

  # The amount of weight gained or lost for a given date. This is based on the number of calories
  # ingested minus the number of calories burned divided by 3500. 3500 calories burned should be
  # about one pound weight loss
  def weight_balance(date = Time.zone.now)
    return calorie_balance(date) / 3500
  end

  # The average amount of weight gained or lost over a given range based on calorie balance alone
  def average_weight_balance(range = 1.week.ago.to_date..Time.zone.now.to_date)
    return average_calorie_balance(range) / 3500
  end

  # Returns a hash of weight stats that tell how much weight was gained or lost over the month, year
  # month or all time
  def weight_stats
    if user_weights.size > 0
      curr_weight = user_weights.find(:all, :order => 'user_weights.created_at DESC', :limit => 1)[0].weight

      wya = user_weights.find(:all, :conditions => ["user_weights.created_at > ?", 1.year.ago], :order => 'user_weights.created_at ASC', :limit =>1)
      weight_year_ago = wya.size > 0 ? wya[0].weight : weight

      wma = user_weights.find(:all, :conditions => ["user_weights.created_at > ?", 1.month.ago], :order => 'user_weights.created_at ASC', :limit =>1)
      weight_month_ago = wma.size > 0 ? wma[0].weight : weight
    else
      curr_weight = weight_year_ago = weight_month_ago = weight
    end
    {
      :all => {
        :lbs => (curr_weight - weight),
        :percent =>  sprintf("%.2f",((curr_weight.to_f - weight.to_f)/weight.to_f)*100)
      },
      :ytd => {
        :lbs => (curr_weight - weight_year_ago),
        :percent => sprintf("%.2f",((curr_weight.to_f - weight_year_ago.to_f)/ weight_year_ago.to_f)*100)
      },
      :mtd => {
        :lbs => (curr_weight - weight_month_ago),
        :percent => sprintf("%.2f",((curr_weight.to_f - weight_month_ago.to_f)/weight_month_ago.to_f)*100)
      }
    }
  end

  # Returns a hash of weights and body pictures formatted for a google annotated timeline
  def weight_graph
    if user_weights.size > 0
      start_day = [1.month.ago.to_date, created_at.to_date].min

      uw = user_weights.group_by{|w| w.created_at.to_date}

      weights = Hash.new
      images = Hash.new

      last_weight = weight
      (start_day..Time.zone.now.to_date).sort.each do |d|
        if uw[d] == nil
          weights[d] = {:weight => last_weight}
        elsif uw[d]
          weights[d] = {:weight => uw[d][0].weight}
          images[d] = ['Picture Update', "<a href='#{weight_tracker_path(uw[d][0])}' id='#{d}'><img src='#{uw[d][0].weight_image.url(:thumb)}' /></a>"] if !uw[d][0].weight_image.path.nil?
          last_weight = uw[d][0].weight
        end

      end

      days = 1
      awb = average_weight_balance
      (Time.zone.now.to_date..Time.zone.now.to_date+1.week).each do |d|
        fw = {:forecasted_weight => last_weight + (awb * days)}
        if weights[d]
          weights[d].merge!(fw)
        else
          weights[d] = fw
        end

        days += 1
      end

      { :weights => weights, :images => images}
    else
      { :weights => {}, :images => {} }
    end
  end

  # nutrition ======================================================================================
  # The amount of calories ingested minus the amount of calories burned for a given day
  def calorie_balance(date = Time.zone.now.to_date)
    ci = calorie_intake(date)
    ce = calorie_expenditure(date)
    return 0 if !ci || !ce
    return ci - ce
  end

  # The average calorie balance for a given date range
  def average_calorie_balance(range = 1.week.ago.to_date..Time.zone.now.to_date)
    acb = 0
    count = 0
    range.each do |date|
      cb = calorie_balance(date)
      if cb
        acb += cb
        count += 1
      end
    end
    return acb / count if count > 0
    return 0
  end

  # The number of calories ingested for a given date based on meals entered
  def calorie_intake(date = Time.zone.now.to_date)
    date = Time.zone.parse(date.to_s)
    m = meals.find(:all, :conditions => ['eaten_at BETWEEN ? and ?', date.beginning_of_day.utc, date.end_of_day.utc])
    return m.inject(0){|s,meal| s += meal.calories}
  end

  # The number of calories burned for a given date based on user activites and tdee
  def calorie_expenditure(date = Time.zone.now.to_date)
    date = Time.zone.parse(date.to_s)
    a = user_activities.find(:all, :conditions => ['activity_date BETWEEN ? and ?', date.beginning_of_day.utc, date.end_of_day.utc])
    return a.inject(0) { |s,activity| s += activity.calories }
  end

  # Sets the tdee for a user for a given date. Only one tdee can be set per day
  def set_tdee(date = Time.now)
    tdee_today = user_activities.find_by_name('Daily Energy Expenditure', :conditions => ['activity_date = ?', Time.now.beginning_of_day.utc])
    
    if !tdee_today && calorie_intake > 0
      UserActivity.create(:user_id => id, :name => 'Daily Energy Expenditure', :activity_date => Time.now.beginning_of_day, :calories_burned => tdee, :duration => 0)
    end
    
  end

  # Calculated the tdee for a given user
  def tdee
    return 0 unless current_weight

    fitness = fitness_level
    if fitness == 'Poor'
      fitness_multiplier = 1.3
    elsif fitness == 'Good-Fair'
      fitness_multiplier = 1.4
    else
      fitness_multiplier = 1.5
    end

    if sex == 'Male'
      return (66 + (6.3 * current_weight) + (12.9 * height_inches) - (6.8 * ((Time.zone.now.to_date - birthday).days/1.year).floor)) * fitness_multiplier
    else
      return (655 + (4.3 * current_weight) + (4.7 * height_inches) - (4.7 * ((Time.zone.now.to_date - birthday).days/1.year).floor)) * fitness_multiplier
    end
  end

  # Calculates the amount of calories a person should eat. A calorie restricted diet is give to
  # people trying to lose weight
  def daily_calorie_allotment
    #give the user a restricted calorie allotment if the user is trying to lose weight
    if self.target_weight < self.weight
      tdee - 650
    else
      tdee
    end
  end

  # The amount of fat a person should eat based on their calorie allotment
  def daily_fat_allotment
    self.daily_calorie_allotment *  0.0325
  end

  # The amount of carbohydrates a person should eat based on their calorie allotment
  def daily_carbohydrate_allotment
    self.daily_calorie_allotment * 0.15
  end

  # The amount of protein a person should eat based on their calorie allotment
  def daily_protein_allotment
    self.daily_calorie_allotment * 0.025
  end

  # static functions ===============================================================================
  # The number of users that signed up this month
  def self.new_users_month_count
    User.count(:conditions => ['created_at > ?', 1.month.ago])
  end

  # Formatted data of users that signed up this month for a sparkline
  def self.new_users_month
    start_date = Time.zone.now.to_date - 1.month
    user_counts = User.count(:group => 'DATE(created_at)', :conditions => ['created_at >= ?', start_date.to_s(:db)])
    result = Array.new

    (start_date..Time.zone.now.to_date).each do |d|
      user_counts.each do |uc|
        result.push uc[1] if uc[0] == d.to_s
        break
      end
      result.push 0
    end

    result
  end

  # misc ===========================================================================================
  # returns true if the users has a food as one of their favorites otherwise return false
  def has_favorite_food?(food_id)
    if fi = food_items.find_by_food_id(food_id)
      return fi.favorite_food_id
    else
      return nil
    end
  end

  # The user's height in inches
  def height_inches
    parts = height.split("'")
    return (parts[0].to_i * 12) + (parts[1].chop.to_i)
  end

  # The user's full name
  def full_name
    return "#{first_name} #{last_name}"
  end

end
