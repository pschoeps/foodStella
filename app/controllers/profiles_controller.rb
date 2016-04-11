class ProfilesController < ApplicationController

	def new
		# if current_user.provider == 'facebook'
			# create prefilled form from user's fb info
		# else
			@profile = current_user.build_profile
		# end
	end

	def create
		@profile = current_user.build_profile(profile_params)

		if @profile.save
		  redirect_to profile_path(current_user)
		  flash[:success] = "Profile Created"
		else
		  render 'new'
		end

	end

	def edit
	  @profile = Profile.find_by_user_id(params[:id])
	end

	def index
		unless current_user.profile
			redirect_to new_profile_path
		end
		@profile = current_user.profile
	end

	def show
		@profile = Profile.find_by_user_id(params[:id])
		@friends = profile.user.friends
	end

	def destroy
	end

	def profile_params
	  	params.require(:profile).permit(:fir_name, :las_name, :email, :about_me, :image_url, :country, :cooking_experience, :average_cook_time )
	end

end
