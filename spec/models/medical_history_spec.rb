require File.dirname(__FILE__) + '/../spec_helper'

describe MedicalHistory do

  it "should have humanized attributes" do
    MedicalHistory.human_attribute_name(:p_name).should == "Question 1"
  end
end

