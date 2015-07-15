module Devise
  module Strategies
    class Apikey < Authenticatable
      def valid?
        true
      end

      def authenticate!
        if params[:user]
          user = User.find_by_email(params[:user][:email])

          if user && user.encrypted_password == params[:user][:password]
            success!(user)
          else
            fail
          end
        else
          fail
        end
      end
    end
  end
end