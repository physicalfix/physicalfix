require File.dirname(__FILE__) + '/../spec_helper'

describe WorkoutList do
  it "should have zero length" do
    @workout_list = WorkoutList.new
    @workout_list.length.should == 0
  end

  it "should not be ready if nothing set" do
    @exercise = mock_model(Exercise, :name => 'foo')
    @workout_list = WorkoutList.new
    @workout_list.stub!(:exercise).and_return(@exercise)
    @workout_list.should_not be_ready
  end

  it "should be ready if it only needs an exercise clip" do
    @exercise = mock_model(Exercise, :name => 'foo')
    @workout_list = WorkoutList.new(:exercise_clip_id => 25)
    @workout_list.stub!(:exercise).and_return(@exercise)
    @workout_list.should be_ready
  end

  it "should not be ready if the exercise requires a weight but doesn't have one" do
    @exercise = mock_model(Exercise, :name => 'Dumbbell Chest Fly')
    @workout_list = WorkoutList.new(:exercise_clip_id => 25)
    @workout_list.stub!(:exercise).and_return(@exercise)
    @workout_list.should_not be_ready
  end

  it "should not be ready if the exercise requires a weight but doesn't have one" do
    @exercise = mock_model(Exercise, :name => 'Dumbbell Chest Fly')
    @workout_list = WorkoutList.new(:exercise_clip_id => 25, :weight => "")
    @workout_list.stub!(:exercise).and_return(@exercise)
    @workout_list.should_not be_ready
  end

  it "should be ready if the exercise requires a weight and has one" do
    @exercise = mock_model(Exercise, :name => 'Dumbbell Chest Fly')
    @workout_list = WorkoutList.new(:exercise_clip_id => 25, :weight => "10")
    @workout_list.stub!(:exercise).and_return(@exercise)
    @workout_list.should be_ready
  end

end

