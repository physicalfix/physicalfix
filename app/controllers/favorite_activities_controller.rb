class FavoriteActivitiesController < ApplicationController
  before_filter :require_login

  def index
    @favorites = FavoriteActivity.find_all_by_user_id(current_user.id, :include => :activity)
  end

  def create
    #do nothing if the activity is already favorited
    if FavoriteActivity.find_by_user_id_and_activity_id(current_user.id, params[:id])
      render :text => ''
      return
    end
    
    FavoriteActivity.create(:activity_id =>params[:id], :user_id => current_user.id)

    @activity = Activity.find(params[:id])

    render :update do |page|
      page.replace_html("favorite-#{@activity.id}", :partial =>'activity_log/favorite_link', :object => @activity)
      page.replace_html("favoritetable", :partial => "activity_log/favorite", :collection => current_user.favorite_activities)
    end
  end

  def destroy

    fa = FavoriteActivity.find(params[:id])
    @activity = fa.activity
    fa.destroy
    unless params[:manage]
      render :update do |page|
       page.replace_html("favorite-#{@activity.id}", :partial =>'activity_log/favorite_link', :object => @activity)
       page.replace_html("favoritetable", :partial => "activity_log/favorite", :collection => current_user.favorite_activities)
      end
    else
      redirect_to :action => :index
    end

  end

end
