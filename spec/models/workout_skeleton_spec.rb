require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WorkoutSkeleton do
  fixtures :users, :musclegroups, :exercises, :exercise_clips, :user_buckets, :user_bucket_exercises, :workout_skeletons, :workout_skeleton_musclegroups
   describe "generate_workout" do
     
     before do
       @ws = workout_skeletons(:workout_skeleton_two)
       @u = users(:basic_user)
       @u.stub!(:equipment).and_return('5lb Dumbbells')
       @week = Time.zone.now.beginning_of_week.to_date
     end
     
     def generate_workout
       @ws.generate_workout(@u, @week)
       @u.reload
     end
     
     it "should generate a workout" do
       generate_workout
       @u.workouts.find_all_by_week_of(@week).size.should == 1
     end
     
     it "should only have exercises in the user bucket" do
        generate_workout
        workout = @u.workouts.find_by_week_of(@week)
        workout.workout_lists.each do |wl|
          @ws.user_bucket.exercises.should include(wl.exercise)
        end
     end
     
     it "should have workout exercises in the same order as the skeleton" do
       generate_workout
       workout = @u.workouts.find_by_week_of(@week)
       @ws.workout_skeleton_musclegroups.all do |wsmg|
         workout.workout_lists.find_by_display_order(wsmg.display_order).musclegroup.should == wsgm.musclegroup
       end
     end
     
     it "should only have exercises that match the users equipment" do
       generate_workout
       workout = @u.workouts.find_by_week_of(@week)
       workout.workout_lists.each do |wl|
         wl.exercise.name.should_not include('Band')
       end
     end
     
     it "should only have easy exercise clips if the user's workout difficultly is easy" do
       @u.stub!(:workout_difficulty).and_return('easy')
       generate_workout
       workout = @u.workouts.find_by_week_of(@week)
        workout.workout_lists.each do |wl|
          exercise_clips = wl.exercise.exercise_clips.all(:order => 'reps ASC')
          easy_clips = exercise_clips[0..((exercise_clips.length-1)/2)]
          easy_clips.should include(wl.exercise_clip)
        end
     end
     
     it "should only have hard exercise clips the the user's workout difficultly is hard" do
       @u.stub!(:workout_difficulty).and_return('hard')
       generate_workout
       workout = @u.workouts.find_by_week_of(@week)
        workout.workout_lists.each do |wl|
          exercise_clips = wl.exercise.exercise_clips.all(:order => 'reps ASC')
          hard_clips = exercise_clips[((exercise_clips.length)/2)..(exercise_clips.length-1)]
          hard_clips.should include(wl.exercise_clip)
        end
     end
     
     it "should have 10 second delays on the workout exercises if the user's workout difficulty is easy" do
       @u.stub!(:workout_difficulty).and_return('easy')
       generate_workout
       workout = @u.workouts.find_by_week_of(@week)
       workout.workout_lists.each do |wl|
        wl.delay_time.should == 10
       end
    end
     
     it "should have 5 second delays on the workout exercises if the user's workout difficulty is hard" do
       @u.stub!(:workout_difficulty).and_return('hard')
       generate_workout
       workout = @u.workouts.find_by_week_of(@week)
       workout.workout_lists.each do |wl|
         wl.delay_time.should == 5
       end
     end
     
   end
   
   describe "has_equipment?" do
     before do
       @ws = workout_skeletons(:workout_skeleton_one)
     end
     
     it "should return true if the needed equipment is in the equipment array" do
       @ws.has_equipment?('Dumbbell Chest Press', '15lb Dumbbell').should be_true
     end
     
     it "should return false if the needed equipment is not in the equipment array" do
       @ws.has_equipment?('Band Bicep Curl', '15lb Dumbbell').should be_false
     end
   end
   
   describe "enough_equipment?" do
     before do
       @ws = workout_skeletons(:workout_skeleton_two)
     end
     
     it "should return true if the user has enough equipment for the workout_skeleton" do
       @ws.enough_equipment?('15lb Dumbbells').should be_true
     end
     
     it "should return false if the user does not have enough equipment for the workout_skeleton" do
       @ws.enough_equipment?('cheese').should be_false
     end
   end
   
end