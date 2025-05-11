module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session
      skip_before_action :verify_authenticity_token
      before_action :set_default_format
      before_action :authenticate_api_request

      private

      def set_default_format
        request.format = :json
      end

      def authenticate_api_request
        header = request.headers['Authorization']
        return render_unauthorized unless header

        token = header.split(' ').last
        decoded = JsonWebToken.decode(token)

        if decoded
          @current_user = User.find_by(id: decoded[:user_id])
          render_unauthorized unless @current_user&.api_token.present?
        else
          render_unauthorized
        end
      rescue ActiveRecord::RecordNotFound
        render_unauthorized
      end

      def current_user
        @current_user
      end

      def render_unauthorized(message = "Unauthorized")
        render json: {
          errors: [{
            status: '401',
            title: 'Unauthorized',
            detail: message
          }]
        }, status: :unauthorized
      end

      def render_not_found(message = "Resource not found")
        render json: {
          errors: [{
            status: '404',
            title: 'Not Found',
            detail: message
          }]
        }, status: :not_found
      end

      def render_error_response(errors)
        error_hash = {}
        
        errors.each do |field, messages|
          error_hash[field] = messages.is_a?(Array) ? messages.first : messages
        end

        render json: {
          errors: error_hash
        }, status: :unprocessable_entity
      end

      def render_success(data, status: :ok)
        render json: data, status: status
      end
    end
  end
end
