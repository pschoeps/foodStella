class UsersController < ApplicationController
	def dashboard
		@recipe = current_user.recipes.build
		@recipes = current_user.recipes
	end

	def show
	end

	def calendar
		@recipes = current_user.recipes
		@calendar_title = Time.now.strftime("%B %d, %Y")
	end
end