module Authorization
  def request_with(user, http_method, action, parameters = {}, session = {}, flash = {} )
    warden.set_user user
    process action, method: http_method.to_s.upcase, params: parameters, session: session, flash: flash
  end

  [:get, :put, :post, :delete].each do |method|
    module_eval <<-EOV, __FILE__, __LINE__
      def #{method}_with(user, *args)
        request_with(user, #{method.inspect}, *args)
      end
    EOV
  end

  def render_with user, options = {}, local_assigns = {}, &block
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:authenticated?).and_return(true)
    render options, local_assigns, &block
  end
end

RSpec::configure do |c|
  c.include Authorization
end
