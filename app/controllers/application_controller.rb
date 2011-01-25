# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all

  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '69105480e3ace40908364a80bc96bdd7'
  include SslRequirement

  before_filter :set_user_time_zone

  filter_parameter_logging "password", "card_number", "cvv"

  # TODO: needs major refactoring
  def current_user
    if session[:logged_in_as]
      if @current_user && @current_user.id != session[:logged_in_as]
        @current_user = User.find(session[:logged_in_as])
      else
        @current_user ||= User.find(session[:logged_in_as])
      end
    else
      if @current_user && @current_user.id != session[:user_id]
        @current_user = User.find(session[:uid])
      else
        @current_user ||= User.find(session[:uid])
      end
    end
  end

  def logout
    session.delete(:uid)
    session.delete(:logged_in_as)
    session.delete(:plan)
    redirect_to root_path
  end

  protected

    def get_experiences
      ["chest pains or chest pressure",
       "heart palpitations/skipped beats",
       "difficulty walking due to dizziness",
       "fainting",
       "seizures",
       "numbness or tingling",
       "excessive shortness of breath with exercise"]
    end

    def get_conditions
      ["heart disease",
       "diabetes",
       "heart murmur",
       "emphysema",
       "arrhythmia’s",
       "asthma",
       "circulatory problems",
       "chronic bronchitis",
       "high blood pressure",
       "neurological problems",
       "high cholesteral",
       "arthritis",
       "osteoporosis",
       "cancer"]
    end

    def get_equipment

      dumbbells = [
        '3lb Dumbbells',
        '5lb Dumbbells',
        '7.5lb Dumbbells',
        '8lb Dumbbells',
        '10lb Dumbbells',
        '12lb Dumbbells',
      '15lb Dumbbells']

      bands = [
        'Black Band',
        'Blue Band',
        'Red Band',
      'Orange Band']

      balls = [
        '5lb Medicine Ball',
        '10lb Medicine Ball',
        '12lb Medicine Ball' ,
        'Physioball',
      'Bosu Ball']

      bodybars = [
        '9lb Bodybar',
        '12lb Bodybar',
        '18lb Bodybar',
      '22lb Bodybar']

      machines = [
        'Stationary Bike',
        'Spin Bike',
        'Treadmill',
        'Elliptical',
        'Stairmaster',
      'Rowing Machine']

      others = [
        'Foam roller',
        'Half foam roller',
        'Workout Bench',
        'Stretch mat',
        'Jumprope',
      'Agility Cones']

      @equipment = {
        'Dumbbells' => dumbbells,
        'Bands' => bands,
        'Balls' => balls,
        'Bodybars' => bodybars,
        'Aerobic Equipment' => machines,
      'Misc. Equipment' => others}
    end

    def ssl_required?
      return false if local_request? || RAILS_ENV == 'development' || RAILS_ENV == 'test'
      super
    end

  private

    def logged_in?
      return !!session[:uid]
    end

    def set_user_time_zone
      return unless logged_in? && current_user && current_user.time_zone
      Time.zone = current_user.time_zone
    end

    def require_login
      case request.format
      when Mime::XML, Mime::JSON
        if u = authenticate_with_http_basic do |u, p|
            u = User.find_by_email(u)
            if u.password_is?(p)
              u
            else
              false
            end
          end
          session[:uid] = u.id
        else
          request_http_basic_authentication
        end
      else
        unless session[:uid]
          session[:return_to] = request.request_uri
          flash[:error] = "You need to be logged in to access this section of the site"
          redirect_to login_path
          return
        end
        if current_user.has_role?('Admin') && !request.request_uri.include?('/admin')
          redirect_to admin_path
        end
      end
    end

    def require_medical_history
      if current_user.medical_history.nil? &&
          current_user.subscription &&
          Subscription.premium?(current_user.subscription.product)
        redirect_to new_account_medical_history_path
      end
    end

    def require_paid_access
      if current_user.subscription.nil? ||
          Subscription.free?(current_user.subscription.product)
        redirect_to food_log_index_path
      end
      if current_user.subscription && Subscription.paid?(current_user.subscription.product) && current_user.subscription.state.nil?
        redirect_to new_subscription_path
      end
    end

end
