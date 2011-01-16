require File.dirname(__FILE__) + '/../spec_helper'

include Crypto

describe Crypto do
  describe "decrpty" do
    it "should decrypt text" do
      Crypto.decrypt('525c6e02d9f2dcb0897f7ac76b3d0f4d').should == 'asdf'
    end
  end
end