class WelcomeController < ApplicationController
  ssl_allowed :index
  def index
    if !request.subdomains.empty? && request.subdomains.first == 'beta'
      redirect_to login_path
    else
      if !session[:uid]
        #@wait_list_user = WaitListUser.new
        #render :action => 'welcome/wait_list.html.haml', :layout => false
        render :action => 'welcome/splash.html.haml', :layout =>'splash'
      else
        redirect_to workouts_path
      end
    end
  end
  
  def create
    @wait_list_user = WaitListUser.new(params[:wait_list_user])
    if @wait_list_user.save
      Notifier.send_later(:deliver_waitlist_welcome, @wait_list_user)
      render(:update) do |page|
        page['wait_list_form'].update('Thank you for signing up!').addClassName('signed_up').removeClassName('error');
      end
    else
      render(:update) do |page|
        page['wait_list_form'].addClassName('error')
        page['errors'].update("The email address you entered isn't valid. Please try again").show();
      end
    end
  end
 
end
