module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :logged_in?
  end

  private

  def current_user
    @current_user ||= begin
      if id = session[:user_id]
        User.find_by(id: id)
      elsif (token = cookies[:remember_token])
        # Find the user by remember token
        user = User.find_by(remember_token: token)
        if user&.remembered?
          # Log the user in in the session too
          session[:user_id] = user.id
          user
        end
      end
    end
  end

  def logged_in?
    current_user.present?
  end

  def authenticate_user
    unless logged_in?
      flash[:alert] = "Please log in to access this page"
      redirect_to login_path
    end
  end

  def login(user, remember_me = false)
    reset_session
    session[:user_id] = user.id
    if remember_me
      user.remember
      cookies[:remember_token] = {
        value: user.remember_token,
        expires: 2.weeks.from_now
      }
    end
  end

  def logout
    forget_user if current_user&.remembered?
    reset_session
    @current_user = nil
  end

  def forget_user
    current_user.forget
    cookies.delete(:remember_token)
  end
end

