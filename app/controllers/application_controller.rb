class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :logged_in?, :current_user
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !!session[:user_id]
  end
end
