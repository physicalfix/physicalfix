class Notifier < ActionMailer::Base

  ###############################
  ## Trial Related Notifications
  ###############################

  def trial_expired_notification(recipient)
    recipients recipient.email
    from  "PhysicalFix <admin@physicalfix.com>"
    subject "Your PhysicalFix Trial Has Expired"
    body :account => recipient,
      :home_page => url_for(:host => "www.physicalfix.com", :controller => 'welcome', :action => 'index')
  end

  def freeby_notification(email_address, email_link, email_type, email_subject, email_body)
    recipients email_address
    from  "PhysicalFix <admin@physicalfix.com>"
    subject email_subject
    body :link => email_link,
      :type => email_type,
      :body_content => email_body
  end

  def basic_14_trial_signup_notification(recipient)
    recipients recipient.email
    from  "PhysicalFix <admin@physicalfix.com>"
    subject "Welcome to PhysicalFix"
    body :account => recipient
  end

  def basic_30_trial_signup_notification(recipient)
    recipients recipient.email
    from  "PhysicalFix <admin@physicalfix.com>"
    subject "Welcome to PhysicalFix"
    body :account => recipient
  end

  def premium_30_trial_signup_notification(recipient)
    recipients recipient.email
    from  "PhysicalFix <admin@physicalfix.com>"
    subject "Welcome to PhysicalFix"
    body :account => recipient
  end

  #############################################
  ## Signup, Reminder, and Other Notifications
  #############################################

  def premium_signup_notification(recipient)
    recipients recipient.email
    from  "PhysicalFix <admin@physicalfix.com>"
    subject "Welcome to PhysicalFix"
    today = Time.zone.now.to_date
    body :account => recipient,
      :start_date => (today + 1.week).beginning_of_week.strftime('%A %B %d, %Y'),
      :home_page => url_for(:host => "www.physicalfix.com", :controller => 'welcome', :action => 'index')
  end

  def basic_signup_notification(recipient)
    recipients recipient.email
    from  "PhysicalFix <admin@physicalfix.com>"
    subject "Welcome to PhysicalFix"
    body :account => recipient,
      :home_page => url_for(:host => "www.physicalfix.com", :controller => 'welcome', :action => 'index')
  end

  def free_signup_notification(recipient)
    recipients recipient.email
    from  "PhysicalFix <admin@physicalfix.com>"
    subject "Welcome to PhysicalFix"
    body :account => recipient,
      :home_page => url_for(:host => "www.physicalfix.com", :controller => 'welcome', :action => 'index')
  end

  def reminder_email(recipient)
    recipients recipient.email
    from  "PhysicalFix <admin@physicalfix.com>"
    subject "Your PhysicalFix workouts are ready!"
    body :account => recipient,
      :start_date => Time.zone.now.beginning_of_week.to_date.strftime('%A %B %d, %Y'),
      :home_page => url_for(:host => "www.physicalfix.com", :controller => 'workouts', :action => 'index')
  end

  def waitlist_welcome(recipient)
    recipients recipient.email_address
    from "PhysicalFix <support@physicalfix.com>"
    subject "Thank you for your interest in physicalfix.com"
  end

  def password_recovery(recipient, key)
    recipients recipient.email
    from  "PhysicalFix <admin@physicalfix.com>"
    subject "PhsyicalFix :: Password Recovery"
    body :account => recipient,
      :start_date => Time.zone.now.beginning_of_week.to_date.strftime('%A %B %d, %Y'),
      :link => reset_password_path(key, :only_path => false)
  end

  def login_nag_email(recipient, days_since_last_login)
    recipients recipient.email
    from  "PhysicalFix <admin@physicalfix.com>"
    subject "physicalfix.com reminders"
    body :account => recipient,
      :days => days_since_last_login,
      :home_page => url_for(:host => "www.physicalfix.com", :controller => 'welcome', :action => 'index')
  end

  def nag_email(recipient, nag)
    recipients recipient.email
    from  "PhysicalFix <admin@physicalfix.com>"
    subject "physicalfix.com reminders"
    body :account => recipient,
      :nags => nag,
      :home_page => url_for(:host => "www.physicalfix.com", :controller => 'welcome', :action => 'index')
  end

  def nag_digest_email(lazy_people)
    recipients ["podman@gmail.com", "jdz14@mac.com"]
    from  "PhysicalFix <admin@physicalfix.com>"
    subject "physicalfix.com Lazy People"
    body :lazy_people => lazy_people
  end
end
