require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe WorkoutHelper do
  
  describe "workout_class" do
    
    it "should return waiting if the workout hasn't been viewed" do
      workout = mock_model(Workout, :viewed => 0)
      helper.workout_class(workout).should == 'waiting'
    end
    
    it "should return incomplete if the workout has been viewed but not completed" do 
      workout = mock_model(Workout, :viewed => 1, :completed => 0)
      helper.workout_class(workout).should == 'incomplete'
    end
    
    it "should return completed if completed" do
      workout = mock_model(Workout, :viewed => 1, :completed => 1)
      helper.workout_class(workout).should == 'complete'
    end
    
  end
  
  describe "workout_state" do
    it "should return waiting if the workout hasn't been viewed" do
      workout = mock_model(Workout, :viewed => 0)
      helper.workout_state(workout).should == 'Ready'
    end
    
    it "should return incomplete if the workout has been viewed but not completed" do 
      workout = mock_model(Workout, :viewed => 1, :completed => 0)
      helper.workout_state(workout).should == 'Incomplete'
    end
    
    it "should return completed if completed" do
      workout = mock_model(Workout, :viewed => 1, :completed => 1)
      helper.workout_state(workout).should == 'Completed'
    end
  end
  
end
