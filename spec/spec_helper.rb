# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'

# Uncomment the next line to use webrat's matchers
#require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end
shared_examples_for "controllers" do
  def self.should_normally_succeed(&params_meth)
    should_have_response 200
  end

  def self.should_have_response(status, &params_meth)
    it "should be a #{status}" do
      params_meth ||= default_paramz
      @method ||= :get
      send @method.to_sym, @action, params_meth.call
      response.headers["Status"].to_i.should == status
    end
  end

  def self.should_succeed_with_format(format)
    it "should be a success with format #{format}" do
      params_meth ||= default_paramz
      @method ||= :get
      send @method.to_sym, @action, params_meth.call.merge(:format => format)
      response.should be_success
    end
  end

  def self.should_redirect(redirect_params=nil)
    it "should redirect" do
      params_meth ||= default_paramz
      @method ||= :get
      send @method.to_sym, @action, params_meth.call
      if redirect_params
        response.should redirect_to(redirect_params)
      else
        response.should be_redirect
      end
    end
  end

  def self.should_assign(name, val=nil, &params_meth)
    it "should assign #{name}" do
      params_meth ||= default_paramz
      @method ||= :get
      send @method.to_sym, @action, params_meth.call
      if val = instance_variable_get("@#{name}")
        val.should_not be_nil
        assigns(name.to_sym).should == val
      else
        assigns(name.to_sym).should_not be_nil
      end
    end
  end

    def self.should_paginate(name, opts={})
      it "should return the default number of #{name}" do
        pending if opts[:pending]
        count = V1::RestController::DEFAULT_LIMIT
        send "make_more_#{name}", count
        get 'index', paramz
        assigns(name.to_sym).size.should == count
      end

      it "should respect pagination args for #{name}" do
        pending if opts[:pending]
        count = V1::RestController::DEFAULT_LIMIT
        send "make_more_#{name}", count
        get 'index', paramz.merge(:limit => 2, :offset => 1)
        ivar = instance_variable_get("@#{name}")
        paginated = begin
                      ivar.find_visible_to(nil, :all, :limit => 2, :offset => 1)
                    rescue
                      paginated_meth(2, 1)
                    end
        assigns(name.to_sym).map(&:id).should == paginated.map(&:id)
      end

      it "should tell the total count for #{name} in the headers" do
        pending if opts[:pending]
        get 'index', paramz
        size = if ivar = instance_variable_get("@#{name}")
                 ivar.size
               else
                 name.classify.constantize.count
               end
        response.headers['Mbx-TotalCount'].should == size
      end

      it "should tell the offset in the headers" do
        pending if opts[:pending]
        get 'index', paramz
        response.headers['Mbx-Offset'].should == 0
      end
    end

  def self.should_400_without(param, &params_meth)
    should_have_response_without("400 Bad Request", param, params_meth)
  end

  def self.should_401_without(param, &params_meth)
    should_have_response_without("401 Unauthorized", param, params_meth)
  end

  def self.should_404_without(param, &params_meth)
    should_have_response_without("404 Not Found", param, params_meth) do |response|
      response.body.should =~ /#{param[/(.*)_id/, 1]}/
    end
  end

  def self.should_422_without(param, &params_meth)
    should_have_response_without("422 Unprocessable Entity", param, params_meth)
  end

  def self.should_have_response_without(resp, param, params_meth)
    it "should be #{resp} without #{param}" do
      params_meth ||= default_paramz
      @method ||= :get
      send @method.to_sym, @action, params_meth.call.merge(param.to_sym => nil)
      response.headers['Status'].should == resp
      yield response if block_given?
    end
  end

  def self.should_not_use_secure_filter(&params_meth)
    it "should not care about ssl" do
      params_meth ||= default_paramz
      @method ||= :get
      controller.should_receive(:go_to_insecure).never
      send @method.to_sym, @action, params_meth.call
    end
  end

  def self.should_use_secure_filter(&params_meth)
    it "should interveen if ssl request is made" do
      params_meth ||= default_paramz
      @method ||= :get
      controller.should_receive(:go_to_insecure).at_least(:once)
      send @method.to_sym, @action, params_meth.call
    end
  end

  # Store user in session to simulate logging in
  def login(user)
    request.session[:uid] = user.id
  end

  def default_paramz
    lambda { defined?(paramz) ? paramz : {} }
  end
end

class UseLayout
  attr_reader :expected
  attr_reader :actual

  def initialize(expected)
    @expected = 'layouts/' + expected
  end

  def matches?(controller)
    if controller.is_a?(ActionController::Base)
      @actual = 'layouts/' + controller.class.read_inheritable_attribute(:layout)
    else
      @actual = controller.layout
    end
    @actual ||= "layouts/application"
    @actual == @expected
  end

  def description
    "Determines if a controller uses a layout"
  end

  def failure_message
    return "use_layout expected #{@expected.inspect}, got #{@actual.inspect}"
  end

 def negeative_failure_message
   return "use_layout expected #{@expected.inspect} not to equal #{@actual.inspect}"
  end
end

def use_layout(expected)
  UseLayout.new(expected)
end