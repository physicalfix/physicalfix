class Admin::UserBucketExercisesController < AdminAreaController
  def create
    @user_bucket = UserBucket.find(params[:user_bucket_id])
    @exercise = Exercise.find(params[:exercise_id])
    @user_bucket.exercises << @exercise
    render :partial => '/admin/user_buckets/exercise', :locals => {:list_exercise => @exercise}
  end
  
  def destroy
    @user_bucket_exercise = UserBucketExercise.find(params[:user_bucket_exercise_id])
    @user_bucket = @user_bucket_exercise.user_bucket
    @exercise =  @user_bucket_exercise.exercise
    @user_bucket_exercise.destroy
    render :partial => '/admin/user_buckets/exercise', :locals => {:list_exercise => @exercise}
  end
end
