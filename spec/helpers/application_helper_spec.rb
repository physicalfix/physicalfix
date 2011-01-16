require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  include ActionView::Helpers::DateHelper
  include 
  before do
    helper.extend Haml
    helper.extend Haml::Helpers
    helper.send :init_haml_helpers
  end
  
  describe "split_time" do
    it "should set time" do
      helper.split_time(30).should == "0 Min.<br/>30 Sec."
    end
  end

  describe "login_box" do
    it "should display login box if not logged in" do
      helper.login_box().should =~ /Not logged in/
    end

    it "should display logout link if logged in" do
      @user = mock_model(User, :first_name => 'Adam', :time_zone => 'UTC')
      session[:uid] = @user.id
      User.stub!(:find).with(@user.id).and_return(@user)
      helper.login_box.should =~ /Logout/
    end
  end
  
  describe "nav_tav" do
   
   it "should be active if the parent is the current controller" do
     con = mock_model(ActionController, :controller_name => 'workouts')
     helper.capture_haml {
       helper.nav_tab('Workouts', workouts_path, 'workouts', con)
    }.should == "<li class='active'>\n  <a href=\"/workouts\">Workouts</a>\n</li>\n"
   end
   
   it "should not be active if the parent isn't the current controller" do
     con = mock_model(ActionController, :controller_name => 'food_log')
      helper.capture_haml {
        helper.nav_tab('Workouts', workouts_path, 'workouts', con)
     }.should == "<li>\n  <a href=\"/workouts\">Workouts</a>\n</li>\n"
   end
  end
  
  describe "twitter_post" do
    def twitter_result(date)
      {
        "rss" => { 
          "xmlns:atom" => "http://www.w3.org/2005/Atom", 
          "version" => "2.0", 
          "channel" => {
            "ttl" => "40", 
            "title" => "Twitter / physicalfix", 
            "language" => "en-us", 
            "atom:link" => {
              "href" => "http://twitter.com/statuses/user_timeline/83489584.rss", 
              "rel" => "self", 
              "type" => "application/rss+xml"
            }, 
            "link" => "http://twitter.com/physicalfix", 
            "description" => "Twitter updates from Josh Zitomer / physicalfix.", 
            "item" => [{
              "title" => "physicalfix: Strong back muscles help heal back pain faster and prevent injury-Don't neglect back strengthening/core exercises. 2-3 times per week.", 
              "pubDate" => date.strftime("%a, %d %b %Y %H:%M:S +0000"), 
              "guid" => "http://twitter.com/physicalfix/statuses/9052424741", 
              "description" => "physicalfix: Strong back muscles help heal back pain faster and prevent injury-Don't neglect back strengthening/core exercises. 2-3 times per week.", 
              "link" => "http://twitter.com/physicalfix/statuses/9052424741"
            }]}, 
          "xmlns:georss" => "http://www.georss.org/georss"
        }
      }
    end
    
    it "should check memcached" do
      Rails.cache.should_receive(:read).with('twitter_post').and_return('asdf')
      helper.twitter_post
    end
    
    it "should return result from memcached if there is something there" do
      Rails.cache.stub!(:read).and_return('asdf')
      helper.twitter_post.should == 'asdf'
    end
    
    it "should make an httparty request if memcached is empty" do
      Rails.cache.stub!(:write)
      Rails.cache.stub!(:read).and_return(nil)
      HTTParty.should_receive(:get).and_return(twitter_result(Time.zone.now.utc))
      helper.twitter_post
    end
    
    it "should return a pretty result if everything was good" do
      @date = Time.zone.now.utc
      Rails.cache.stub!(:write)
      Rails.cache.stub!(:read).and_return(nil)
      HTTParty.stub!(:get).and_return(twitter_result(@date))
      helper.twitter_post.should == "<p class=\"quote\"><a href=\"http://twitter.com/physicalfix/statuses/9052424741\">#{distance_of_time_in_words_to_now(@date - 4.hours)} ago</a> Strong back muscles help heal back pain faster and prevent injury-Don't neglect back strengthening/core exercises. 2-3 times per week. <p><a href=\"http://twitter.com/physicalfix\">Follow us on Twitter &#0187;</a></p></p>"
    end
    
    it "should recover gracefully" do
      Rails.cache.stub!(:write)
      Rails.cache.stub!(:read).and_return(nil)
      HTTParty.stub!(:get).and_raise('asf')
      helper.twitter_post.should == "<p><a href=\"http://twitter.com/physicalfix\">Follow us on Twitter &#0187;</a></p>"
    end
    
    it "should write the result to memcached" do
      Rails.cache.should_receive(:write).with('twitter_post', "<p><a href=\"http://twitter.com/physicalfix\">Follow us on Twitter &#0187;</a></p>", :expires_in => 1.hour)
      Rails.cache.stub!(:read).and_return(nil)
      HTTParty.stub!(:get).and_raise('asf')
      helper.twitter_post
    end
    
  end
  
  describe "short_split_time" do
    it "should output split times" do
      helper.short_split_time(89).should == '1m 29s'
    end
  end
  
  describe "windowed_pagination_links" do
    it "should output pagination stuff" do
      helper.windowed_pagination_links(29, 5, {:window_size => 2, :always_show_anchors => true, :link_to_current_page => true}){"asdf"}.should == 'asdfasdfasdfasdfasdfasdfasdf'
    end
  end
  
  describe "error_for" do
    fixtures :users
    it "should pick the first error if there are muliple errors on a field" do
      user = users(:valid_user)
      user.errors.add(:field, 'adf')
      user.errors.add(:field, 'bar')
      helper.error_for(user, :field).should == 'adf'
    end
  end
  
end