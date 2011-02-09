require File.dirname(__FILE__) + '/../spec_helper'


describe User do
  describe "A new user" do
    fixtures :users, :roles, :user_roles, :subscriptions

    before(:each) do
      #create valid user
      @user = User.new(valid_new_user)
    end
    
    def valid_new_user
      {:first_name => 'Adam',
        :last_name => 'Podolnick',
        :email => 'podman@example.com',
        :cell_phone => '5555555555',
        :weight => 140,
        :target_weight => 160,
        :height => "5'11\"",
        :birthday => Time.zone.now.to_date,
        :goals => 'hi!',
        :password => 'mypassword',
        :fitness_level => 'Good-Fair'}
    end

    it "should validate email format" do
      %w( good@example.com good+you@example.com good_you@example.com
          pizza@some.org.gov pizza@my.school.edu good@play.org ).each do |email|
        @user.email = email
        @user.should have(:no).error_on(:email)
      end

      ["bad example.com", "me", "@here.com", ".com", "you@here@yay.com",
       "pizza@...com"].each do |email|
        @user.email = email
        @user.should have(1).error_on(:email)
      end
    end

    it "should be valid" do
      @user.should be_valid
    end

    it "should validate uniqueness of email" do
      other = users(:valid_user)
      @user.email = other.email
      @user.should have(1).error_on(:email)
      @user.email = other.email.upcase
      @user.should have(1).error_on(:email)
    end

    it "should have no started workouts" do
      @user.started_workouts.should be_zero
    end

    it "should have no completed workouts" do
      @user.completed_workouts.should be_zero
    end

  end

  describe "An existing user" do
    fixtures :user_buckets, :workout_skeletons, :exercises, :user_bucket_exercises, :musclegroups, :workout_skeleton_musclegroups, :users, :roles, :user_roles, :workouts, :workout_sessions, :user_weights, :medical_histories, :meals, :subscriptions

    before(:each) do
      @user = users(:valid_user)
    end

    it "should send a premium signup notification if the user is a premium user" do
      @user.stub!(:subscription).and_return(mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION))
      Notifier.should_receive(:send_later).with(:deliver_premium_signup_notification, @user)
      @user.send_signup_notification
    end
    it "should send a basic signup notification if the user is a basic user" do
      @user.stub!(:subscription).and_return(mock_model(Subscription, :product => Subscription::BASIC_SUBSCRIPTION))
      Notifier.should_receive(:send_later).with(:deliver_basic_signup_notification, @user)
      @user.send_signup_notification
    end
    it "should send a free signup notification if the user is a free user" do
      @user.stub!(:subscription).and_return(mock_model(Subscription, :product => Subscription::FREE_SUBSCRIPTION))
      Notifier.should_receive(:send_later).with(:deliver_free_signup_notification, @user)
      @user.send_signup_notification
    end
    it "should match valid password" do
      @user.password_is?("testtest").should be_true
    end

    it "should not match invalid password" do
      @user.password_is?("bad password").should be_false
    end

    it "should not have roles" do
      @user.has_role?('foo').should be_false
    end

    it "should have an empty roles_string" do
      @user.roles_string.should be_empty
    end

    it "should add new roles" do
      role = roles(:admin_role)
      @user.add_role(role.name)
      @user.has_role?(role.name).should be_true
    end
    
    it "should remove roles" do
      role = roles(:admin_role)
      @user.add_role(role.name)
      @user.has_role?(role.name).should be_true
      @user.remove_role(role.name)
      @user.has_role?(role.name).should be_false
    end

    it "should have started workouts" do
      @user.workouts.size.should == 3
      @user.started_workouts.should == 2
    end

    it "should have completed workouts" do
      @user.completed_workouts.should == 1
    end

    it "should have weight stats" do
      @user.weight_stats.should == {
        :all => {:lbs => 5,:percent => "3.57"},
        :ytd => {:lbs => 0,:percent => "0.00"},
        :mtd => {:lbs => 0,:percent => "0.00"}
      }
    end

    it "should have empty weight stats" do
      @user = users(:user_without_workouts)
      @user.weight_stats.should == {
        :mtd=>{:lbs=>0, :percent=>"0.00"},
        :all=>{:lbs=>0, :percent=>"0.00"},
        :ytd=>{:lbs=>0, :percent=>"0.00"}
        }
    end

    it "should have weight graph" do
      @uw = mock_model(UserWeight, :weight => 145, :created_at => Time.zone.now.to_date - 6.days, :weight_image => mock('weight_image', :path => nil))
      @user.stub!(:user_weights).and_return([@uw])
      @user.weight_graph.should == {
        :images => {},
        :weights => generate_weights
      }
    end

    it "should have empty weight graph" do
      @user = users(:user_without_workouts)
      @user.weight_graph.should == {
        :images => {},
        :weights => {}
      }
    end

    it "should have a current_weight" do
      @user.current_weight.should == 145
    end
    
    it "should have a height in inches" do
      @user.height_inches.should == 71
    end

    it "should have all workouts" do
      3.times do
        Workout.create(:user_id => @user.id, :week_of => (Time.zone.now.beginning_of_week + 1.week).to_date)
      end
      @user.has_all_workouts?.should be_true
    end

    it "should not need a workout if the user is an admin" do
      @user.stub!(:has_role?).with('Admin').and_return(true)
      @user.needs_workouts?.should be_false
    end

    it "should not need a workout if the user doesn't have a medical history" do
      @user.stub!(:subscription).and_return(mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION))
      @user.stub!(:medical_history).and_return(nil)
      @user.needs_workouts?.should be_false
    end

    it "should not need a workout if the user didn't meet the cutoff" do
      @user.stub!(:subscription).and_return(mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION))
      @user.stub!(:created_at).and_return(Time.zone.now.end_of_week - 12.hours)
      @user.needs_workouts?.should be_false
    end

    it "should not need a workout if the user has all workouts for the week" do
      @user.stub!(:subscription).and_return(mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION))
      @user.stub!(:has_all_workouts?).and_return(true)
      @user.needs_workouts?.should be_false
    end

    it "should need workouts if the use met the cutoff but doesn't have all workouts and is premium" do
      @user.stub!(:created_at).and_return(Time.zone.now.end_of_week - 1.year)
      @user.stub!(:has_all_workouts?).and_return(false)
      @user.stub!(:has_role?).with('Admin').and_return(false)
      @user.stub!(:subscription).and_return(mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION))
      @user.needs_workouts?.should be_true
    end

    it "should return a tdee" do
      @medical_history = mock_model(MedicalHistory, :fitness => 'Good-Fair')
      @user.stub!(:medical_history).and_return(@medical_history)
      @user.stub!(:current_weight).and_return(200)
      @user.stub!(:height_inches).and_return(72)
      @user.stub!(:birthday).and_return(Time.zone.now.to_date - 25.years - 183.days)
      @user.tdee.should be_close(2918.72, 0.001)
    end
    
    it "should return a different tdee for females" do
      @user.stub!(:sex).and_return("Female")
      @medical_history = mock_model(MedicalHistory, :fitness => 'Good-Fair')
      @user.stub!(:medical_history).and_return(@medical_history)
      @user.stub!(:current_weight).and_return(200)
      @user.stub!(:height_inches).and_return(72)
      @user.stub!(:birthday).and_return(Time.zone.now.to_date - 25.years - 183.days)
      @user.tdee.should be_close(2430.26, 0.001)
    end

    it "should have a different tddee for excellent fitness" do
      @user.stub!(:fitness_level).and_return('Excellent')
      @user.stub!(:current_weight).and_return(200)
      @user.stub!(:height_inches).and_return(72)
      @user.stub!(:birthday).and_return(Time.zone.now.to_date - 25.years - 183.days)
      @user.tdee.should be_close(3127.2, 0.001)
    end
    
    it "should have a different tddee for poor fitness" do
      @user.stub!(:fitness_level).and_return('Poor')
      @user.stub!(:current_weight).and_return(200)
      @user.stub!(:height_inches).and_return(72)
      @user.stub!(:birthday).and_return(Time.zone.now.to_date - 25.years - 183.days)
      @user.tdee.should be_close(2710.24, 0.001)
    end
    
    it "should set_tdee if it doesn't have one for today" do
      UserActivity.stub!(:find_by_name).and_return(nil)
      @user.stub!(:calorie_intake).and_return(123)
      UserActivity.should_receive(:create)
      @user.set_tdee
    end
    
    it "should not set_tdee if it does have one for today" do
      UserActivity.stub!(:find_by_name).and_return([])
      UserActivity.should_not_receive(:create)
      @user.set_tdee
    end
    
    it "should return a calorie restricted daily_calorie_allotment if the user is trying to lose weight" do
      @user.stub!(:target_weight).and_return(100)
      @user.stub!(:weight).and_return(200)
      @user.stub!(:tdee).and_return(1000)
      @user.daily_calorie_allotment.should == (1000-650)
    end
    
    it "should return the raw tdee for daily_calorie_allotment if the user isn't trying to lose weight" do
      @user.stub!(:target_weight).and_return(200)
      @user.stub!(:weight).and_return(100)
      @user.stub!(:tdee).and_return(1000)
      @user.daily_calorie_allotment.should == 1000
    end
    
    it "should return calculate the proper daily_fat_allotment" do
      @user.stub!(:daily_calorie_allotment).and_return(1000)
      @user.daily_fat_allotment.should be_close(1000*0.0325, 0.0001)
    end
    
    it "should return calculate the proper daily_carbohydrate_allotment" do
      @user.stub!(:daily_calorie_allotment).and_return(1000)
      @user.daily_carbohydrate_allotment.should be_close(1000*0.15, 0.0001)
    end
    
    it "should calculate the proper daily_protein_allotment" do
      @user.stub!(:daily_calorie_allotment).and_return(1000)
      @user.daily_protein_allotment.should be_close(1000*0.025, 0.0001)
    end

    it "should return a weight balance for a date" do
      @user.weight_balance.should == 0
    end

    it "should have days since last workout if there are workout sessions" do
      @ws = mock_model(WorkoutSession, :updated_at => Time.zone.now - 144.hours)
      @user.stub!(:workout_sessions).and_return([@ws])
      @user.days_since_last_workout.should == 6
    end

    it "should return 0 for days since last workout if there aren't any workout sessions" do
      @user.stub!(:workout_sessions).and_return([])
      @user.days_since_last_workout.should == 0      
    end

    it "should have days since last weight if user weights isn't empty" do
      @user.days_since_last_weight.should == 6
    end

    it "should return 0 for days since last weight if there aren't any user weights" do
      @user.stub!(:user_weights).and_return([])
      @user.days_since_last_weight.should == 0
    end

    it "should have days_since_last_meal if meals is not empty" do
      @meal = mock_model(Meal, :created_at => (Time.zone.now - 144.hours))
      @user.stub!(:meals).and_return([@meal])
      @user.days_since_last_meal.should == 6
    end

    it "should return 0 for days_since_last_meal if meals is empty" do
      @user.stub!(:meals).and_return([])
      @user.days_since_last_meal.should == 0
    end

    it "should have days_since_last_activity if activities is not empty" do
      @activity = mock_model(UserActivity, :created_at => (Time.zone.now - (6*24).hours))
      @user.stub!(:activities).and_return([@activity])
      @user.days_since_last_activity.should == 6
    end

    it "should return 0 for days_since_last_meal if meals is empty" do
      @user.stub!(:activities).and_return([])
      @user.days_since_last_activity.should == 0
    end

    it "should have days_since_last_login if last_logged_in_at is set" do
      @user.stub!(:last_logged_in_at).and_return(Time.zone.now - (6*24).hours)
      @user.days_since_last_login.should == 6
    end

    it "should return 0  for days_since_last_login if last_logged_in_at is not set" do
      @user.stub!(:last_logged_in_at).and_return(nil)
      @user.days_since_last_login.should == 0
    end

    it "should return 0 for average_calorie_balance if no calories" do
      @user.stub!(:calorie_balance).and_return(nil)
      @user.average_calorie_balance.should == 0
    end

    it "should return 0 for tdee if no current_weight" do
      @user.stub!(:current_weight).and_return(nil)
      @user.tdee.should == 0
    end

    describe "generate_workouts" do
      it "should return unless the user is a basic user" do
        user = users(:admin_user)
        user.generate_workouts.should == false
      end
      
      it "should generate workouts if the user is a basic user" do
        user = users(:basic_user)
        user.stub!(:equipment).and_return('Dumbbell')
        user.generate_workouts
        user.workouts.find_all_by_week_of(Time.zone.now.beginning_of_week.to_date).size.should == 1
      end
      
      it "should only generate workouts once" do
        user = users(:basic_user)
        user.stub!(:equipment).and_return('Dumbbell')
        user.generate_workouts
        user.generate_workouts
        user.workouts.find_all_by_week_of(Time.zone.now.beginning_of_week.to_date).size.should == 1
      end
    end
    
    it "should return full_name" do
      user = users(:basic_user)
      user.full_name.should == 'Peter Roberts'
    end
    
    def generate_weights
      dates = Hash.new
      ((Time.zone.now.to_date - 6.days)..(Time.zone.now.to_date)).each do |d|
        dates[d] = {:weight => 145}
      end
      ((Time.zone.now.to_date - 1.month)..(Time.zone.now.to_date - 7.days)).each do |d|
        dates[d] = {:weight => 140}
     end
     (Time.zone.now.to_date..Time.zone.now.to_date + 1.week).each do |d|
         if dates[d]
          dates[d].update({:forecasted_weight => 145})
         else
           dates[d] = {:forecasted_weight => 145}
         end
     end
     dates
    end
  end

  describe "Static functions" do
    fixtures :users, :roles, :user_roles, :workouts, :workout_sessions, :user_weights, :medical_histories, :subscriptions
    
    it "send notifications" do
      User.stub!(:all).and_return([users(:free_user), users(:premium_user), users(:basic_user)])
      Notifier.should_receive(:deliver_reminder_email).exactly(2).times
      User.send_reminders
    end

    it "should have users needing workouts" do
      User.users_needing_workouts.size.should == 1
    end

    it "should not include a user who signed up less than 24 hours before the next week in users needing workouts" do
      start_time = Time.zone.now.end_of_week - 12.hours
      @user = users(:valid_user)
      @user.stub!(:created_at).and_return(start_time)
      User.stub!(:all).and_return([@user])
      User.users_needing_workouts.size.should == 0
    end

    it "should have new users" do
      @zone = mock_model(ActiveSupport::TimeZone, :now => DateTime.parse('2009-10-12'))
      Time.stub!(:zone).and_return(@zone)
      User.stub!(:count).and_return(
        {'2009-09-29' => 6}
      )
      User.new_users_month.should == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    end

    it "should have new users count" do
      User.new_users_month_count.should == 9
    end
    
    it "should login nag email" do
      Notifier.stub!(:deliver_nag_digest_email).and_return(true)
      user_one = mock_model(User, 
        :days_since_last_login => 9, 
        :time_zone => 'UTC', 
        :first_name => 'test', 
        :last_name => 'test', 
        :subscription_type => Subscription::PREMIUM_SUBSCRIPTION,
        :reminder_emails => true
      )
      User.stub!(:all).and_return([user_one])
      Notifier.should_receive(:deliver_login_nag_email).once
      User.send_nag_emails
    end
    
    it "should not send nag email if the user has no subscription_type" do
      user_one = mock_model(User, 
        :days_since_last_login => 9, 
        :time_zone => 'UTC', 
        :first_name => 'test', 
        :last_name => 'test', 
        :subscription_type => nil,
        :reminder_emails => true
      )
      User.stub!(:all).and_return([user_one])
      Notifier.should_not_receive(:deliver_login_nag_email)
      User.send_nag_emails
    end
    
    it "should send other nag emails" do 
      user_one = mock_model(User, 
        :days_since_last_login => 0, 
        :days_since_last_workout => 6,
        :days_since_last_weight => 6,
        :days_since_last_activity => 6,
        :days_since_last_meal => 6, :time_zone => 'UTC',
        :subscription_type => Subscription::PREMIUM_SUBSCRIPTION,
        :reminder_emails => true
      )
      User.stub!(:all).and_return([user_one])
      Notifier.should_receive(:deliver_nag_email)
      User.send_nag_emails
    end
    
    it "should only send login nag email even if other nags exist" do
      user_one = mock_model(User, 
        :days_since_last_login => 3, 
        :days_since_last_workout => 3,
        :days_since_last_weight => 0,
        :days_since_last_activity => 0,
        :days_since_last_meal => 0, :time_zone => 'UTC',
        :subscription_type => Subscription::PREMIUM_SUBSCRIPTION,
        :reminder_emails => true
      )
      User.stub!(:all).and_return([user_one])
      Notifier.should_receive(:deliver_login_nag_email).once
      Notifier.should_not_receive(:deliver_nag_email)
      User.send_nag_emails
    end
    
    it "should not send a workout nag email if the user is a free user" do
      user_one = mock_model(User, 
        :days_since_last_login => 0, 
        :days_since_last_workout => 6,
        :days_since_last_weight => 0,
        :days_since_last_activity => 0,
        :days_since_last_meal => 0, :time_zone => 'UTC',
        :subscription_type => Subscription::FREE_SUBSCRIPTION,
        :reminder_emails => true
      )
      User.stub!(:all).and_return([user_one])
      Notifier.should_not_receive(:deliver_nag_email)
      User.send_nag_emails
    end
    
    it "should not send nags on days that are not multiples of 3" do
      user_one = mock_model(User, 
        :days_since_last_login => 4, 
        :days_since_last_workout => 4,
        :days_since_last_weight => 4,
        :days_since_last_activity => 4,
        :days_since_last_meal => 4, :time_zone => 'UTC',
        :subscription_type => Subscription::PREMIUM_SUBSCRIPTION,
        :reminder_emails => true
      )
      User.stub!(:all).and_return([user_one])
      Notifier.should_not_receive(:deliver_login_nag_email)
      Notifier.should_not_receive(:deliver_nag_email)
      User.send_nag_emails
    end
    
    it "should not send nags on days that are greater than 9" do
      user_one = mock_model(User, 
        :days_since_last_login => 12, 
        :days_since_last_workout => 12,
        :days_since_last_weight => 12,
        :days_since_last_activity => 12,
        :days_since_last_meal => 12, :time_zone => 'UTC',
        :subscription_type => Subscription::PREMIUM_SUBSCRIPTION,
        :reminder_emails => true
      )
      User.stub!(:all).and_return([user_one])
      Notifier.should_not_receive(:deliver_login_nag_email)
      Notifier.should_not_receive(:deliver_nag_email)
      User.send_nag_emails
    end
    
    it "should not send nags if the user has opted out of reminder emails" do
      user_one = mock_model(User, 
        :days_since_last_login => 0, 
        :days_since_last_workout => 6,
        :days_since_last_weight => 6,
        :days_since_last_activity => 6,
        :days_since_last_meal => 6, :time_zone => 'UTC',
        :subscription_type => Subscription::PREMIUM_SUBSCRIPTION,
        :reminder_emails => false
      )
      User.stub!(:all).and_return([user_one])
      Notifier.should_not_receive(:deliver_nag_email)
      User.send_nag_emails
    end
    
    it "should send a digest email" do
      user_one = mock_model(User,
        :days_since_last_login => 0, 
        :days_since_last_workout => 9,
        :days_since_last_weight => 9,
        :days_since_last_activity => 9,
        :days_since_last_meal => 9,
        :email => 'test@test.com',
        :first_name => 'test', 
        :time_zone => 'UTC',
        :subscription_type => Subscription::PREMIUM_SUBSCRIPTION,
        :reminder_emails => true
      )
      
      user_two = mock_model(User,
        :days_since_last_login => 0, 
        :days_since_last_workout => 9,
        :days_since_last_weight => 9,
        :days_since_last_activity => 9,
        :days_since_last_meal => 9,
        :email => 'test@test.com',
        :first_name => 'test', :time_zone => 'UTC',
        :subscription_type => Subscription::PREMIUM_SUBSCRIPTION,
        :reminder_emails => true
      )
      
      User.stub!(:all).and_return([user_one, user_two])
      
      Notifier.should_receive(:deliver_nag_digest_email).once
      
      User.send_nag_emails
    end
      
    it "should send a progress email after 2 months" do
      user_one = mock_model(User, :created_at => Date.today - 2.months)
      user_two = mock_model(User, :created_at => Date.today - 1.month)
      user_three = mock_model(User, :created_at => Date.today - 3.months)
      User.stub!(:all).and_return([user_one, user_two, user_three])
      Notifier.should_receive(:deliver_progress_email).once
      User.send_progress_email
    end
    
  end

end

