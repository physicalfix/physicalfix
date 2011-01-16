require File.dirname(__FILE__) + '/../spec_helper'

describe ActivityLogHelper do
  describe "activity_class" do
    it "should return nil if not a specal case" do
      activity = mock_model(Activity, :name => 'foo')
      helper.activity_class(activity).should == nil
    end

    it "should return tdee if activity name is Daily Energy Expenditure" do
      activity = mock_model(Activity, :name => 'Daily Energy Expenditure')
      helper.activity_class(activity).should == 'tdee'
    end

    it "should return workout if activity name starts with workout" do
      activity = mock_model(Activity, :name => 'Workout started on that day')
      helper.activity_class(activity).should == 'workout'
    end
    
  end
end