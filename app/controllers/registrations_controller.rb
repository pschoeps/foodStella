class RegistrationsController < Devise::RegistrationsController

  
  
  
  
  def create
   super
   # @user.build_profile(fir_name: @user.fir_name, las_name: @user.las_name, email: @user.email)
   # params.require(:profile).permit(:fir_name, :las_name, :email, :about_me, :picture_url, :country, :cooking_experience, :average_cook_time, :liked_foods, :disliked_foods, :username, :tab )
  end

  def 
  
  
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
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :invite_token, :fir_name, :las_name, :location, :country, :birthday)
  end

  def account_update_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :invite_token, :fir_name, :las_name, :location, :country, :birthday)
  end
  
     protected
     
  def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :invite_token, :fir_name, :las_name, :location, :country, :birthday)
  end
  
  
  
  protected
    def after_inactive_sign_up_path_for(resource)
      # new_user_confirmation_path
      new_session_path(resource_name)
    end

    def after_sign_up_path_for(resource)
      # calendar_user_path(current_user)
      recipes_path
    end
    
    def after_sign_in_path_for(user)
      # calendar_user_path(current_user)
      recipes_path
    end

    def after_update_path_for(resource)
      # calendar_user_path(current_user)
      recipes_path
    end
end