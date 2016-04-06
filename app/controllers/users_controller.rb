class UsersController < ApplicationController
	def dashboard
		@recipe = current_user.recipes.build
		@recipes = current_user.recipes
	end

	def show
	end

	def calendar
		@recipes = current_user.recipes
		@calendar_title = Time.now.strftime("%A")

		d = Date.today
		@month = d.strftime("%B")
		@week_begin = d.at_beginning_of_week.strftime("%-d")
		@week_end = d.at_end_of_week.strftime("%-d")
		@date_string = @month + " " + @week_begin + " - " + @week_end

	end
end