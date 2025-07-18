class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Devise configuration  
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  # Skip authentication for Devise controllers and specific public routes
  skip_before_action :authenticate_user!, if: :skip_authentication?
  
  private
  
  def skip_authentication?
    devise_controller? || controller_name == 'registrations' || controller_name == 'sessions'
  end
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email])
  end
end
