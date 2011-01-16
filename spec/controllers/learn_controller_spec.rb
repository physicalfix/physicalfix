require File.dirname(__FILE__) + '/../spec_helper'

describe LearnController do
  describe "GET about" do
    it "should work" do
      get :about
    end
  end
  
  describe "GET workouts" do
    it "should work" do
      get :workouts
    end
  end
  
  describe "GET nutrition" do
    it "should work" do
      get :nutrition
    end
  end
end