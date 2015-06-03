class SubscriptionsController < ApplicationController
  ssl_required :edit, :new, :create
  def index
    
  end

  def new
    @credit_card = session[:cc] || CreditCard.new
    @subscription = session[:subscription]
    
    session.delete(:cc)
    session.delete(:subscription)
    
    if params[:plan]
      session[:upgrade] = true
      session[:plan] = params[:plan]
    end

    @plan = session[:plan]
    
    unless @plan
      redirect_to root_path
      return
    end
    
    render :layout =>'splash'
  end

  def create
    @credit_card = CreditCard.new(params[:credit_card])
        
    if @credit_card.valid?
      # set the proper chargify plan based on the user's subscription_type
      if params[:plan]
        unless %w{basic premium}.include?(params[:plan])
          params[:plan] = 'basic'
        end
        session[:plan] = params[:plan]
        plan = "#{params[:plan]}-subscription"
      else
        plan = case current_user.subscription.product
          when Subscription::BASIC_SUBSCRIPTION then 'basic-subscription'
          when Subscription::PREMIUM_SUBSCRIPTION then 'premium-subscription'
        end
      end

      @plan = plan.split('-')[0]

      # create the subscription using the subscription manager
      @subscription = Subscription.create_subscription(
              current_user,
              plan,
              @credit_card)

      if !@subscription.errors.errors.empty?
        session[:cc] = @credit_card
        session[:subscription] = @subscription
        if request.xhr?
          @errors = @subscription.errors.full_messages
          @errors = @errors.join(",").gsub("Credit card: cannot be expired.","Invalid card information. Please re-enter.").split(",")
          @errors = @errors.join(",").gsub("Credit card number: must be a valid credit card number.","Invalid card information. Please re-enter.").split(",")
          render :update do |page|
            page.replace_html("errors", :partial => "layouts/flash_errors")
          end
        else
          redirect_to new_subscription_path
        end
      else
        Subscription.create(  :user_id => current_user.id, 
                              :state => @subscription.state, 
                              :product =>plan.split('-')[0], 
                              :chargify_id => @subscription.id)
        @current_user.reload
        session[:subscription_plan] = session[:plan]
        session.delete(:plan)
        unless session[:upgrade] == true
          if request.xhr?
            render(:update) {|page| page.redirect_to(thank_you_path)}
          else
            redirect_to thank_you_path
          end
        else
          flash[:info] = 'Congratulations! Your plan has been updated!'
          if request.xhr?
            render(:update) {|page| page.redirect_to(workouts_path)}
          else
            redirect_to workouts_path
          end
        end
          
      end
    else
      session[:cc] = @credit_card
      if request.xhr?
        @errors = @credit_card.errors.full_messages
        @errors = @errors.join(",").gsub("Credit card: cannot be expired.","Invalid card information. Please re-enter.").split(",")
        @errors = @errors.join(",").gsub("Credit card number: must be a valid credit card number.","Invalid card information. Please re-enter.").split(",")        
        render :update do |page|
          page.replace_html("errors", :partial => "layouts/flash_errors")
        end
      else
        redirect_to new_subscription_path
      end
    end
  end

  def edit
    
  end

  def update
    if params[:_json]
      params[:_json].uniq.each do |sub_id|
        Subscription.send_later(:check_subscription, sub_id)
      end
      render :text => 'thanks for the update'
    else
      sub = @current_user.subscription
      old_product = sub.product
      new_product = params[:product]
      # do migrations here....
      sub.migrate(new_product)
      if old_product == 'basic' && new_product == 'premium'
        flash[:info] = "Thank you for upgrading to the premium subscription!"
      elsif old_product == 'premium' && new_product == 'basic'
        flash[:info] = 'Your account has been downgraded to the basic subscription.'
      end
      redirect_to workouts_path
    end
  end

  def destroy
    @current_user.subscription.unsubscribe
    flash[:info] = "Your account has been downgraded to a free account."
    redirect_to account_path
  end

end
