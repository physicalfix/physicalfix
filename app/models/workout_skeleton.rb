class WorkoutSkeleton < ActiveRecord::Base
  belongs_to :user_bucket
  has_many :workout_skeleton_musclegroups
  has_many :musclegroups, :through => :workout_skeleton_musclegroups
  has_many :workouts
  validates_presence_of :name
  validates_presence_of :description
  validates_associated :user_bucket
  
  def generate_workout(user, week)
    w = Workout.new
    w.user = user
    w.approved = true
    w.week_of = week.to_date
    w.workout_skeleton_id = self.id
    w.save

    states = []
    
    exercises = user_bucket.exercises(:include => :exercise_clips).group_by{|e| e.musclegroup_id}
    
    workout_skeleton_musclegroups.all(:order => 'display_order ASC').each do |mg|
      
      possible_exercises = exercises[mg.musclegroup_id]

      unless states[mg.musclegroup_id]
        states[mg.musclegroup_id] = {
                :current_index => rand(possible_exercises.length),
                :direction => rand(2) == 0 ? 1 : -1,
                :length => possible_exercises.length
        }
        current_state = states[mg.musclegroup_id]
      else
        current_state = states[mg.musclegroup_id]
        current_state[:current_index] += current_state[:direction]
      end

      equipment = user.equipment
      
      exercise_to_add = possible_exercises[current_state[:current_index]%current_state[:length]] #possible_exercises[rand(possible_exercises.length)] 
      
      until has_equipment?(exercise_to_add.name, equipment) do
        current_state[:current_index] += current_state[:direction]        
        exercise_to_add = possible_exercises[current_state[:current_index]%current_state[:length]]
      end
      
      possible_clips = exercise_to_add.exercise_clips.sort{|a,b| a.reps <=> b.reps}
      
      delay_time = 5
      
      if user.workout_difficulty
        if user.workout_difficulty == 'easy'
          possible_clips = possible_clips[0..((possible_clips.length-1)/2)]
          delay_time = 10
        elsif user.workout_difficulty == 'hard'
          possible_clips = possible_clips[(possible_clips.length/2)..possible_clips.length-1]
          delay_time = 5
        end
      end
      
      
      
      exercise_clip_to_add = possible_clips[rand(possible_clips.length)]
      
      wl = WorkoutList.new
      wl.workout = w
      wl.exercise = exercise_to_add
      wl.exercise_clip = exercise_clip_to_add
      wl.display_order = mg.display_order
      wl.delay_time = delay_time
      wl.save
      
    end
    
  end
  
  def has_equipment?(name, equipment)
    if name.include?('Dumbbell')
      has = equipment.include?('Dumbbell')
    elsif name.include?('Band')
      has = equipment.include?('Band')
    else
      return true
    end
  end
  
  def enough_equipment?(equipment)
    exercises = user_bucket.exercises(:include => :exercise_clips).group_by{|e| e.musclegroup_id}
    
    workout_skeleton_musclegroups.all(:order => 'display_order ASC').all? do |mg|
      possible_exercises = exercises[mg.musclegroup_id]
      
      possible_exercises.any? do |e|
        has_equipment?(e.name, equipment)
      end
      
    end
    
  end

end
