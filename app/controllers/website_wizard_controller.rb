class WebsiteWizardController < ApplicationController
  include Wicked::Wizard
  steps :create, :choose_platform, :configuration

  def show
    case step
    when :create
      @website = Website.new
    when :configuration
      @website = current_website
      @tab = session[:install_tab] || @website.platform
    else
      @website = current_website
    end
    render_wizard
  end

  def update
    binding.pry
    case step
    when :create
      # @website = Website.new(website_params)
      @website = Website.new(website_params)
      @website.website_members.build(user: current_user, role: :owner)
      if @website.save
        set_website(@website)
        redirect_to next_wizard_path
        # render_wizard
      else
        render_step wizard_value(step)
      end
    when :choose_platform
      @website = current_website
      @website.platform = website_params[:platform]
      session[:install_tab] = params[:tab]
      render_wizard @website
    else
      @website = current_website
      render_wizard @website
    end
  end

  def finish_wizard_path
    binding.pry
    websites_path
  end

  private

  def website_params
    params.require(:website).permit(:domain, :title, :platform)
  end
end
