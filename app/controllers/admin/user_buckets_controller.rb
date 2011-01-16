class Admin::UserBucketsController < AdminAreaController
  def index
    @user_buckets = UserBucket.all(:order => 'display_order')
  end
  
  def show
    @user_bucket = UserBucket.find(params[:id])
    @musclegroups = Musclegroup.find(:all, :include => :exercises)
  end
  
  def new
    @user_bucket = UserBucket.new
  end
  
  def create
    @user_bucket = UserBucket.new(params[:user_bucket])
    if @user_bucket.save
      redirect_to admin_user_buckets_path
    else
      render :action => :new
    end
  end
  
  def edit
    @user_bucket = UserBucket.find(params[:id])
  end
  
  def update
    @user_bucket = UserBucket.find(params[:id])
    if @user_bucket.update_attributes(params[:user_bucket])
      redirect_to admin_user_buckets_path
    else
      render :action => :edit
    end
  end
  
  def destroy
    @user_bucket = UserBucket.find(params[:id])
    @user_bucket.destroy
    redirect_to admin_user_buckets_path
  end
  
end
