class Admin::UsersController < AdminAreaController
  
  def index
    @title = 'Admin :: Users'

    if params[:unw] and params[:unw] == 'true'
      @users = User.users_needing_workouts
      @users = @users.paginate(:page => params[:page]) if @users
    elsif params[:user_search]
      name = "%#{params[:user_search]}%"
      order = params[:sort] ? "#{params[:sort]} #{params[:direction]}" : 'created_at DESC'
      @users = User.paginate(:page => params[:page], :order => order, :conditions => ["first_name like ? OR last_name like ? OR email like ?", name, name, name])
    else
      order = params[:sort] ? "#{params[:sort]} #{params[:direction]}" : 'created_at DESC'
      @users = User.paginate(:page => params[:page], :order => order)
    end
  end
  
  def show
    @user = User.find(params[:id])
    @title = "Admin :: Users :: #{@user.email}"
  end
  
  def medical_history
    @user = User.find(params[:id])
    @mh = @user.medical_history
    @title = "Admin :: Users :: #{@user.email} :: Medical History"
  end
  
end
