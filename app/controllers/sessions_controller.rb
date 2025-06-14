class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create]
  def new
    redirect_to root_path, notice: "You are already logged in." if logged_in?
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)
    
    if user&.authenticate(params[:password])
      login(user, params[:remember_me] == "1")
      redirect_to root_path, notice: "Logged in successfully"
    else
      flash.now[:alert] = "Invalid email/password combination"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to root_path, notice: "You have been logged out"
  end
end
