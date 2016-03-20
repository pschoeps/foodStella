class UsersController < ApplicationController
	def dashboard
		@recipe = current_user.recipes.build
	end

	def show
	end
end
