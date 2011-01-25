class AccountsController < ApplicationController
  before_filter :require_login, :except => [:index, :new, :create, :thank_you]
  before_filter :find_user, :only => [:show, :edit, :update, :equipment, :workout_type, :notifications, :billing]
  ssl_required :edit, :new, :create
  ssl_allowed :show, :update

  def index
    @num_pros = Subscription.get_num_premiums
    render :layout => 'splash'
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
    @num_pros = Subscription.get_num_premiums
    @product = @current_user.subscription.product
  end

  def new
    key = params[:k]
    plan = params[:plan]
    if key
      check_key(key)
    end
    if !key && plan && !Subscription.freeby?(plan)
      session[:plan] = plan
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
    plan = session[:plan]
    if @user.valid?
      if key
        use_freeby(key)
      elsif Subscription.free_or_trial?(plan)
        begin_chargify_transaction(plan)
        after_signup
      else
        params[:credit_card][:first_name] = @user.first_name
        params[:credit_card][:last_name] = @user.last_name
        @credit_card = CreditCard.new(params[:credit_card])
        if @credit_card.valid?
          product = nil
          if Subscription.paid?(plan)
            product = plan
          end
          begin_chargify_transaction(product, @credit_card)
          after_signup
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
      flash[:info] = "Your info has been updated."
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
      @current_user.subscription.unsubscribe
      @current_user.destroy
      logout
    end
  end

  def thank_you
    redirect_to root_path unless session[:plan]
    @product = session[:plan]
    session.delete(:plan)
    flash.clear
  end

  protected

    def find_user
      @user = current_user
    end

  private

    def check_key(key)
      freeby = Freeby.find_by_key(key)
      if freeby && !freeby.used
        membership_type = freeby.membership_type
        session[:plan] = membership_type
        session[:key] = key
      else
        redirect_to "/422.html" # invalid key
        return
      end
    end

    def use_freeby(key)
      freeby = Freeby.find_by_key(key)
      if freeby
        freeby.used = true
        freeby.save
        session.delete(:key)
        @user.save
        if Subscription.freeby?(session[:plan])
          begin_chargify_transaction(session[:plan])
        end
        after_signup
      else
        redirect_to "/422.html" # Invalid key!
        return
      end
    end

    # Start a Chargify transaction with the specified user and product plan
    def begin_chargify_transaction(product, credit_card = nil)
      subscription = nil
      User.transaction do
        @user.save
        subscription = Subscription.create_subscription(@user, product, credit_card)
        raise ActiveRecord::Rollback if !subscription.errors.errors.empty?
      end
      if !subscription.errors.errors.empty?
        @user = @current_user || User.new(params[:user])
        flash[:error] = subscription.errors.full_messages.join(', ')
        render :action => :new, :layout => 'splash'
        return
      else
        Subscription.create(
          :user_id => @user.id,
          :state => subscription.state,
          :product => product,
        :chargify_id => subscription.id)
      end
    end

    # What to show people after signup (the thank you page)
    def after_signup
      @user.reload
      session[:uid] = @user.id
      # Set inital weight.
      @user.user_weights << UserWeight.create(:user_id => @user.id, :weight => @user.weight)
      # Send welcome email.
      @user.send_signup_notification
      redirect_to thank_you_path
    end

end
