class RegistrationsController < ApplicationController
  def new
    redirect_to root_path, notice: "You are already logged in." if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      login(@user)
      redirect_to root_path, notice: "Account created successfully!"
    else
      flash.now[:alert] = "There was a problem creating your account."
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
