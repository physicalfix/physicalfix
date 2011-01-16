require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::WorkoutsController do

  before do
    @admin_user = mock_model(User, :has_password? => true, :has_role? => true, :time_zone => 'UTC')
    session[:uid] = @admin_user.id
    User.stub!(:find).with(@admin_user.id).and_return(@admin_user)
  end

  describe "GET index" do
    it "should list all workouts if no user passed" do
      Workout.should_receive(:paginate)
      get :index
    end

    it "should list all workouts for a user if user passed" do
      Workout.should_receive(:paginate).with({:order => 'id DESC', :page => nil, :include => [:user, :workout_sessions], :conditions => ['user_id = ? and workout_skeleton_id IS NULL', "3"]})
      get :index, :user_id => 3
    end

    it "should list all approved workouts if approved passed in" do
      Workout.should_receive(:paginate).with({:conditions => ['approved = ? and workout_skeleton_id IS NULL', true], :order => 'id DESC', :page => nil, :include => [:user, :workout_sessions]})
      get :index, :approved => true
    end

    it "should list all unapproved workouts if unapproved passed in" do
      Workout.should_receive(:paginate).with({:conditions => ['approved = ? and workout_skeleton_id IS NULL', false], :order => 'id DESC', :page => nil, :include => [:user, :workout_sessions]})
      get :index, :unapproved => true
    end

    it "should list all completed workouts if completed passed in" do
      Workout.should_receive(:paginate).with({:conditions => 'comment IS NOT NULL and workout_skeleton_id IS NULL', :order => 'id DESC', :page => nil, :include => [:user, :workout_sessions]})
      get :index, :completed => true
    end

  end

  describe "GET new" do
    it "should create new workout" do
      Workout.should_receive(:new)
      get :new
    end

    it "should find user if passsed" do
      User.should_receive(:find).with("3")
      get :new, :user_id => 3
    end
  end

  describe "POST create" do

    before do
      @workout = mock_model(Workout, :save => true)
      Workout.stub!(:new).and_return(@workout)
      @paramz = {:date => {:year => 2009, :week => 20}, :workout => {}}
    end

    it "should create new workout" do
      Workout.should_receive(:new)
      post :create, @paramz
    end

    it "should render new template if create fails" do
      @workout.stub!(:save).and_return(false)
      post :create, @paramz
      response.should render_template(:new)
    end
    
    it "should redirect to edit if create passes" do
      post :create, @paramz
      response.should redirect_to(edit_admin_workout_path(@workout))
    end
  end

  describe "DELETE destroy" do

    before do
      @workout = mock_model(Workout, :destroy => true)
      Workout.stub!(:find).with(@workout.id.to_s).and_return(@workout)
    end

    it "should destroy workout" do
      @workout.should_receive(:destroy)
      delete :destroy, :id => @workout.id
    end
    
    it "should redirect to index" do
      delete :destroy, :id => @workout.id
      response.should redirect_to(admin_workouts_path)
    end
  end

  describe "GET edit" do
    before do
      @user = mock_model(User, :equipment => 'stuff', :time_zone => 'UTC')
      @workout = mock_model(Workout, :save => true, :user => @user)
      Workout.stub!(:find).and_return(@workout)
    end
    
    it "should get musclegroups" do
      Musclegroup.should_receive(:find).with(:all, :include => :exercises)
      get :edit, :id => @workout.id
    end

  end

  describe "PUT update" do

    before do
      @workout = mock_model(Workout, :update_attributes => true)
      Workout.stub!(:find).with(@workout.id.to_s).and_return(@workout)
    end

    it "should set week_of if date passed" do
      put :update, {:id => @workout.id, :date => {:year => 2009, :week => 20}}
      params[:workout][:week_of].should == Date.commercial(2009,20,1)
    end
    
    it "should set approved if approve passed" do
      put :update,{:id => @workout.id, :approve => 'true'}
      params[:workout][:approved].should == true
    end

    it "should update workout" do
      @workout.should_receive(:update_attributes)
      put :update, {:id => @workout.id}
    end

    it "should redirect to index if format is HTML" do
      put :update, {:id => @workout.id}
      response.should redirect_to(admin_workouts_path)
    end

    it "should render js if format is JS" do
      put :update, {:id => @workout.id, :format => 'js'}
      response.should render_template('admin/workouts/update')
    end
  end

  describe "GET show" do
    it "should redirect to edit" do
      @workout = mock_model(Workout)
      Workout.stub!(:find).with(@workout.id.to_s).and_return(@workout)
      get :show, :id => @workout.id
      response.should redirect_to(edit_admin_workout_path(@workout))
    end
  end

  describe "GET comment" do
    it "should get comment" do
      @workout = mock_model(Workout, :save => true, :user => @user, :comment => 'hi')
      Workout.stub!(:find).and_return(@workout)
      @workout.should_receive(:comment)
      get :comment, :id => @workout.id
    end
  end
  
  describe "GET record_note" do
    it "should assign workout_id" do
      @workout = mock_model(Workout)
      Workout.stub!(:find).and_return(@workout)
      get :record_note, :id => @workout.id
      assigns[:workout_id].should == @workout.id.to_s
    end
  end

end