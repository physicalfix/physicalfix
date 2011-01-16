class AdminAreaController < ApplicationController
  before_filter :require_login, :require_admin
  layout 'application_back.html.erb'
  def require_admin
    unless current_user.has_role?('Admin')
      session[:return_to] = nil
      flash[:error] = 'You do not have access to that section of the site'
      redirect_to :controller => '/account', :action => 'index'
    end
  end
  
end