# app/controllers/magic_links_controller.rb
class MagicLinksController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create verify]
  # This controller handles the magic link login flow.
  # It allows users to enter their email, and it sends a magic link,
  # and verifies that link to log them in.

  # The `authenticate_user!` method is typically defined in ApplicationController.
  # Here we skip it for the new and create actions so users can request a magic link
  # If you have a before_action that normally requires login, skip it here.

  def new
    # Renders a form where the user types their email.
  end

  def create
    user = User.find_by(email: params[:email].downcase.strip)
    if user
      # Invalidate any old tokens for this user (optional)
      MagicLinkToken.where(user: user).delete_all

      token_record = user.magic_link_tokens.create!
      MagicLinkMailer.with(token: token_record).send_link.deliver_now

      flash[:notice] = "Check your email for a login link. It expires in 15 minutes."
      redirect_to root_path
    else
      flash.now[:alert] = "No account found for that email."
      render :new, status: :unprocessable_entity
    end
  end

  # This action is reached when the user clicks the link in their email.
  def verify
    token = MagicLinkToken.find_by(token: params[:token])
    if token && !token.expired?
      session[:user_id] = token.user_id
      token.destroy
      redirect_to root_path, notice: "You’re now logged in!"
    else
      token&.destroy
      redirect_to new_magic_link_path, alert: "That link is invalid or has expired"
    end
  end
end
