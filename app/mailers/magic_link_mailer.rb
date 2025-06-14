class MagicLinkMailer < ApplicationMailer
  default from: "no-reply@abcscribe.com"

  def send_link
    @token_record = params[:token]
    @user = @token_record.user
    @url  = verify_magic_link_url(@token_record.token)  # e.g. http://yourdomain.com/magic_links/XYZ123

    mail(to: @user.email, subject: "Your Abcscribe login link")
  end
end