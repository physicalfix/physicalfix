require File.dirname(__FILE__) + '/../spec_helper'

describe Workout do

  describe "workout" do
    fixtures :workouts, :exercises, :exercises_workouts, :exercise_clips
    
    before(:each) do
      @workout = workouts(:started_workout)
      #create workout list because fixtures being dumb :\
      WorkoutList.create(
        :workout_id => @workout.id,
        :exercise_id => 1,
        :exercise_clip_id => 1,
        :weight => 20,
        :delay_time => 5
      )
    end

    it "should have total length" do
      @workout.total_length.should == 35
    end

    it "should be ready" do
      @workout.should be_ready
    end

    it "should have a duration" do
      @workout.duration(2).should == 35
    end

    it "should not be ready if an exercise uses a dumbbell but does not have a weight" do
      WorkoutList.create(
        :workout_id => @workout.id,
        :exercise_id => 2,
        :exercise_clip_id => 1,
        :delay_time => 5
      )
      @workout.should_not be_ready
    end

    it "should be ready if an exercise uses a dumbbell and has a weight" do
      WorkoutList.create(
        :workout_id => @workout.id,
        :exercise_id => 2,
        :exercise_clip_id => 1,
        :delay_time => 5,
        :weight => 20
      )
      @workout.should be_ready
    end

  end

  describe "to_xml" do
    fixtures :workouts, :exercises, :exercises_workouts, :exercise_clips, :musclegroups, :users, :user_weights
    it "should output xml" do
      @workout = workouts(:workout_for_this_week)
      @workout.to_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<workout>\n  <id>10</id>\n  <week_of>#{@workout.week_of.to_s}</week_of>\n  <completed>0</completed>\n  <viewed>0</viewed>\n  <total_length>105</total_length>\n  <calories_burned>15.3551282051281</calories_burned>\n  <note></note>\n  <equipment>\n    <item>20 Lbs Dumbbells</item>\n  </equipment>\n  <exercises>\n    <exercise>\n      <name>Pushups</name>\n      <muscle_group>Chest</muscle_group>\n      <reps>15</reps>\n      <weight>20</weight>\n      <delay>5</delay>\n    </exercise>\n    <exercise>\n      <name>Pushups</name>\n      <muscle_group>Chest</muscle_group>\n      <reps>15</reps>\n      <weight>20</weight>\n      <delay>5</delay>\n    </exercise>\n    <exercise>\n      <name>Dumbbell</name>\n      <muscle_group>Chest</muscle_group>\n      <reps>15</reps>\n      <weight>20</weight>\n      <delay>5</delay>\n    </exercise>\n  </exercises>\n</workout>\n"
    end
  end

  describe "Completed Workout" do
    fixtures :workouts, :workout_sessions
    before(:each) do
      @workout = workouts(:completed_workout)
    end

    it "should have completed sessions" do
      @workout.completed.should == 1
    end
    
    it "should have viewed sessions" do
      @workout.viewed.should == 1
    end

  end
end

