class UsersController < ApplicationController
   include MobileHelper
   before_action :check_for_mobile

	def dashboard
		@recipe = current_user.recipes.build
		@recipes = current_user.recipes
		@profile = current_user.profile
	end

	def show
		redirect_to controller: 'profiles', action: 'show'
		@friends = current_user.friends
	end

	def index
		@users = User.all
	end

	def inbox
   		@users = User.all
  	end

  	def json_list
  		@recipes = Recipe.all
  		@stuff = @recipes.as_json

  		#@pretty_recipes = @recipes.to_json
  		#@render = JSON.pretty_generate(@recipes)
  		#@pretty_json = JSON.pretty_generate(@recipes)
  		
  		render :json => JSON.pretty_generate(@stuff)
    end

    def json_list_ing
    	@ing = Ingredient.all
  		@stuff = @ing.as_json

  		#@pretty_recipes = @recipes.to_json
  		#@render = JSON.pretty_generate(@recipes)
  		#@pretty_json = JSON.pretty_generate(@recipes)
  		
  		render :json => JSON.pretty_generate(@stuff)
  	end

  	def json_list_quant
  		@qua = Quantity.all
  		@stuff = @qua.as_json

  		#@pretty_recipes = @recipes.to_json
  		#@render = JSON.pretty_generate(@recipes)
  		#@pretty_json = JSON.pretty_generate(@recipes)
  		
  		render :json => @stuff
  	end

  	

	def calendar
		@calendar = true
		@followed_recipes = current_user.following
		@user_recipes = current_user.recipes
		@recipes = @user_recipes + @followed_recipes
		@events = current_user.events

		@snacks = @user_recipes.where(:meal_type => "1") + @followed_recipes.where(:meal_type => "1")
		@side_dishes = @user_recipes.where(:meal_type => "2") + @followed_recipes.where(:meal_type => "2")
		@main_dishes = @user_recipes.where(:meal_type => "3") + @followed_recipes.where(:meal_type => "3")
		@desserts = @user_recipes.where(:meal_type => "4") + @followed_recipes.where(:meal_type => "4")
		@drinks = @user_recipes.where(:meal_type => "5") + @followed_recipes.where(:meal_type => "5")

		@expanded = ['false','false','true','false','false']

		# @day_counter = 3

		d = Date.today
		@month = d.strftime("%B")
		# @week_begin = d.at_beginning_of_week.strftime("%-d")
		# @week_end = d.at_end_of_week.strftime("%-d")
		# @date_string = @month + " " + @week_begin + " - " + @week_end

		@planner_begin = d.strftime("%-d")
		# @planner_end = (d + (@day_counter-1).days).strftime("%-d")
		@planner_end = (d + (2).days).strftime("%-d")
		@date_string = @month + " " + @planner_begin + " - " + @planner_end

		@today = [DateTime.now.strftime('%A - %B %-d, %Y'), DateTime.now.strftime('%Y-%m-%d')]
		# @tomorrow = [DateTime.tomorrow.strftime('%A - %B %-d, %Y'), DateTime.tomorrow.strftime('%Y-%m-%d')]
		@tomorrow = [(DateTime.now + 1.days).strftime('%A - %B %-d, %Y'), (DateTime.now + 1.days).strftime('%Y-%m-%d')]
		@day_after_tom = [(DateTime.now + 2.days).strftime('%A - %B %-d, %Y'), (DateTime.now + 2.days).strftime('%Y-%m-%d')]

		@day_counter = 3



		#logic for mobile calendar view (weekly)
		today = Date.today # Today's date
		@days_from_this_week = (today.at_beginning_of_week..today.at_end_of_week).map



	end

	def add_day
		day_counter = params[:day_counter].to_i
		@new_day = [(DateTime.now + day_counter.days).strftime('%A - %B %-d, %Y'), (DateTime.now + day_counter.days).strftime('%Y-%m-%d')]
		new_day_counter = day_counter + 1
		current_user.update_attributes(:day_counter => new_day_counter)
		current_user.save!

		render :partial => 'users/one_day', :locals => { :day => @new_day }
    end

    def previous_day
		day_counter = params[:day_counter].to_i
		@new_day = [(DateTime.now - day_counter.days).strftime('%A - %B %-d, %Y'), (DateTime.now - day_counter.days).strftime('%Y-%m-%d')]

		render :partial => 'users/one_day', :locals => { :day => @new_day }
    end

    def shopping_list

    	@followed_recipes = current_user.following
		@user_recipes = current_user.recipes
		@recipes = @user_recipes + @followed_recipes
		@events = current_user.events

		@snacks = @user_recipes.where(:meal_type => "1") + @followed_recipes.where(:meal_type => "1")
		@side_dishes = @user_recipes.where(:meal_type => "2") + @followed_recipes.where(:meal_type => "2")
		@main_dishes = @user_recipes.where(:meal_type => "3") + @followed_recipes.where(:meal_type => "3")
		@desserts = @user_recipes.where(:meal_type => "4") + @followed_recipes.where(:meal_type => "4")
		@drinks = @user_recipes.where(:meal_type => "5") + @followed_recipes.where(:meal_type => "5")

		@expanded = ['false','false','false','false','false']

    	d = Date.today
		@month = d.strftime("%B")
		@week_begin = d.at_beginning_of_week.strftime("%-d")
		@week_end = d.at_end_of_week.strftime("%-d")
		@date_string = @month + " " + @week_begin + " - " + @week_end

		day_counter = params[:day_counter].to_i
		prev_day_counter = params[:prev_day_counter].to_i

		if prev_day_counter == 1
			@first_day = DateTime.now
		else
			subtracted_days = prev_day_counter - 1
			@first_day = DateTime.now - subtracted_days.days 
		end

		@last_day = DateTime.now + day_counter.days

		@events = Event.where(start_at: (@first_day)..@last_day)

		@planned_recipes = []
		@events.each do |e|
			puts "one event"
		  unless e.recipe_id < 0
		    recipe = Recipe.find(e.recipe_id)
		    @planned_recipes << recipe
		  end
		end

		@shopping_items = []

		@planned_recipes.each do |r|
			r.ingredients.each do |i|
				i.quantities.where(recipe_id: r.id).each do |q|
					unique_r = true
					@shopping_items.each do |s|
						if s[0] == i.name
							unique_r = false
							s[1] += q.ounces
						end
					end
					if unique_r
						unit = q.unit == '' ? '' : 'oz'
						@shopping_items << [i.name, q.ounces, 'oz.']
					end
				end
				# i.quantities.each do |q|
					# unit = get_unit(q.unit, q.amount)
					# @shopping_items << [i.name, q.amount, unit]
				# end
			end
		end

    end

    def get_unit(unit, amount)
    	string = case unit
                when "1"
                  if amount.to_i > 1
                  	"Cups"
                  else
                  	"Cup"
                  end
                when "2"
                  "Oz."
                when "3"
                  "Tsp."
                 when "4"
                 	"Tbsp."
                 when "5"
                 	if amount.to_i > 1
						"Pinches"
					else
                 		"Pinch"
					end
                end
      string
	end
end







