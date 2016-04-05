
class SessionsController < Devise::SessionsController

  # GET /resource/sign_in
   def new
     super
   end

  # POST /resource/sign_in
   def create
     super
   end

  # DELETE /resource/sign_out
   def destroy
     super
   end

  private
  def determine_layout
    #set a lyout variable for determining weather or not to set a layout in the application.html file.  If this variable is set to 
    #false (in individual controller instances), then the navbar and footer will not be displayed.
    @layout = false
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end

  protected
    def after_sign_up_path_for(resource)
      dashboard_user_path(current_user)
    end
    
    def after_sign_in_path_for(user)
      dashboard_user_path(current_user)
    end

    def after_update_path_for(resource)
      dashboard_user_path(current_user)
    end
end