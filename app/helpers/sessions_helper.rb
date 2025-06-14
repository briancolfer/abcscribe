module SessionsHelper
  def logout
    Rails.logger.debug("#{Time.current}: Logout called")
    reset_session
    cookies.delete(:remember_token)
  end
end
