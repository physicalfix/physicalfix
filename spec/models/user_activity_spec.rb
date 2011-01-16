require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserActivity do 
  fixtures :users, :activities, :user_weights
  before(:each) do
    @valid_attributes = {  
      :user_id => 1,
      :activity_id => 1,
      :activity_date => DateTime.now,
      :duration => 10.0
    }
  end

  it "should create a new instance given valid attributes" do
    UserActivity.create!(@valid_attributes)
  end

  it "should calculate calories burned" do
    @ua = UserActivity.new
    @ua.user = users(:valid_user)
    @ua.activity = activities(:aerobics)
    @ua.duration = 60.0
    @ua.calories.should == 395
  end
  
  it "should calculate calories burned if not an acutal activity" do
    @ua = UserActivity.new
    @ua.user = users(:valid_user)
    @ua.calories_burned = 50
    @ua.duration = 60.0
    @ua.calories.should == 50
  end
  
  it "should return 0 if no calories_burned or no activity" do
    @ua = UserActivity.new
    @ua.user = users(:valid_user)
    @ua.calories.should == 0
  end

end
