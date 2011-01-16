module Admin::UserHelper
  def age(birthday)
    unless birthday == nil
      ((Time.zone.now - birthday.to_time)/1.year).floor
    else
      0
    end
  end
end
