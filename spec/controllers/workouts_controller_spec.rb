require File.dirname(__FILE__) + '/../spec_helper'

describe WorkoutsController do
  
  fixtures :users, :roles, :user_roles, :medical_histories, :subscriptions

  before do
    @user = users(:valid_user)
    @user.stub!(:user_bucket).and_return(1)
    @subscription = mock_model(Subscription, 
      :product =>Subscription::PREMIUM_SUBSCRIPTION,
      :state => 'active'
    )
    @user.stub!(:subscription).and_return(@subscription)
    User.stub!(:find).and_return(@user)
    login(@user)
  end

  it_should_behave_like "controllers"

  describe "GET index" do
     it "should redirect if no medical_history" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @user.stub!(:subscription).and_return(mock_model(Subscription, :state => 'active', :product => Subscription::PREMIUM_SUBSCRIPTION))
      User.stub!(:find).and_return(@user)
      get :index
      response.should redirect_to(new_account_medical_history_path)
     end
     
     it "should not redirect if no medical_history but not premium" do
       @subscription.stub!(:product).and_return(Subscription::BASIC_SUBSCRIPTION)
       @user.stub!(:equipment).and_return('15lb Dumbbells')
       User.stub!(:find).and_return(@user)
       get :index
       response.should_not be_redirect
     end
     
     it "should redirect if the user is a free user" do
       User.stub!(:find).and_return(@user)
       @subscription.stub!(:product).and_return(Subscription::FREE_SUBSCRIPTION)
       get :index
       response.should redirect_to(food_log_index_path)
     end

    it "should assign true to start_flag if the user signed up less than 24 hours before the start of the next week" do
      sign_up_date = Time.zone.now.end_of_week - 12.hours
      @user.stub!(:created_at).and_return(sign_up_date)
      User.stub!(:find).and_return(@user)
      @zone = mock("zone", :now => Time.zone.now + 1.week)
      Time.stub!(:zone).and_return(@zone)
      get :index
      assigns[:start_flag].should be_true
    end

    it "should assign false to start_flag if the user signed up over 24 hours before the start of the next week" do
      sign_up_date = Time.zone.now.end_of_week - 28.hours
      @user.stub!(:created_at).and_return(sign_up_date)
      User.stub!(:find).and_return(@user)
      @zone = mock("zone", :now => Time.zone.now + 1.week)
      Time.stub!(:zone).and_return(@zone)
      get :index
      assigns[:start_flag].should be_false
    end

     it "should assign true to start_flag if the user signs in before they should get workouts" do
       start_date = Time.zone.now.beginning_of_week
       7.times do |i|
         @user.stub!(:created_at).and_return(start_date + i*(1.day))
         User.stub!(:find).and_return(@user)
         get :index
         assigns[:start_flag].should be_true
       end
     end

    it "should assign false if the user signed up well over a week ago" do
      @user.stub!(:created_at).and_return(Time.zone.now - 1.year)
      User.stub!(:find).and_return(@user)
      get :index
      assigns[:start_flag].should be_false
    end

    it "should assign false to start_flag if the user is a basic user" do
      sign_up_date = Time.zone.now.end_of_week - 12.hours
      @user.stub!(:created_at).and_return(sign_up_date)
      @subscription.stub!(:product).and_return(Subscription::BASIC_SUBSCRIPTION)
      @user.stub!(:generate_workouts).and_return(true)
      @user.stub!(:user_bucket).and_return(12)
      @user.stub!(:workout_difficulty).and_return('easy')
      User.stub!(:find).and_return(@user)
      get :index
      assigns[:start_flag].should be_false
    end
    
    it "should assign user_buckets if no user_buckets selected" do
      @subscription.stub!(:product).and_return(Subscription::BASIC_SUBSCRIPTION)
      @user.stub!(:user_bucket).and_return(nil)
      @user.stub!(:equipment).and_return('')
      User.stub!(:find).and_return(@user)
      UserBucket.stub!(:approved).and_return([])
      get :index
      assigns[:user_buckets].should_not be_nil
    end
    
    it "should generate workouts if the user needs them" do
      @subscription.stub!(:product).and_return(Subscription::BASIC_SUBSCRIPTION)
      @user.stub!(:user_bucket).and_return(mock_model(UserBucket))
      @user.stub!(:workout_difficulty).and_return('easy')
      @user.stub!(:workouts).and_return(mock('workouts', :all => []))
      @user.should_receive(:generate_workouts).and_return(true)
      @user.stub!(:equipment).and_return('')
      User.stub!(:find).and_return(@user)
      get :index
    end
    
    it "should not generate workouts if the user doesn't need them" do
      @subscription.stub!(:product).and_return(Subscription::BASIC_SUBSCRIPTION)
      @user.stub!(:user_bucket).and_return(mock_model(UserBucket))
      @user.stub!(:workout_difficulty).and_return('easy')
      @workout = mock_model(Workout)
      @user.stub!(:workouts).and_return(mock('workouts', :all => [@workout, @workout, @workout]))
      @user.should_not_receive(:generate_workouts).and_return(true)
      @user.stub!(:equipment).and_return('')
      User.stub!(:find).and_return(@user)
      get :index
    end
    
    it "should reset user bucket if the user bucket is bad" do
      @subscription.stub!(:product).and_return(Subscription::BASIC_SUBSCRIPTION)
      @user.stub!(:user_bucket).and_return(mock_model(UserBucket))
      @user.stub!(:workout_difficulty).and_return('easy')
      @user.stub!(:workouts).and_return(mock('workouts', :all => []))
      @user.stub!(:generate_workouts).and_return('bad bucket')
      @user.stub!(:equipment).and_return('')
      @user.should_receive(:update_attributes).with(:user_bucket_id => nil, :workout_difficulty => nil)
      User.stub!(:find).and_return(@user)
      get :index
    end
    
    it "should delete the workouts" do
      @subscription.stub!(:product).and_return(Subscription::BASIC_SUBSCRIPTION)
      @user.stub!(:user_bucket).and_return(mock_model(UserBucket))
      @user.stub!(:workout_difficulty).and_return('easy')
      @workout = mock_model(Workout)
      @workout.should_receive(:destroy)
      @user.stub!(:workouts).and_return(mock('workouts', :all => [@workout]))
      @user.stub!(:generate_workouts).and_return('bad bucket')
      @user.stub!(:equipment).and_return('')
      @user.stub!(:update_attributes).and_return(true)
      User.stub!(:find).and_return(@user)
      get :index
    end
    
    it "should get user buckets if bad bucket" do
      @subscription.stub!(:product).and_return(Subscription::BASIC_SUBSCRIPTION)
      @user.stub!(:user_bucket).and_return(mock_model(UserBucket))
      @user.stub!(:workout_difficulty).and_return('easy')
      @user.stub!(:workouts).and_return(mock('workouts', :all => []))
      @user.stub!(:generate_workouts).and_return('bad bucket')
      @user.stub!(:equipment).and_return('')
      @user.stub!(:update_attributes).and_return(true)
      User.stub!(:find).and_return(@user)
      get :index
      assigns[:user_buckets].should_not be_nil
    end
    
    it "should redirect to new subscription form if subscription state is nil" do
      @subscription.stub!(:state).and_return(nil)
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      
      get :index
      response.should redirect_to(new_subscription_path)
    end
    
    
  end

  describe "GET show" do
    
    fixtures :workouts, :exercises, :exercises_workouts
     it "should redirect if no medical_history" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @subscription = mock_model(Subscription, :product =>  Subscription::PREMIUM_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      get :show
      response.should redirect_to(new_account_medical_history_path)
     end
     
     it "should not redirect if no medical_history but not premium" do
       @user.stub!(:subscription_type).and_return(Subscription::BASIC_SUBSCRIPTION)
       User.stub!(:find).and_return(@user)
       get :show, :id => workouts(:workout_for_this_week).id
       response.should_not be_redirect
     end
     
     it "should redirect if the user is a free user" do
        @subscription.stub!(:product).and_return(Subscription::FREE_SUBSCRIPTION)
        User.stub!(:find).and_return(@user)
        get :show
        response.should redirect_to(food_log_index_path)
      end

    it "should redirect if workout doesn't belong to user" do
      @user = mock_model(User, :medical_history => {}, :time_zone => 'UTC', :user_bucket => 1)
      @subscription.stub!(:product).and_return(Subscription::BASIC_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      @another_user = mock_model(User, :medical_history => {}, :time_zone => 'UTC')
      workout_sessions = mock('workout_sessions_proxy', :started_today => [])
      @workout = mock_model(Workout, :user => @another_user, :workout_sessions => workout_sessions)
      User.stub!(:find).and_return(@user)
      Workout.stub!(:find).and_return(@workout)
      get :show
      response.should redirect_to(workouts_path)
    end

    it "should 200 if it does belong to user" do
      @user = users(:valid_user)
      @workout = workouts(:workout_for_this_week)
      User.stub!(:find).and_return(@user)
      Workout.stub!(:find).and_return(@workout) 
      get :show
      #response.headers["Status"].to_i.should == 200 
    end

    it "should not include Stretch mat mat in equipment if the user does not have one" do
      @user = users(:valid_user)
      @workout = workouts(:workout_for_this_week)
      User.stub!(:find).and_return(@user)
      Workout.stub!(:find).and_return(@workout)
      get :show
      assigns[:equipment].should_not include('Stretch mat')
    end

    it "should include Stretch mat mat in equipment if the user has one" do
      @user = users(:valid_user)
      @user.stub!(:equipment).and_return('Stretch mat')
      @workout = workouts(:workout_for_this_week)
      User.stub!(:find).and_return(@user)
      Workout.stub!(:find).and_return(@workout)
      get :show
      assigns[:equipment].should include('Stretch mat')
    end

  end

  describe "GET play" do
    
    before do
      @user = mock_model(User, :medical_history => {}, :time_zone => 'UTC', :user_bucket => 1)
      @subscription = mock_model(Subscription, :product => Subscription::BASIC_SUBSCRIPTION, :state => 'active')
      @user.stub!(:subscription).and_return(@subscription)
      @workout_sessions_proxy = mock("workout_sessions_proxy", :started_today => [])
      @workout = mock_model(Workout, :user => @user, :workout_sessions => @workout_sessions_proxy)
      User.stub!(:find).and_return(@user)
      Workout.stub!(:find).and_return(@workout)
    end


    it "should redirect if no medical_history" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @subscription.stub!(:product).and_return(Subscription::PREMIUM_SUBSCRIPTION)
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      get :play
      response.should redirect_to(new_account_medical_history_path)
    end
    
    it "should not redirect if no medical_history but not premium" do
      get :play
      response.should_not be_redirect
    end
    
     it "should redirect if the user is a free user" do
       @subscription.stub!(:product).and_return(Subscription::FREE_SUBSCRIPTION)
       User.stub!(:find).and_return(@user)
       get :play
       response.should redirect_to(food_log_index_path)
     end

    it "should redirect if workout doesn't belong to user" do
      @another_user = mock_model(User, :medical_history => {}, :time_zone => 'UTC')
      @workout.stub!(:user).and_return(@another_user)
      get :play
      response.should redirect_to(workouts_path)
    end

    describe "unfinished workout session" do
      before do
        @ws = mock_model(WorkoutSession, :workout_id => 234)
        @workout_sessions_proxy.stub!(:started_today).and_return([@ws])
      end

      it "should redirect to show if there is an existing workout session" do
        get :play, :id => @workout.id
        response.should redirect_to(workout_path(@ws.workout_id))
      end
      

      it "should start over session if resume is false" do
        @ws.should_receive(:update_attribute).with(:last_played, 0)
        get :play, {:id => @workout.id, :resume => 'f'}
      end

      it "should just play if resume is true" do
        @ws.should_not_receive(:update_attribute).with(:last_played, 0)
        get :play, {:id => @workout.id, :resume => 't'}
      end
    end

    it "should create new session if there is none" do
      WorkoutSession.should_receive(:create)
      get :play, {:id => @workout.id, :resume => 'f'}
    end

  end

  describe "GET resume" do
    fixtures :workouts, :workout_sessions
    
    it "should redirect if no medical_history" do
      @user = mock_model(User, :medical_history => nil, :time_zone => 'UTC')
      @subscription = mock_model(Subscription, :product => Subscription::PREMIUM_SUBSCRIPTION, :state => 'active')
      @user.stub!(:subscription).and_return(@subscription)
      User.stub!(:find).and_return(@user)
      get :resume
      response.should redirect_to(new_account_medical_history_path)
    end
    
    it "should redirect if the user is a free user" do
       @subscription.stub!(:product).and_return(Subscription::FREE_SUBSCRIPTION)
       User.stub!(:find).and_return(@user)
       get :resume
       response.should redirect_to(food_log_index_path)
    end
    
    it "should not redirect if no medical_history but not premium" do
      @subscription.stub!(:product).and_return(Subscription::BASIC_SUBSCRIPTION)
      User.stub!(:find).and_return(@user)
      get :resume, :id => workout_sessions(:started_workout_session).id
      response.should_not be_redirect
    end
    
    it "should find workout session" do
      @ws = mock_model(WorkoutSession, :workout_id => 1)
      WorkoutSession.stub!(:find).and_return(@ws)
      get :resume
    end

    it "should redirect if no workout session exists" do
      @subscription.stub!(:product).and_return(Subscription::BASIC_SUBSCRIPTION)
      User.stub!(:find).and_return(@user)
      WorkoutSession.stub!(:find).and_return(nil)
      get :resume
      response.should redirect_to(workouts_path)
    end

  end

  describe "GET playlist" do
    it "should render xml" do
      @workout = mock_model(Workout)
      Workout.stub!(:find).and_return(@workout)
      get :playlist
      response.should render_template('workouts/playlist.xml.builder')
    end
  end

  describe "GET status" do
    fixtures :users, :user_activities
    
    it "should update last_played" do
      @user = mock_model(User, :time_zone => 'UTC')
      @user.stub!(:has_role?).with('Free').and_return(false)
      @workout = mock_model(Workout, :user => @user, :calories_burned => 300, :duration => 0)
      @ws = mock_model(WorkoutSession, :workout => @workout, :created_at => DateTime.now, :updated_at => DateTime.now)

      WorkoutSession.stub!(:find).and_return(@ws)

      @ws.should_receive(:update_attribute).with(:last_played, "5")
      get :status, {:lastPlayed => 5, :id =>@ws.id}
    end

    it "should add a user activity for the workout" do
      @user = mock_model(User, :time_zone => 'UTC')
      @workout = mock_model(Workout, :user => @user, :calories_burned => 300, :duration => 0)
      @ws = mock_model(WorkoutSession, :workout => @workout, :created_at => DateTime.now, :updated_at => DateTime.now, :update_attribute => true)
      WorkoutSession.stub!(:find).and_return(@ws)
      name = "Workout started on #{@ws.created_at.to_s(:long)}"
      @ua = mock_model(UserActivity, :user => @user, :activity_date= => true)
      
      params = {:user_id => @user.id, :name => name, :activity_date => @ws.created_at, :duration => 0}
      
      UserActivity.should_receive(:find_by_user_id_and_name).and_return(@ua)
      @ua.should_receive(:calories_burned=).with(300)
      @ua.should_receive(:duration=).with(0)
      @ua.should_receive(:save)

      get :status, {:lastPlayed => 5, :id => @ws.id}
    end

    it "should update a current record if it exists" do
      @user = users(:valid_user)
      @workout = mock_model(Workout, :user => @user, :calories_burned => 300, :duration => 0)
      @ws = mock_model(WorkoutSession, :workout => @workout, :created_at => Time.zone.now, :updated_at => Time.zone.now, :update_attribute => true)
      activity_name = "Workout started on #{@ws.created_at.strftime('%B %d, %Y %I:%M %p')}"

      UserActivity.create(
              :user_id => @user.id,
              :name => activity_name,
              :duration => 0.0,
              :activity_date =>  @ws.updated_at,
              :calories_burned => 0.9
      )
      
      ua_count = @user.user_activities.count

      WorkoutSession.stub!(:find).and_return(@ws)
      
      get :status, {:lastPlayed => 5, :id => @ws.id}

      assigns[:user].user_activities.count.should == ua_count
    end
    
  end

  describe "POST comment" do
    before do
      @workout = mock_model(Workout, :comment => nil, :update_attribute => true)
      Workout.stub!(:find).and_return(@workout)
      @ws = mock_model(WorkoutSession)
      WorkoutSession.stub!(:find).and_return(@ws)
    end
    
    it "should set workout session to complete if there is a session" do
      @ws.should_receive(:update_attribute).with(:complete, true)
      post :comment, {:workout_session => 1, :workout => {}}
    end

    it "should redirect to index if there is already a comment" do
      @workout.stub!(:comment).and_return('this is a comment')
      post :comment, {:workout => {}}
      response.should redirect_to(workouts_path)
    end

    it "should update comment" do
      @ws.should_receive(:update_attribute).with(:complete, true)
      @workout.should_receive(:update_attribute)
      post :comment, {:workout_session => 1, :workout => {:difficulty => 'easy', :pain => 'yes', :where_pain => 'shoulders'}}
    end
  end
  
end

