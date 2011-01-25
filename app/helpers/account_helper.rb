module AccountHelper

  def label(name, obj, field)
    if obj.errors.on(field)
      haml_tag :p, {:class => 'type error'} do
        haml_concat name
        haml_tag :span, {:class => 'error'} do
          haml_concat "#{name} #{error_for(obj, field)}"
        end
      end
    else
      haml_tag :p, {:class => 'type'} do
        haml_concat name
      end
    end
  end

  def date_select_helper(c = nil)
    if !c
      date_select :user, :birthday, :order => [:month, :day, :year],
        :start_year => Date.current.year,
        :end_year => Date.current.year - 110, :prompt => true
    else
      c.date_select :expiration, {:order => [:month, :year], :user_month_numbers => true,
                                  :start_year => Time.now.year,
                                  :end_year => Time.now.year + 10}
    end
  end

  def time_zone_select_helper(f)
    f.time_zone_select :time_zone, ActiveSupport::TimeZone.us_zones, {:default => "Eastern Time (US & Canada)"}, {:style => 'width:290px'}
  end

end
