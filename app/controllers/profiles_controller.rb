class ProfilesController < ApplicationController

	def new
		@profile = current_user.build_profile
	end

	def create
		# if !profile_params[:picture_url] && current_user.image
			# profile_params[:picture_url] = current_user.image
			#OR# @profile.update_attribute(:picture_url, current_user.image)
		# end
		@profile = current_user.build_profile(profile_params)

		if @profile.save
			# if !profile_params[:picture_url] && current_user.image
				# @profile.update_attribute(:picture_url, current_user.image)
			# end
		  redirect_to profile_path(current_user)
		  flash[:success] = "Profile Created"
		else
		  render 'new'
		end

	end

	def edit
		@profile = Profile.find(params[:id])
	end

	def update
	  @profile = Profile.find(params[:id])
	  @profile.update_attributes(profile_params)
	    respond_to do |format|
	      format.html  { redirect_to profile_path(current_user) }
	      flash[:success] =  "Profile Updated"
	  end
	end

	def index
		# @profile = Profile.find_by_user_id(params[:user_id])
		# @profile = Profile.find(params[:id])
		# @profiles = Profile.all
	end

	def show
		if !current_user.profile && params[:id].to_i == current_user.id
			redirect_to new_profile_path and return
		end

		@profile = Profile.find_by_user_id(params[:id])
		if(params.has_key?(:tab))
			@tab = params[:tab]
		else
			@tab = 'about_me'
		end

		@users = User.all
		@friends = current_user.friends
	end

	def destroy
	end

	def profile_params
	  	params.require(:profile).permit(:fir_name, :las_name, :email, :about_me, :picture_url, :country, :cooking_experience, :average_cook_time, :tab )
	end

end
