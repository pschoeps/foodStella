class ProfilesController < ApplicationController

	def new
		@profile = current_user.build_profile
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
	end

	def destroy
	end

	def profile_params
	  	params.require(:profile).permit(:fir_name, :las_name, :email, :about_me, :picture_url, :country, :cooking_experience, :average_cook_time )
	end

end
