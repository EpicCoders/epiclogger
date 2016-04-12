module WebsiteWizardHelper
  def wizard_progress_bar
    content_tag(:div, class: 'steps') do
      content_tag(:ul) do
        wizard_steps.collect do |every_step|
          class_str = 'disabled'
          class_str = 'current'  if every_step == step
          class_str = 'disabled finished' if past_step?(every_step)
          step_url = '#'
          step_url = wizard_path(every_step) if every_step!=:create
          concat(
            content_tag(:li, class: class_str) do
              I18n.t(every_step)
            end
          )
        end
      end
    end
  end
end
