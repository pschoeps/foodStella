class ApplicationController < ActionController::Base
  before_filter :authenticate_user!, except: :temporary_preference
  before_filter :determine_layout

  def determine_layout
  	#set a lyout variable for determining weather or not to set a layout in the application.html file.  If this variable is set to 
  	#false (in individual controller instances), then the navbar and footer will not be displayed.
    @layout = true
    @user_agent = check_for_mobile ? "mobile" : "comp"
  end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #def after_sign_in_path_for(resource_or_scope)
  #  if request.env['omniauth.origin']
  #     request.env['omniauth.origin']
  #  else
  #    recipes_path
  #  end
  #end

  #appends the file path is the device is mobile
  def check_for_mobile
    #session[:mobile_override] = params[:mobile] if params[:mobile]
    prepare_for_mobile if mobile_device?
  end

  #alters the file path by redirecting to a different file tree locaed in app/views_mobile
  def prepare_for_mobile
    prepend_view_path Rails.root + 'app' + 'views_mobile'
  end
  
  #checks if the device is mobile
  def mobile_device?
    if session[:mobile_override]
      session[:mobile_override] == "1"
    else
      # Season this regexp to taste.
      (request.user_agent =~ /Mobile|webOS|iPhone|iPad/) 
    end
  end

end