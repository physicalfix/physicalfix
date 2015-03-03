class AccountsController < ApplicationController
  before_filter :require_login, :except => [:index, :new, :create, :thank_you]
  before_filter :find_user, :only => [:show, :edit, :update, :equipment, :workout_type, :notifications, :billing]
  ssl_required :edit, :new, :create
  ssl_allowed :show, :update

  VALID_PLANS = ['trial', 'free', 'basic', 'premium']
  
  def index
    Rails.logger.warn "======#{current_user.inspect}=====#{current_user.present?}==#{@current_user.inspect}==========#{request.referer}========================"
    if current_user.present? && (request.referer.include? "http://www.physicalfix.com/")
      redirect_to workouts_path
    else
      @num_pros = User.all.count{|u| u.subscription && u.subscription.product == 'premium'}
      render :layout => 'splash'
    end
  end
  
  def show
    @page_title = "Account Info"
    @height_feet = @user.height.split('\'')[0].to_i
    @height_inches = @user.height.split('\'')[1].to_i
    puts @user.height
    puts @height_feet
    puts @height_inches
  end
  
  def equipment
    @equpiment = get_equipment
    render :template => '/accounts/edit_equipment'
  end
  
  def workout_type
    @user_buckets = UserBucket.approved.group_by{|ub| ub.enough_equipment?(@user.equipment).to_s}
    render :template => '/accounts/edit_user_buckets'
  end
  
  def billing
    @num_pros = User.all.count{|u| u.subscription && u.subscription.product == 'premium'}
  end
  
  def new
    
    # grab key if it exists
    key = params[:k]
    
    # if we have a key find out what membership
    if key
      freeby = Freeby.find_by_key(key)
      # make sure it's not been used
      if freeby && !freeby.used
        membership_type = freeby.membership_type
        session[:plan] = membership_type
        session[:key] = key
      else
        redirect_to "/422.html" # invalid key
        return
      end
    end
      
    if !key && params[:plan] && VALID_PLANS.include?(params[:plan])
      session[:plan] = params[:plan]
    end
      
    @user = User.new
    @height_feet = 5
    @height_inches = 0
    @credit_card = CreditCard.new
    
    render :layout =>'splash'
  end

  def create
    
    params[:user][:cell_phone] = params[:user][:cell_phone].gsub(/\D/, '') if params[:user][:cell_phone]
    params[:user][:home_phone] = params[:user][:home_phone].gsub(/\D/, '') if params[:user][:home_phone]
    params[:user][:height] = "#{params[:height_feet]}' #{params[:height_inches]}\""

    @user = User.new(params[:user])
    
    @height_feet = params[:height_feet].to_i
    @height_inches = params[:height_inches].to_i
    
    key = session[:key]
    
    if @user.valid? 
    
      if session[:plan] && session[:plan] == 'free'
        @user.save
        Subscription.create(:user_id => @user.id, :product => Subscription::FREE_SUBSCRIPTION, :state => Subscription::ACTIVE_STATE)
        after_signup
        
      ##
      ## Start: Free 14-Day Trial Modifications
      ##
      
      elsif session[:plan] == 'trial'
        @user.save
        Subscription.create(:user_id => @user.id, :product => Subscription::BASIC_SUBSCRIPTION, :state => Subscription::TRIAL_STATE)
        after_signup

      elsif key
        # check key
        freeby = Freeby.find_by_key(key)
        if freeby 
          # mark freeby used
          freeby.used = true
          freeby.save
          session[:key] = nil
          @user.save
          Subscription.create(:user_id => @user.id, :product => session[:plan], :state => Subscription::ACTIVE_STATE)
          after_signup
        else
          redirect_to "/422.html" # invalid key
          return
        end
        
      ##
      ## End: Free 14-Day Trial Modifications
      ##
      
      else
        params[:credit_card][:first_name] = @user.first_name
        params[:credit_card][:last_name] = @user.last_name
        @credit_card = CreditCard.new(params[:credit_card])
    
        if @credit_card.valid?
          if session[:plan] == 'basic'
            product = 'basic-subscription'
          elsif session[:plan] == 'premium'
            product = 'premium-subscription'
          end
    
          User.transaction do 
            @user.save
            @subscription = Subscription.create_subscription(@user, product, @credit_card)
            raise ActiveRecord::Rollback if !@subscription.errors.errors.empty?
          end
        
          if !@subscription.errors.errors.empty?
            @user = @current_user || User.new(params[:user])
            flash[:error] = @subscription.errors.full_messages.join(', ')
            render :action => :new, :layout => 'splash'
            return
          else
            Subscription.create(
              :user_id => @user.id,
              :state => @subscription.state,
              :product =>product.split('-')[0],
              :chargify_id => @subscription.id
            )
            after_signup
          end
        else
          render :action => :new, :layout => 'splash'
        end
      end
    else
      @credit_card = CreditCard.new
      render :action => :new, :layout => 'splash'
    end
  end

  def edit
    @height_feet = @user.height.split('\'')[0].to_i
    @height_inches = @user.height.split('\'')[1].to_i
    @equipment = get_equipment
  end
  
  def update
    params[:user][:equipment].delete("") if params[:user][:equipment]
    params[:user][:equipment] = params[:user][:equipment].join("|") if params[:user][:equipment]
    params[:user][:cell_phone] = params[:user][:cell_phone].gsub(/\D/, '') if params[:user][:cell_phone]
    params[:user][:home_phone] = params[:user][:home_phone].gsub(/\D/, '') if params[:user][:home_phone]

    params[:user][:height] = params[:height_feet] + '\' ' + params[:height_inches] + '"' if params[:height_feet] && params[:height_inches]

    if @user.update_attributes(params[:user])
      flash[:info] = "Your info has been updated"
      if params[:update_user_bucket_on_workout]
        redirect_to workouts_path
      else
        redirect_to account_path
      end
    else
      @height_feet = @user.height.split('\'')[0].to_i
      @height_inches = @user.height.split('\'')[1].to_i
      @equipment = get_equipment
      render :controller => :accounts, :action => :show
    end
  end
  
  def destroy
    User.transaction do
      # cancel the subscription if there is one
      @current_user.subscription.unsubscribe
      
      #destroy the user record (do we want to do this?)
      @current_user.destroy
      
      #log the user out
      session[:uid] = nil
      session[:logged_in_as] = nil

      redirect_to root_path
    end
  end
  
  def thank_you
    redirect_to root_path unless session[:plan]
    @subscription_plan = session[:plan]
    session.delete(:plan)
    flash.clear
  end
  
 protected
 
 def find_user
   @user = current_user
 end
 
 private
 
 def after_signup
   @user.reload
   
   #login user
   session[:uid] = @user.id

   #set inital weight
   @user.user_weights << UserWeight.create(:user_id => @user.id, :weight => @user.weight)


   #send welcome email
   @user.send_signup_notification
   
   redirect_to thank_you_path
 end
 
 
end
