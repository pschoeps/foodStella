class StaticPagesController < ApplicationController
  def home
  	if user_signed_in?
  		redirect_to calendar_user_path(current_user)
  	end
  end

  def temporary_preference
    token = "";
    if params[:token]
      token = params[:token]
    else
      token = SecureRandom.base58(24)
    end

    recipe = Recipe.find(params[:recipe_id])
    liked = params[:liked]
    recipe.user_preferences.build(liked: liked, token: token)

    @new_recipe = Recipe.order("RANDOM()").first
    @token = token
    @returned = [@new_recipe, @token]
    render :json => @returned
  end


  private
    def determine_layout
  	  #set a layout variable for determining weather or not to set a layout in the application.html file.  If this variable is set to 
  	  #false (in individual controller instances), then the navbar and footer will not be displayed.
      @layout = false
    end
end

