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

  describe "days of week between" do
    it "should return number of occurences of a given day between a start date and an end date" do
      helper.days_of_week_between(1, "Feb 15, 2011".to_date, "Feb 14, 2011".to_date).should == 0
      helper.days_of_week_between(1, "Feb 16, 2011".to_date, "Feb 18, 2011".to_date).should == 0
      helper.days_of_week_between(1, "Feb 10, 2011".to_date, "Feb 15, 2011".to_date).should == 1
      helper.days_of_week_between(1, "Feb 14, 2011".to_date, "Feb 14, 2011".to_date).should == 1
      helper.days_of_week_between(1, "Jan 31, 2011".to_date, "Feb 8, 2011".to_date).should == 2
      helper.days_of_week_between(1, "Feb 9, 2011".to_date, "Aug 11, 2011".to_date).should == 26
    end
  end

end
