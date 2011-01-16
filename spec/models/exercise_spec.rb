require File.dirname(__FILE__) + '/../spec_helper'

describe Exercise do
  before(:each) do
    @exercise = Exercise.new
  end

  describe "A new exercise" do

    fixtures :musclegroups

  end

end