module ApplicationHelper
  def nav_link(link_text, link_path, link_params={}, icon_name=nil)
    class_name = current_page?(link_path) ? 'active-link' : ''
    html = ""

    content_tag(:li, :class => class_name) do
      link_to link_path, link_params do
        html << icon(icon_name) unless icon_name.nil?
        html << link_text
        html.html_safe
      end
    end
  end

  def error_sidebar?
    controller_name == 'errors' && action_name == 'show'
  end

  def no_sidebar?
    controller_name == 'website_wizard'
  end

  def regular_sidebar?
    !error_sidebar? && !no_sidebar?
  end

  def app_domain
    # if this is a review app then we will use the heroku_app_name variable to build the domain
    if ENV.key?('HEROKU_APP_NAME')
      "#{ENV['HEROKU_APP_NAME']}.herokuapp.com"
    else
      ENV['APP_DOMAIN']
    end
  end
end
