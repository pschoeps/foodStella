class ProfilesController < ApplicationController
	respond_to :html, :json

	def new
		@profile = current_user.build_profile
	end

	def create
		# if !profile_params[:picture_url] && current_user.image
			# profile_params[:picture_url] = current_user.image
			#OR# @profile.update_attribute(:picture_url, current_user.image)
		# end
		@profile = current_user.build_profile(profile_params)
		# @profile.fir_name = current_user.fir_name
		# @profile.las_name = current_user.las_name
		# @profile.username = current_user.username

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
	  if @profile.update_attributes(profile_params)
	  	if params[:profile][:username]
			current_user.update_attribute(:username, params[:profile][:username])
		end
	  	respond_with @profile.user
	  else
	  	render :edit
	  end
	end

	def index
	end

	def show
		@user = User.find(params[:id])
		@myself = @user.id == current_user.id ? true : false;

		# if !current_user.profile && params[:id].to_i == current_user.id
		if !@user.profile
			if @myself
				Profile.create!(user_id: current_user.id, fir_name: current_user.fir_name, las_name: current_user.las_name, username: current_user.username, email: current_user.email, picture_url: current_user.image, country: current_user.country)
				# redirect_to(:back) and return
			else
				flash[:notice] = 'User has not setup profile'
				redirect_to(:back) and return
			end
		end
		
		@profile = Profile.find_by_user_id(params[:id])
		if(params.has_key?(:tab))
			@tab = params[:tab]
		else
			@tab = 'about_me'
		end

		@editable = @myself
		@friends = @user.friends
		@others = User.find(:all, :conditions => ["id != ?", current_user.id])
		@pending = @myself? @user.pending_friends : []
		@requests = @myself? @user.requested_friends : []

		@preferred_ingredients = @user.preferred_ingredients

		#filtering links to model 
		@filterrific = initialize_filterrific(
		  User,
		  params[:filterrific],
		  :select_options => {
		    sorted_by:   User.options_for_sorted_by
		  }
		) or return

		# @others = @filterrific.find.page(params[:page])
		@filtered_users = User.filterrific_find(@filterrific) #.page(params[:page]) #.search_query

		@friends = @friends & @filtered_users
		@requests = @requests & @filtered_users
		@others = @others & @filtered_users- @friends - @requests

		respond_to do |format|
		  format.html
		  format.js
		end
	end

	def destroy
	end

	def profile_params
	  	params.require(:profile).permit(:fir_name, :las_name, :email, :about_me, :picture_url, :country, :cooking_experience, :average_cook_time, :liked_foods, :disliked_foods, :username, :cookware_preferences, :tab, :background_url, :background_offset, :show_full_name )
	end

end
