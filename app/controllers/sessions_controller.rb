class SessionsController < ApplicationController
  def create
  #   user = User.from_omniauth(env["omniauth.auth"])
  #   session[:user_id] = user.id
  #   redirect_to root_url
  auth = request.env["omniauth.auth"]
 #render :text=>'<pre>' + auth.to_yaml and return
  user = User.where(:provider => auth['provider'], 
                    :uid => auth['uid']).first || User.create_with_omniauth(auth)
  session[:user_id] = user.id
  session[:access_token] = auth.credentials.token
  redirect_to root_url, :notice => "Signed in!"
   end

  def destroy
  reset_session
  redirect_to root_url, notice => 'Signed out'
 end

end