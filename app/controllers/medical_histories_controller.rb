class MedicalHistoriesController < ApplicationController
  before_filter :require_login
  ssl_required :new, :create
  
  def new
    if !current_user.medical_history.nil?
      redirect_to account_path
    else
      @experience = get_experiences
      @conditions = get_conditions
      @errors = []

      @medical_history = MedicalHistory.new
      render :layout => 'splash'
    end
  end

  def create
    if  params[:medical_history][:experience]
      params[:medical_history][:experience].delete("")
      params[:medical_history][:experience] = params[:medical_history][:experience].join('|')
    end

    if params[:medical_history][:diagnose]
      params[:medical_history][:diagnose].delete("")
      params[:medical_history][:diagnose] = params[:medical_history][:diagnose].join('|')
    end

    params[:medical_history][:user_id] = current_user.id
    
    @medical_history = MedicalHistory.new(params[:medical_history])
    
    if  @medical_history.save
      flash[:info] = "Medical history updated."
      redirect_to workouts_path
    else
      @experience = get_experiences
      @conditions = get_conditions
      @errors = @medical_history.errors.full_messages
      @errors.sort! {|x,y| x.sub(/[A-z]+/,'').to_i <=> y.sub(/[A-z]+/,'').to_i}
      render :template => "/medical_histories/new.html.haml", :layout => 'splash'
    end
  end
end
