class RegistrationsController < Devise::RegistrationsController

  
  
  
  
  def create
   super
  end
  
  
  def edit

   end

   # def configure_permitted_parameters
   #    devise_parameter_sanitizer.for(:sign_up) {|u| 
   #      u.permit(:email, :password, :password_confirmation, :remember_me, 
   #      profile_attributes: [:email, :about_me])}
   # end

   private
   def determine_layout
     #set a lyout variable for determining weather or not to set a layout in the application.html file.  If this variable is set to 
     #false (in individual controller instances), then the navbar and footer will not be displayed.
     @layout = false
   end

  def sign_up_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :invite_token, :fir_name, :las_name, :location, :country)
  end

  def account_update_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :invite_token, :fir_name, :las_name, :location, :country)
  end
  
     protected
     
  def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :invite_token, :fir_name, :las_name, :location, :country)
  end
  
  
  
  protected
    def after_sign_up_path_for(resource)
      calendar_user_path(current_user)
    end
    
    def after_sign_in_path_for(user)
      calendar_user_path(current_user)
    end

    def after_update_path_for(resource)
      calendar_user_path(current_user)
    end
end