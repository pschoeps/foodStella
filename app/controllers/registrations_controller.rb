class RegistrationsController < Devise::RegistrationsController

  
  
  
  
  def create
   super
  end
  
  
  def edit

   end
   
  
     protected
     
  def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :invite_token)
  end
  
  
  
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