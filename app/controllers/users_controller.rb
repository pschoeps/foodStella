class UsersController < ApplicationController
   include MobileHelper
   before_action :check_for_mobile
	respond_to :html, :json

   def update
	@user = User.find(params[:id])
	if params[:user][:preferred_list]
		@user.update_attribute(:preferred_list, params[:user][:preferred_list])
	end
	if params[:user][:deferred_list]
		@user.update_attribute(:deferred_list, params[:user][:deferred_list])
	end
   	 #  	if params[:profile][:username]
   		# 	current_user.update_attribute(:username, params[:profile][:username])
   		# end
   	 #  	respond_with @profile.user
   	 #  else
   	 #  	render :edit
   	 #  end

   	# puts params[:user][:preferred_list]
   	# @user.preferred_list(params[:user][:preferred_list])
   	# respond_to do |format|
   	#   format.json
   	# end
   	# render 'show'
   	respond_with @user
   end

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
		gon.dayView = false
		if params[:zoom_level]
		  gon.zoomLevel = params[:zoom_level]
		else
		  gon.zoomLevel = 130
		end
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

		@expanded = ['none', 'none', 'none', 'none', 'none']

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
		if params[:week_counter] == nil
		  day = Date.today # Today's date
		else
		  week_counter = params[:week_counter].to_i
		  days = week_counter * 7
		  day = Date.today + days
		end
		@days_from_week = (day.at_beginning_of_week..day.at_end_of_week).map{|x| x}
		@week_subtitle = @days_from_week.first.strftime('%m/%-d') + " - " + @days_from_week.last.strftime('%m/%-d')
		@meal_types = [["Breakfast", "T00:00:00", "#f5b266", "breakfast"], ["Snack", "T00:30:00", "#bc9c63", "snack1"], ["Lunch", "T01:00:00", "#819800", "lunch"], ["Snack", "T01:30:00", "#bc9c63", "snack2"], ["Dinner", "T02:00:00", "#796c2d", "dinner"]]
	end

	def day_calendar
		gon.dayView = true
		@calendar = true
		@followed_recipes = current_user.following
		@user_recipes = current_user.recipes
		@recipes = @user_recipes + @followed_recipes

		@snacks = @user_recipes.where(:meal_type => "1") + @followed_recipes.where(:meal_type => "1")
		@side_dishes = @user_recipes.where(:meal_type => "2") + @followed_recipes.where(:meal_type => "2")
		@main_dishes = @user_recipes.where(:meal_type => "3") + @followed_recipes.where(:meal_type => "3")
		@desserts = @user_recipes.where(:meal_type => "4") + @followed_recipes.where(:meal_type => "4")
		@drinks = @user_recipes.where(:meal_type => "5") + @followed_recipes.where(:meal_type => "5")

		@expanded = ['none', 'none', 'none', 'none', 'none']

		day_counter = params[:day_counter]
		day = params[:day]

		#logic for mobile calendar view (weekly)
		if day_counter == nil && day == nil
		  @day = Date.today # Today's date
		elsif day_counter && day == nil
		  day_counter = params[:day_counter].to_i
		  @day = Date.today + day_counter
		elsif day_counter && day 
		  @day = params[:day].to_date + day_counter
		elsif day && day_counter == nil
			@day = params[:day].to_date
		else
		  @day = params[:day].to_date
		end

		gon.nextDay = @day + 1.days 
		gon.previousDay = @day - 1.days
		
		@days_from_week = (@day.at_beginning_of_week..@day.at_end_of_week).map{|x| x}
		user_events = current_user.events
		@events = user_events.where(:start_at => (@day.strftime + "T00:00:00")..(@day.strftime + "T:2:00:00"))
		@meal_types = [["Breakfast", "T00:00:00", "#f5b266", "breakfast"], ["Snack", "T00:30:00", "#bc9c63", "snack1"], ["Lunch", "T01:00:00", "#819800", "lunch"], ["Snack", "T01:30:00", "#bc9c63", "snack2"], ["Dinner", "T02:00:00", "#796c2d", "dinner"]]
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

	def python
		#require "rubypython"

		RubyPython.start(:python_exe => "python2.6")

		  sys = RubyPython.import("sys")
		  mod = RubyPython.import("do_work")
		 p mod
		  #sys.path.append("#{Rails.root}/lib")
		  #p "test"
		  render :text => mod.printy()

		RubyPython.stop # stop the Python interpreter

=begin

		#result = `python recommender.py params`
		#puts result

		python_cmd = Escape.shell_command(['python', "../lib/do_work.py"]).to_s
        system python_cmd
        render :text => python_cmd
=end

=begin
result = `python do_work.py foo bar`
puts result
render :text => result
=end
	end
end







