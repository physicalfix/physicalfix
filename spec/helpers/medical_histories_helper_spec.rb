require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include ApplicationHelper

describe MedialHistoriesHelper do
  fixtures :users
  before do
    @user = users(:valid_user)
    #init_haml_helpers
    helper.extend Haml
    helper.extend Haml::Helpers
    helper.send :init_haml_helpers
  end
  
  it "should return a regular p if there is no error" do
    helper.capture_haml{
      helper.label('test', @user, :name)
    }.should == "<p class='type'>\n  test\n</p>\n"
  end
  
  it "should return a p with an error if there is an error on the field" do
    @user.errors.add(:name, 'error')
    helper.capture_haml{
      helper.label('test', @user, :name)
    }.should == "<p class='type error'>\n  test\n  <span class='error'>\n    Name error\n  </span>\n</p>\n"
  end

end
