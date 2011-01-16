class WorkoutsController < ApplicationController
  before_filter :require_login
  before_filter :require_medical_history
  before_filter :require_paid_access
  
  before_filter :require_requirements
  
  def index
    @title = 'Workout'
    @user = current_user
    
    if @user.subscription && @user.subscription.product == Subscription::BASIC_SUBSCRIPTION
      @start_flag = false
    else
      @start_flag = @user.created_at > Time.zone.now.beginning_of_week - 1.day
    end
    
    @week_start = Time.zone.now.beginning_of_week.to_date
    @workouts = @user.workouts.all(:conditions => {:week_of => @week_start.to_s, :approved => true}, :include => [:workout_sessions])
    
    if (@user.subscription && @user.subscription.product == Subscription::BASIC_SUBSCRIPTION &&
            (@user.user_bucket.nil? || @user.workout_difficulty.nil?)) ||
            params[:edit_workouts] == 'true'
      @user_buckets = UserBucket.approved.group_by{|ub| ub.enough_equipment?(@user.equipment).to_s}
    elsif @workouts.size < 3
      result = @user.generate_workouts
      @workouts = @user.workouts.all(:conditions => {:week_of => @week_start.to_s, :approved => true}, :include => [:workout_sessions])
      if result == 'bad bucket'
        @user.update_attributes(:user_bucket_id => nil, :workout_difficulty => nil)
        @workouts.each{|w| w.destroy}
        @user_buckets = UserBucket.approved.group_by{|ub| ub.enough_equipment?(@user.equipment).to_s}
      end
    end
    
    respond_to do |wants|
      wants.html
      wants.xml { render :xml => @workouts.to_xml }
    end
  end
  
  def show
    @title = 'Workout :: View'
    @workout = Workout.find(params[:id])

    @workout_session = @workout.workout_sessions.started_today

    if @workout.user != current_user
      flash[:error] = 'You cannot access this workout because it does not belong to you';
      redirect_to workouts_path
    else
     @equipment = @workout.equipment
     @equipment << 'Stretch mat' if !current_user.equipment.nil? && current_user.equipment.include?('Stretch mat')
      respond_to do |wants|
        wants.html
        wants.xml { render :xml => @workout.to_xml }
      end
    end
  end

  def play
    @title = 'Workout :: Play'
    @workout = Workout.find(params[:id])
    if @workout.user != current_user
      flash[:error] = 'You cannot access this workout because it does not belong to you';
      redirect_to workouts_path
    else
      @workout_session = @workout.workout_sessions.started_today.first
    
      if @workout_session.nil?
        @workout_session = WorkoutSession.create(:workout_id => params[:id])
        render :layout => false
      elsif @workout_session != nil && params[:resume] != nil
        if params[:resume] == 't'
          render :layout => false
        elsif params[:resume] == 'f'
         @workout_session.update_attribute(:last_played, 0)
         render :layout => false
        end
      else
       redirect_to workout_path(@workout_session.workout_id)
      end
    end
  end
  
  def resume
    ws = WorkoutSession.find(params[:id])
    if ws == nil
      redirect_to workouts_path
    else
      @workout_id = ws.workout_id
    end
  end
  
  def status
    ws = WorkoutSession.find(params[:id])
    ws.update_attribute(:last_played, params[:lastPlayed])

    #get workout
    workout = ws.workout

    activity_name = "Workout started on #{ws.created_at.strftime('%B %d, %Y %I:%M %p')}" 
    ua = UserActivity.find_by_user_id_and_name(workout.user.id, activity_name)     
    
    unless ua
      ua = UserActivity.new(
        :user_id => workout.user.id, 
        :name => activity_name
      )
    end
    ua.duration = workout.duration(params[:lastPlayed].to_i + 1)/60
    ua.calories_burned = workout.calories_burned(params[:lastPlayed].to_i + 1)
    ua.activity_date = Time.now.utc
    ua.save
    @user = ua.user
    render :inline => '200'
  end
  
  def playlist
    @workout = Workout.find(params[:id])
    render :layout => false, :template => "workouts/playlist.xml.builder"
  end
  
  def comment    
    @title = 'Workout :: Comment'
    @comment = comment_message
    @workout = Workout.find(params[:id])
    if params[:workout_session]
      WorkoutSession.find(params[:workout_session]).update_attribute(:complete, true);
    end
    
    if @workout.comment != nil
      redirect_to :action => "index"
    else
      if request.post?
        com = ""
        if params[:workout][:difficulty]
          com += "This workout was too #{params[:workout][:difficulty]}<br/>"
        else
          com += 'This workout was just right<br/>'
        end
      
        if params[:workout][:pain] == 'yes'
          com += "Pain: #{params[:workout][:where_pain]}<br/>"
        end
      
        com += "#{params[:workout][:comment]}"
      
        @workout.update_attribute(:comment, com)
      
        flash[:info] = 'Thank you for your feedback!';
        redirect_to :action => "index"
      end
    end
  end


  def need_info
  end
  
  private
  def comment_message
    messages = ["That was a great workout {name} Let's keep it up!",
    "{name}, Keep up the good work! I am proud to be a PhysicalFix Team member with you!",
    "That was hard work {name}!  You did an awesome job!",
    "That was a tough one {name}! It's hard work but we're getting closer and closer to your goals!",
    "Hey {name}, succeeding feels good doesn't it?",
    "The PhysicalFix Team is proud of you {name}! Good work!",
    "Great job {name}! That's how you get stronger!"]
    messages[rand(messages.length)].gsub('{name}', User.find(current_user).first_name)
  end
  
  def require_requirements
    if @current_user.subscription && @current_user.subscription.product != Subscription::FREE_SUBSCRIPTION
      if @current_user.user_bucket.nil?
        if @current_user.equipment.nil?
          @equipment = get_equipment
          render :template => 'workouts/need_info.html.haml'
        end
      end
    end
  end
  
end
