class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    sign_in User.find_for_google_oauth2(request.env['omniauth.auth'])
    redirect_to root_path
  end

end
