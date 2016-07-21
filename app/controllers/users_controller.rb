class UsersController < ApplicationController
   include MobileHelper
   include ActionView::Helpers::TextHelper
   before_action :check_for_mobile
   before_filter :find_meals_and_events, :only => [:day_calendar, :calendar, :shopping_list]
   before_filter :get_user_recommended_recipes, :only => [:day_calendar, :calendar]
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
  		@layout = false
  		master_array = []
  		@recipes = Recipe.all
  		@recipes.each do |r|
  			list = {
  				"total_time": "#{r.prep_time + r.cook_time}",
  				"servings": "#{r.servings}",
  				"recipe_id": r.id,
  				"recipe_name": r.name,
  				"meal_type": get_meal_type(r.meal_type),
  				"prep_time": "#{r.prep_time}"

  			}
  			master_array << list
  		end
  		@array = master_array

  	

  		#@json = master_array.as_json

  		#@pretty_recipes = @recipes.to_json
  		#@render = JSON.pretty_generate(@recipes)
  		#@pretty_json = JSON.pretty_generate(@recipes)
  		
		#@json = JSON.pretty_generate(@json, :indent => "\t")
  		
  		#render :json => @json
    end

    def json_list_ing
    	@layout = false
    	@recipes = Recipe.all

  		@recipes.each do |r|
  			@ings = r.ingredients
  			@ings.each do |i|
  				@quants = i.quantities.where(recipe_id: r.id).each do |q|
  					list = {   :ingredient_id => "#{i.id}",
      				 	:recipe_id => r.id,
      					:detail => q.detail,
      					:quantity => "#{q.amount}",
      					:ingredient => i.name
    				}
  				end
  			end
  		end

  	end

  	def get_meal_type(typ)
    string = case typ 
                when "1"
                  "Snack"
                when "2"
                  "Side Dish"
                when "3"
                  "Main Dish"
                when "4"
                  "Dessert"
                when "5"
                  "Drink"
                # when "6"
                   # "Appetizer"
                end
    string
  end

  	def json_list_quant
  		@qua = Quantity.all
  		@stuff = @qua.as_json

  		#@pretty_recipes = @recipes.to_json
  		#@render = JSON.pretty_generate(@recipes)
  		#@pretty_json = JSON.pretty_generate(@recipes)
  		
  		render :json => @stuff
  	end

  	def find_meals_and_events
  		@followed_recipes = current_user.following
		@user_recipes = current_user.recipes
		@recipes = @user_recipes + @followed_recipes
		@events = current_user.events

		@snacks = @user_recipes.where(:meal_type => "1") + @followed_recipes.where(:meal_type => "1")
		@side_dishes = @user_recipes.where(:meal_type => "2") + @followed_recipes.where(:meal_type => "2")
		@main_dishes = @user_recipes.where(:meal_type => "3") + @followed_recipes.where(:meal_type => "3")
		@desserts = @user_recipes.where(:meal_type => "4") + @followed_recipes.where(:meal_type => "4")
		@drinks = @user_recipes.where(:meal_type => "5") + @followed_recipes.where(:meal_type => "5")
	end

	def get_user_recommended_recipes
		recommended_recipe_ids = []
		@recommended_recipes = []
		if @events.length != 0
		  @events.last(2).each do |event|
			recommended_recipe_ids << event.recipe_id
			@recommended_recipes << Recipe.find(event.recipe_id)
		  end
		end

		if @user_recipes.length != 0
		  @user_recipes.last(3) do |recipe|
		  	recommended_recipe_ids << recipe.id 
		  	@recommended_recipes << recipe
		  end
		end

		if recommended_recipe_ids.length == 0
			Recipe.last(5).each do |recipe|
			  recommended_recipe_ids << recipe.id 
			  @recommended_recipes << recipe
			end
		end
		@recommended_recipe_ids = recommended_recipe_ids
		puts "search for me"
		puts @recommended_recipes 
		@recommended_recipes.each do |r|
			puts r.name 
		end

	end

	def load_user_recommended_recipes
	  recommended_recipe_ids = params[:ids]
	  loader_counter = 0
	  recommended_recipe_ids.each do |r|
		response = HTTParty.get("https://sleepy-escarpment-10890.herokuapp.com/recommend?"+recipe_id+"")
		puts response.body
		response = response.body
		if response
      	  response.gsub!(/(\,)(\S)/, "\\1 \\2")
      	  array = YAML::load(response)
    	end
    	array.each do |response|
    	  puts "array first three"
    	  if Recipe.exists?(id: response.to_i)
            puts "the recipe exists"
            recipe = Recipe.find(response)
            pic = recipe.retrieve_pic
            friendly_name = recipe.get_friendly_name
            truncated_name = truncate(recipe.name, length: 30)
            ActionCable.server.broadcast "recommended_#{current_user.id}",
              recipe: recipe,
          	  pic: pic,
          	  recipe_class: "#{friendly_name}-#{recipe.id}",
          	  recipe_friendly_name: friendly_name,
          	  truncated_name: truncated_name,
          	  pic: pic

          	loader_counter += 1
          	puts "loader"
          	puts loader_counter

          	if loader_counter == 6
          	  return
          	end
      	  end

		end
	  end
	  respond_to do |format|
	  	format.js 
	  end
	end

	def calendar
		gon.dayView = false
		gon.user_id = current_user.id
		gon.recommended_recipe_ids = @recommended_recipe_ids
		if params[:zoom_level]
		  gon.zoomLevel = params[:zoom_level]
		else
		  gon.zoomLevel = 130
		end
		@calendar = true

		@expanded = ['none', 'none', 'none', 'none', 'none']


		if params[:week]
		  day = params[:week].to_date
		else
		  sorted_events = @events.sort_by &:start_at
		  last_day = sorted_events.last
		  if last_day
		    day = Date.parse(last_day.start_at)
		  else
		  	day = Date.today
		  end
		end

		gon.nextWeek = day + 7.days 
		gon.previousWeek = day - 7.days

		@month = day.strftime("%B")

		@planner_begin = day.strftime("%-d")
		# @planner_end = (d + (@day_counter-1).days).strftime("%-d")
		@planner_end = (day + (2).days).strftime("%-d")
		@date_string = @month + " " + @planner_begin + " - " + @planner_end

		@today = [DateTime.now.strftime('%A - %B %-d, %Y'), DateTime.now.strftime('%Y-%m-%d')]
	


		@days_from_week = (day.at_beginning_of_week..day.at_end_of_week).map{|x| x}
		@week_subtitle = @days_from_week.first.strftime('%m/%-d') + " - " + @days_from_week.last.strftime('%m/%-d')
		@meal_types = [["Breakfast", "T00:00:00", "#f5b266", "breakfast"], ["Snack", "T00:30:00", "#bc9c63", "snack1"], ["Lunch", "T01:00:00", "#819800", "lunch"], ["Snack", "T01:30:00", "#bc9c63", "snack2"], ["Dinner", "T02:00:00", "#796c2d", "dinner"]]

	end

	def day_calendar
		gon.user_id = current_user.id
		unless mobile_device?
		  gon.recipes_page = true
		end

		gon.recommended_recipe_ids = @recommended_recipe_ids

		gon.dayView = true
		@calendar = true

		@expanded = ['none', 'none', 'none', 'none', 'none']

		day_counter = params[:day_counter]
		day = params[:day]

		if params[:day]
			@day = params[:day].to_date
		else
		  sorted_events = @events.sort_by &:start_at
		  puts sorted_events.last
		  last_day = sorted_events.last
		  if last_day
		    @day = Date.parse(last_day.start_at)
		  else
		  	@day = Date.today
		  end
		end

		gon.nextDay = @day + 1.days 
		gon.previousDay = @day - 1.days
		
		@days_from_week = (@day.at_beginning_of_week..@day.at_end_of_week).map{|x| x}
		user_events = current_user.events
		@events = user_events.where(:start_at => (@day.strftime + "T00:00:00")..(@day.strftime + "T:2:00:00"))
		@meal_types = [["Breakfast", "T00:00:00", "#f5b266", "breakfast"], ["Snack", "T00:30:00", "#bc9c63", "snack1"], ["Lunch", "T01:00:00", "#819800", "lunch"], ["Snack", "T01:30:00", "#bc9c63", "snack2"], ["Dinner", "T02:00:00", "#796c2d", "dinner"]]
		#@layout = false
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

		@expanded = ['false','false','false','false','false']
		if params[:day]
		  	@day = params[:day].to_date
		  	puts "day here"
		  	puts @day
		else
		  @day = DateTime.now
		end

		if params[:view_type] == "day"
		  @events = Event.where(start_at: (@day.strftime + "T00:00:00")..(@day.strftime + "T:2:00:00"))
		  puts "events count"
		  puts @events.length
		  @date_string = @day.strftime("%A")
		elsif params[:view_type] == "week"

			@beginning_of_week = @day.at_beginning_of_week.to_datetime
			@end_of_week = @day.at_end_of_week.to_datetime

		 	@events = Event.where(start_at: (@beginning_of_week)..@end_of_week)

			@month = @day.strftime("%B")
			@week_begin = @day.at_beginning_of_week.strftime("%-d")
			@week_end = @day.at_end_of_week.strftime("%-d")
			@date_string = @month + " " + @week_begin + " - " + @week_end
		end


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
			    if s[2] == i.name
				  unique_r = false
				  s[3] += q.ounces
				  s[0] = get_fraction(s[3], s[4])
				end
			  end
			  if unique_r
				unit = q.unit == '' ? '' : 'oz'
				@shopping_items << [get_fraction(q.ounces, q.unit), get_unit(q.unit, q.amount), i.name, q.ounces, q.unit]
			  end
			end
		  end
		end
    end

    def get_fraction(oz, unit)
    	oz_in_unit = case unit
                when "1"
                  8
                when "2"
                  1
                when "3"
                  0.166
                 when "4"
                 	0.5
                 when "5"
                 	0.013
                 else
                 	1
                end
        amount = oz / oz_in_unit
        
		# rounded to nearest .25
		quarter = (amount*4).round / 4.0
		number = 1.23
		whole_num = quarter.to_s.split(".")[0]
		whole_num = '' if whole_num == '0'
		dec = quarter.to_s.split(".")[1]
		fraction = case dec
	            when "25"
	              '1/4'
	            when "5"
	              '1/2'
	            when "75"
	              '3/4'
	             else
	             	''
	            end
		if whole_num == ''
			string = fraction
		elsif fraction == ''
			string = whole_num
		else
			string = whole_num + ' ' + fraction
		end
		return string
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



		#RubyPython.start(:python_exe => "python2.6")
		RubyPython.start(:python_exe => "python2.6")

		  sys = RubyPython.import("sys")
		  mod = RubyPython.import("initial")
		  p mod
		  #sys.path.append("#{Rails.root}/lib")
		  #p "test"
		  render :text => mod

		RubyPython.stop # stop the Python interpreter


	

  		#@pretty_recipes = @recipes.to_json
  		#@render = JSON.pretty_generate(@recipes)
  		#@pretty_json = JSON.pretty_generate(@recipes)
  		


	

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




