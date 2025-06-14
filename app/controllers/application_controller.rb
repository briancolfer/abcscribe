class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Authentication
  include SessionsHelper

  before_action :authenticate_user!

  def authenticate_user!
    # Implement your authentication logic here.
    # For example, redirect unless session[:user_id] is present.
    redirect_to new_session_path unless session[:user_id]
  end
end
