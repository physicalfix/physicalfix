class WeightTrackerController < ApplicationController
    before_filter :require_login
    before_filter :require_medical_history
    
    def index
      @user = current_user
      @stats = @user.weight_stats
      @graph = @user.weight_graph
      @annotations = {:weight => @graph[:images]}
       

      @options = {
        :annotations => @annotations,
        :scaleType => 'maximize',
        :zoomStartTime => Time.zone.now - 5.days,
        :allValuesSuffix => ' lbs',
        :allowHtml => true,
        :annotationsWidth => 15,
        :fill => 90,
        :wmode => 'opaque'

      }
    end
    
    def create
      unless params[:weight_tracker][:target_weight]
        params[:weight_tracker][:user_id] = current_user.id
        uw = UserWeight.new(params[:weight_tracker])
        if uw.valid?
          uw.save
          flash[:info] = "New Weight Recorded"
        else
          flash[:error] = "You can only enter your weight once a day"
        end
      else
        current_user.update_attribute(:target_weight, params[:weight_tracker][:target_weight])
      end
      
      redirect_to :action => "index"
    end

    def show
      @uw = UserWeight.find(params[:id])
    end
end
