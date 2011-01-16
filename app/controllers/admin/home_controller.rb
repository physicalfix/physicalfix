class Admin::HomeController < AdminAreaController
  def index
    @title = 'Admin'
    @unwCount = User.users_needing_workouts.length
    ucd = User.new_users_month
    user_chart = GoogleChart.spark_line_100x30(ucd.join(","))
    user_chart.colors = "6699cc"
    @new_users_graph_url = user_chart.to_url + "&chds=" +ucd.min.to_s + "," + ucd.max.to_s + "&chf=bg,s,FFFFCC"

    wsd = WorkoutSession.workouts_started_month
    workouts_started_chart = GoogleChart.spark_line_100X30(wsd.join(","))
    workouts_started_chart.colors = "6699cc"
    @workouts_started_graph_url = workouts_started_chart.to_url + "&chds=" + wsd.min.to_s + "," + wsd.max.to_s + "&chf=bg,s,FFFFCC"
    
    wcd = WorkoutSession.workouts_completed_month
    workouts_completed_chart = GoogleChart.spark_line_100X30(wcd.join(","))
    workouts_completed_chart.colors = "6699cc"
    @workouts_completed_graph_url = workouts_completed_chart.to_url + "&chds=" + wcd.min.to_s + "," + wcd.max.to_s + "&chf=bg,s,FFFFCC"

    @recent_workouts = WorkoutSession.recently_completed
    @recent_foods = Meal.all(:conditions => ['created_at > ?', 1.week.ago], :order => 'created_at DESC', :include => :user)
    @recent_activities = UserActivity.all(:conditions => ['created_at > ?', 1.week.ago], :order => 'created_at DESC', :include => [:user, :activity])
    @recent_weights = UserWeight.all(:conditions => ['created_at > ?', 1.week.ago], :order => 'created_at DESC', :include => :user)
  end
end
