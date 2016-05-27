class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  before_filter :determine_layout

  def determine_layout
  	#set a lyout variable for determining weather or not to set a layout in the application.html file.  If this variable is set to 
  	#false (in individual controller instances), then the navbar and footer will not be displayed.
    @layout = true
  end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource_or_scope)
   if request.env['omniauth.origin']
      request.env['omniauth.origin']
    end
end

end