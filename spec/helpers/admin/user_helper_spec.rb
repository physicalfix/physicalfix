require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::UserHelper do
  describe "age" do
    it "should return 0 if no age passed" do
      helper.age(nil).should == 0
    end

    it "should return age if birthday passed" do
      helper.age(Time.zone.now - (24*366*24).hours).should == 24
    end

  end
end