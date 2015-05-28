class SessionsController < ApplicationController
  ssl_required :new
  ssl_allowed :create
  
  def new
    render :layout => 'sign_in'
  end

  def create
    @user = User.find_by_email(params[:email])
    
    #@user = nil if @user && @user.roles_string.empty?
    
    if @user && @user.password_is?(params[:password])
      @user.update_attribute(:last_logged_in_at, Time.now)
      session[:uid] = @user.id
      
      ##
      ## Start: Free 14-Day Trial Modifications
      ##
    
      # Get rid of "logout" flash message
      flash.discard

      if @user.trial_expired?
        print "+==========================="        
        flash[:error] = "Your #{@user.get_trial_text} has expired. To continue receiving workouts, please upgrade now..."
        @user.downgrade_to_free
        redirect_to billing_account_path
        return
      end

      ##
      ## End: Free 14-Day Trial Modifications
      ##
      
      #check for credit card state
      if @user.subscription && Subscription::PROBLEM_STATES.include?(current_user.subscription.state)
        session[:cc_problem] = true
      end
      
      if @user.medical_history == nil && @user.subscription && @user.subscription.product == Subscription::PREMIUM_SUBSCRIPTION
        session[:return_to] = nil
        flash[:error] = "You must complete the medical history questionnaire before you can continue using PhysicalFix"
        redirect_to new_account_medical_history_path
      else
         flash[:info] = "Welcome Back #{@user.first_name}!"

        if session[:return_to]
          redirect_to session[:return_to]
          session[:return_to] = nil
        elsif @user.has_role?('Admin')
          redirect_to admin_path
        elsif @user.subscription && @user.subscription.product == Subscription::FREE_SUBSCRIPTION
          redirect_to food_log_index_path
        else
          redirect_to workouts_path
        end
      end
    else
      flash[:error] = 'Wrong username or password';
      render :action => :new, :layout => 'sign_in'
    end
  end
  
  def sudo
    if current_user.has_role?('Admin')
      session[:logged_in_as] = params[:user_id]
      @logged_in_as = current_user
      redirect_to workouts_path
    else
      redirect_to root_path
    end
  end
  
  def unsudo
    session[:logged_in_as] = nil
    redirect_to admin_path
  end

  def destroy
    session[:uid] = nil
    session[:logged_in_as] = nil
    flash[:info] = "Logout Successful."
    redirect_to root_path
  end

end
