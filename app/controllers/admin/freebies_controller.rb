class Admin::FreebiesController < AdminAreaController

  def index
    @freebies = Freeby.all
  end

  def new
    @freeby = Freeby.new
    @basic_free = Subscription::BASIC_FREE_SUBSCRIPTION
    @premium_free = Subscription::PREMIUM_FREE_SUBSCRIPTION
    @basic_30 = Subscription::BASIC_30_TRIAL_SUBSCRIPTION
    @premium_30 = Subscription::PREMIUM_30_TRIAL_SUBSCRIPTION
  end

  def create
    email_subject = params[:subject]
    email_body = params[:body]
    if email_subject.empty?
      flash[:error] = "A subject is required."
      redirect_to :action => :new
      return
    end
    if email_body.empty?
      flash[:error] = "A body is required."
      redirect_to :action => :new
      return
    end
    @freeby = Freeby.new(params[:freeby])
    @freeby.key = SecureRandom.hex(10)
    @freeby.used = false
    if @freeby.save
      email_link = signup_url + "?k=#{@freeby.key}"
      email_type = @freeby.membership_type
      Notifier.deliver_freeby_notification(@freeby.email, email_link, email_type, email_subject, email_body)
      flash[:message] = "Your freebie has been created! An email was ssent to #{@freeby.email}."
      redirect_to admin_freebies_path
    else
      render :action => :new
    end
  end

end
