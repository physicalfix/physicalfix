class PasswordsController < ApplicationController
  ssl_required :edit, :new, :create, :update

  def new
    render :layout => 'sign_in'  
  end
  
  def create
    user = User.find_by_email(params[:email])
    if user
      key = Crypto.encrypt("#{user.id}:#{user.password_salt}")
      Notifier.deliver_password_recovery(user, key)
      flash[:info] = "Please check your email for instructions on how to reset your password"
      redirect_to root_path
     else
        flash[:error] ="An account with that email address could not be found";
        render :action => :new, :layout => 'sign_in'
     end
  end

  def edit
    if params[:id]
      begin
        key = Crypto.decrypt(params[:id]).split(/:/)
        @user = User.find(key[0], :conditions => {:password_salt => key[1]})
        session[:uid] = @user 
        flash[:info] = "Please change your password"
      rescue
        flash[:error] = "The recovery link you used is not valid. Please try resetting your password again."
        redirect_to root_path
      end
    else
      require_login
    end
  end
  
  def update
    if params[:id]
      begin
        key = Crypto.decrypt(params[:id]).split(/:/)
        @user = User.find(key[0], :conditions => {:password_salt => key[1]})
      rescue
        flash[:error] = 'Unauthorized Access'
        @user = nil
      end
    elsif params[:old_password]
      @user = current_user
      unless @user and @user.password_is?(params[:old_password])
        flash[:error] = 'Old Password is incorrect'
        @user = nil
      end
    end

    if @user and @user.update_attributes(params[:user])
      if params[:id]
        flash[:info] = "Your password has been successfully changed. You can now log in with your new password."
        redirect_to login_path
      else
        flash[:info] = "Your password has been successfully changed."
        redirect_to account_path
      end
    elsif @user == nil
      if params[:id]
        redirect_to root_path
      else
        render :action => :edit
      end
    else
      render :action => :edit
    end
  end
end
