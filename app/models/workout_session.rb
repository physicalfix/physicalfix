class WorkoutSession < ActiveRecord::Base
  belongs_to :workout
  belongs_to :user

  named_scope :started_today, :conditions => ["workout_sessions.created_at between ? and ? and complete IS NULL", Time.zone.now.beginning_of_day, Time.zone.now.end_of_day], :include => {:workout => :user}


  named_scope :recently_completed, :conditions => ['updated_at > ? and complete = ?', Time.zone.now.utc - 1.week, true], :order => 'updated_at DESC'

  def self.workouts_started_month_count
    start = Time.zone.now.to_date - 1.month
    WorkoutSession.count(:conditions => ['created_at > ?', start.to_s(:db)])
  end
  
  def self.workouts_started_month
    start = Time.zone.now.to_date - 1.month
    dates = (start..Time.zone.now.to_date).to_a
    ws = WorkoutSession.count(:group => "DATE(created_at)", :conditions => ['created_at > ?', start.to_s(:db)])
    v = Hash.new
    dates.each do |d|
      v[d] = 0
      ws.each do |w, count|
        if d.to_s == w.to_s
          v[d] = count
        end
      end
    end
    v.sort.map{|x| x[1]}
  end
  
  def self.workouts_completed_month_count
    start = Time.zone.now.to_date - 1.month
     WorkoutSession.count(:conditions => ['updated_at > ? and complete = ?', start.to_s(:db), true])
  end
   
  def self.workouts_completed_month
    start = Time.zone.now.to_date - 1.month
    dates = (start..Time.zone.now.to_date).to_a
    ws = WorkoutSession.count(:group => "DATE(updated_at)", :conditions => ['updated_at > ? and complete = ?', start.to_s(:db), true])
    v = Hash.new
    dates.each do |d|
      v[d] = 0
      ws.each do |w, count|
        if d.to_s == w.to_s
          v[d] = count
        end
      end
    end
    v.sort.map{|x| x[1]}
  end
end
