class ProfilesController < ApplicationController

	def new
		@profile = current_user.build_profile
	end

	def create
		@profile = current_user.build_profile(profile_params)
	end

	def show
		@profile = Profile.find(params[:id])
		@friends = profile.user.friends
		@recipes = profile.user.recipes # && @followed_recipes
	end

	def destroy
	end

	def profile_params
	  	params.require(:profile).permit(:fir_name, :las_name, :email, :about_me, :image_url, :country, :cooking_experience, :average_cook_time )
	end

end
