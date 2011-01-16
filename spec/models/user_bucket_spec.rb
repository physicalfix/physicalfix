require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserBucket do
   describe "enough_equipment?" do
     fixtures :user_buckets, :workout_skeletons
     
     it "should call enough_equipment? on each workout_skelton" do
       @ub = user_buckets(:big_bucket)
       @ub.workout_skeletons.each do |ws|
         ws.should_receive(:enough_equipment?)
       end
       @ub.enough_equipment?('')
     end
    
     it "should return true if the user has enough equipment" do
       @ub = user_buckets(:big_bucket)
        @ub.workout_skeletons.each do |ws|
          ws.stub!(:enough_equipment?).and_return(true)
        end
        @ub.enough_equipment?('').should == true
     end
     
     it "should return false if the user does not have enough equipment" do
       @ub = user_buckets(:big_bucket)
         @ub.workout_skeletons.each do |ws|
           ws.stub!(:enough_equipment?).and_return(false)
         end
         @ub.enough_equipment?('').should == false
     end
   end
  describe "needed_equipment" do
    fixtures :musclegroups, :exercises, :exercise_clips, :user_buckets, :user_bucket_exercises, :workout_skeletons, :workout_skeleton_musclegroups
    before do
      @ub = user_buckets(:big_bucket)
    end

    it "should return empty string if all equipment is present" do
      @ub.needed_equipment('Dumbbells').should be_empty
    end

    it "should return dumbbells or band if no equipment is present" do
      @ub.needed_equipment('').should == ['Exercise Band or Dumbbells']
    end

    it "should return dumbbells if needs dumbbells" do
      @ub = user_buckets(:dumbell_bucket)
      @ub.needed_equipment('Band').should == ['Dumbbells']
    end

  end
end