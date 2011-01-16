require File.dirname(__FILE__) + '/../spec_helper'

describe WorkoutSession do
  fixtures :workout_sessions

  it "should have started count" do
    WorkoutSession.workouts_started_month_count.should == 2
  end
  
  it "should have started array" do
    @zone = mock_model(ActiveSupport::TimeZone, :now => DateTime.parse('2009-10-12'))
    Time.stub!(:zone).and_return(@zone)
    WorkoutSession.stub!(:count).and_return(
      {'2009-10-06' => 2}
    )
    WorkoutSession.workouts_started_month.should == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0]
  end

  it "should have completed count" do
    WorkoutSession.workouts_completed_month_count.should == 1
  end

  it "should have completed array" do
    @zone = mock_model(ActiveSupport::TimeZone, :now => DateTime.parse('2009-10-12'))
    Time.stub!(:zone).and_return(@zone)
    WorkoutSession.stub!(:count).and_return(
      {'2009-10-07' => 1}
    )
    WorkoutSession.workouts_completed_month.should == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]
  end

  describe "#started_today" do
    it "should have one result if there is a workout session that was started today" do
      @ws = WorkoutSession.create(:workout_id => 1)
      WorkoutSession.started_today.should == [@ws] 
    end

    it "should have no results if there is a workout session for today but it is complete" do
      @ws = WorkoutSession.create(:workout_id => 1, :complete => true)
      WorkoutSession.started_today.should == []
    end

    it "should have no resutls if there are no workout sessions started today" do
      WorkoutSession.started_today.should == []
    end

  end

end

