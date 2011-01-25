# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def nav_tab(name, path, parent, con)
    if con.controller_name == parent
      haml_tag 'li', {:class =>'active'} do
        haml_concat link_to(name, path)
      end
    else
      haml_tag 'li' do
        haml_concat link_to(name, path)
      end
    end
  end

  def current_user
    return controller.current_user
  end

  def twitter_post
    if output = Rails.cache.read('twitter_post')
    else
      begin
        result = HTTParty.get('http://twitter.com/statuses/user_timeline/131044039.rss', :format=> :xml)['rss']['channel']['item'].first
        date = Time.parse(result['pubDate'])
        output = content_tag(:p, :class =>'quote') do
          "#{link_to(distance_of_time_in_words_to_now(date) + " ago", result['link'])} #{h(result['description'].split('physicalfix: ')[1])} #{content_tag(:p, link_to('Follow us on Twitter &#0187;', 'http://twitter.com/physicalfix'))}"
        end
      rescue
        output = content_tag(:p, link_to('Follow us on Twitter &#0187;', 'http://twitter.com/physicalfix'))
      end
      Rails.cache.write('twitter_post', output, :expires_in => 1.hour)
    end
    return output
  end

  def login_box
    output = '<div id="login_logout"><h3>'
    unless session[:uid].blank?
      output << 'Hello '
      output << User.find(session[:uid]).first_name
      output << '<em> '
      output << link_to("(Logout)", logout_path)
      output << '</em>'
    else
      output << '<em>Not logged in.</em> '
      output << link_to('Login', login_path)
    end
    output << '</h3></div>'
    output << '<div style="clear:both"></div>'
  end

  def split_time(seconds)
    min = (seconds.to_f / 60.0).floor
    sec = (seconds.to_f % 60.0).round
    output = "#{min} Min."
    output << "<br/>"
    output << "#{sec} Sec."
  end

  def short_split_time(seconds)
    min = (seconds.to_f / 60.0).floor
    sec = (seconds.to_f % 60.0).round
    output = "#{min}m "
    output << "#{sec}s"
  end

  def windowed_pagination_links(total_pages, current_page, options)
    link_to_current_page = options[:link_to_current_page]
    always_show_anchors = options[:always_show_anchors]
    padding = options[:window_size]

    html = ''

    #Calculate the window start and end pages
    padding = padding < 0 ? 0 : padding
    first = current_page  - padding > 0 ? current_page - padding : 1
    last = current_page + padding <= total_pages ? current_page + padding : total_pages

    # Print start page if anchors are enabled
    html << yield(1) if always_show_anchors and not first == 1

    # Print window pages
    first.upto(last) do |page|
      (current_page == page && !link_to_current_page) ? html << page : html << yield(page)
    end

    # Print end page if anchors are enabled
    html << yield(total_pages) if always_show_anchors and not last == total_pages
    html
  end

  def error_for(obj, field)

    return "" unless obj.errors.on(field)

    if obj.errors.on(field).class == Array
      return obj.errors.on(field)[0]
    else
      return obj.errors.on(field)
    end

  end
end
