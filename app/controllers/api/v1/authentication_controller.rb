module Api
  module V1
    class AuthenticationController < BaseController
      skip_before_action :authenticate_api_request, only: :create

      def create
        user = User.find_by(email: params[:email]&.downcase)
        
        if user&.authenticate(params[:password])
          token = user.generate_api_token
          render json: {
            data: {
              type: 'token',
              id: user.id.to_s,
              attributes: {
                token: token,
                email: user.email
              }
            }
          }, status: :created
        else
          render_unauthorized("Invalid email or password")
        end
      end

      def destroy
        current_user.invalidate_token
        head :no_content
      end
    end
  end
end

