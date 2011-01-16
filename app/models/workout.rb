class Workout < ActiveRecord::Base
  has_many :workout_lists, :dependent => :destroy
  has_many :workout_sessions, :dependent => :destroy 
  belongs_to :user
  belongs_to :workout_skeleton
  
  has_many :exercises, :through => :workout_lists, :order => 'display_order', :dependent => :destroy 
  validates_presence_of :user_id, :week_of, :on => :create

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.workout do
      xml.id self.id
      xml.week_of self.week_of
      xml.completed self.completed
      xml.viewed self.viewed
      xml.total_length self.total_length
      xml.calories_burned self.calories_burned
      xml.note self.note
      if self.equipment
        xml.equipment do
          self.equipment.each do |item|
            xml.item item
          end
        end
      end

      xml.exercises do
        workout_lists.each do |wl|
          xml.exercise do
            xml.name wl.exercise.name
            xml.muscle_group wl.exercise.musclegroup.name
            xml.reps wl.exercise_clip.reps
            xml.weight wl.weight
            xml.delay wl.delay_time
          end
        end
      end
    end 
  end

  def completed
    count = 0
    workout_sessions.reject{|ws| ws.complete != true}.size
  end
  
  def viewed
    workout_sessions.size
  end
  
  def workout_exercises
    workout_lists.find(:all, :order => :display_order, :include => {:exercise => [:musclegroup, :exercise_clips]})
  end

  def duration(idx = -1)
    return total_length if idx == -1
    l = 0
    we = workout_exercises
    last = idx.to_i == -1 ? we.size : idx.to_i
    (0..(last - 1)).each do |i|   
      l += we[i].length if we[i] && we[i].length
    end
    return l
  end

  # calculate the number of calories burned for this workout
  # accepts an index so you can calculate through a given exercise in the workout
  # if the idx is -1 calculate for the whole length
  def calories_burned(idx = -1)
    l = duration(idx)
    (l/60.0) * 0.06051282051282 * user.current_weight
  end

  def equipment
    equipment = []
    workout_exercises.each do |e|
      n = e.exercise.name   
      equipment.push(e.weight + ' Lbs Dumbbells') if (!!n.index('Dumbbell')) && e.weight
      equipment.push('Dumbbells') if (!!n.index('Dumbbell')) && !e.weight
      equipment.push('Exercise Band') if (!!n.index('Band'))   
    end
    equipment.uniq
  end

  def total_length
    l = 0
    wl = WorkoutList.find_all_by_workout_id(self.id, :include => :exercise_clip)
    wl.each do |we|
      l += we.length
    end
    return l
  end
  
  def ready?
    we = workout_exercises
    r = !we.empty?
    return r && we.all?{|obj| obj.ready? } 
  end
end