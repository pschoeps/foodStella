class UsersController < ApplicationController
   include MobileHelper
   include ActionView::Helpers::TextHelper
   require 'json'
   before_action :check_for_mobile
   before_filter :find_meals_and_events, :only => [:day_calendar, :calendar, :shopping_list, :shuffle]
   before_filter :get_user_recommended_recipes, :only => [:day_calendar, :calendar]
   before_filter :get_shuffle_recommended_recipes, :only => [:day_calendar, :calendar]
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

  	def user_data
  		@layout = false
  		require 'json'
  		@users = User.all


	
		
  	    

  	   
  	end

  	def json_list_ing_basic
    	@layout = false
    	@ingredients = Ingredient.all 
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

  	def update_ingredients
  		require 'json'
  		new_file = File.open("categorized_ingredients.json", "r")
  		cal_file = File.open("calories.json", "r")

		#JSON.parse(new_file).each do |line|
		#	JSON.parse(line)
		#	new_line = line.as_json
		#	puts line.as_json	
		#	puts new_line["recipe_id"]	
		#end
		#new_file.to_json
		new_file.each do |line|

	        pos = line.split[2]
	        if pos 
	          new_pos = pos.delete(",").delete('\\"')
	        end
	        cat = line.partition('category').last.delete(":").delete("}").delete(',').delete('\\"')
	        cat[0] = ''
	        cat = cat.strip!

	        ing_id = new_pos.to_i 

	        if ing_id > 0 && Ingredient.find(ing_id)
	          ing = Ingredient.find(ing_id)
	          ing.update_attributes!(category: cat)
	          ing.save
	        end
	    end

	    cal_file.each do |line|
	      if line.length > 2
	        recipe_id = line.split[3].delete(",").to_i
	        recipe_calories = line.partition('calories').last.delete(":").delete("}").delete(',').delete(' ').delete('\\"').to_i
	        start_string = '\\"'
	        end_string = "abbreviated"
	        ing = line.partition('ingredient').last
	        ing_ing = ing.partition('ingredient').last 
	        ingy = ing_ing[/#{start_string}(.*?)#{end_string}/m, 1]
	        ingredientn =  ingy.delete(":").delete("}").delete(',').delete('\\"')
	        ingredientn[0] = ''
	        ingredient = ingredientn[0..-2]
	        puts ingredient

	        if Recipe.find(recipe_id)
	          recipe_and_ing = true
	          Recipe.find(recipe_id).ingredients.each do |ing|
	          	puts ing.name 
	          	puts ingredient
	          	puts ing.name.length
	          	puts ingredient.length
	          	if ing.name.to_s.squeeze == ingredient.to_s.squeeze
	              qua = Quantity.find_by_ingredient_id_and_recipe_id(ing.id, recipe_id)
	              ounces = qua.ounces
	              puts recipe_calories
	              puts "recipe_calories"
	              if recipe_calories != 0 && recipe_calories > 0 && ounces != 0 && ounces > 0
  	                updated_calories = (recipe_calories/ounces)
  	              else
  	              	updated_calories = 0
  	              end
  	              #uncomment these to update again
  	              ing.update_attributes!(calories: updated_calories)
  	              ing.save
	            end
	          	puts "search for a name"
	          end
	        end


	        puts " "
	        puts recipe_calories
	        puts ingredient 
	        puts recipe_id 
	        puts recipe_and_ing
	        puts " "

#	        if recipe_id && Recipe.find(recipe_id)
#	          rec_rec = Recipe.find(recipe_id)
#	          ings = rec_rec.ingredients
#	          if ings.where(:name => ingredient).last
#	            ing = ings.where(:name => ingredient).last 
#	            quant = Quantity.find_by_ingredient_id_and_recipe_id(ing.id, rec_rec.id)
#	            ounces = quant.amount
#	            updated_calories = (recipe_calories/ounces)
#	            puts updated_calories
#	            puts "search for me"
	            #ng.update_attributes!(calories: updated_calories)
#	            #ing.save
#	          end
#	        end
	        #recipe = Recipe.find(recipe_id)
	      end
	    end
	    @ingredients = Ingredient.all
	end

	def string_between_markers marker1, marker2
      self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
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

		# flag recommended events
		@recommended_events = []
		@events.each do |e|
			r = e.get_recipe(e.recipe_id)
			unless r.in?(@recipes)
				@recommended_events << e
			end
		end

		@snacks = @user_recipes.where(:meal_type => "1") + @followed_recipes.where(:meal_type => "1")
		@side_dishes = @user_recipes.where(:meal_type => "2") + @followed_recipes.where(:meal_type => "2")
		@main_dishes = @user_recipes.where(:meal_type => "3") + @followed_recipes.where(:meal_type => "3")
		@desserts = @user_recipes.where(:meal_type => "4") + @followed_recipes.where(:meal_type => "4")
		@drinks = @user_recipes.where(:meal_type => "5") + @followed_recipes.where(:meal_type => "5")
	end

	def get_user_recommended_recipes
		cap = 376
		recommended_recipe_ids = []
		@recommended_recipes = []
		if @events.length != 0
		  @events.where("recipe_id <= ?", cap).last(2).each do |event|
			recommended_recipe_ids << event.recipe_id
			@recommended_recipes << Recipe.find(event.recipe_id)
		  end
		end

		if @user_recipes.length != 0
		  @user_recipes.where("id <= ?", cap).last(3) do |recipe|
		  	recommended_recipe_ids << recipe.id 
		  	@recommended_recipes << recipe
		  end
		end

		if recommended_recipe_ids.length == 0
			Recipe.where("id <= ?", cap).last(5).each do |recipe|
			  recommended_recipe_ids << recipe.id 
			  @recommended_recipes << recipe
			end
		end
		@recommended_recipe_ids = recommended_recipe_ids
		puts "search for me"
		puts @recommended_recipes 
	end

	def get_shuffle_recommended_recipes
		cap = 376
		# ^^^^ cap must be increased once breakfasts have been added
		shuffle_recommended_recipe_ids = []
		@shuffle_recommended_recipes = []

		@followed_recipes = current_user.following
		@user_recipes = current_user.recipes
		# convert array back into activeRecord relation
		recipe_array = @user_recipes + @followed_recipes
		@recipes = Recipe.where(id: recipe_array.map(&:id))

		sample_count = 3

		# find 3 recipes of each type to use as the recommender's set
			# these categories aren't very accurate, a script to guess a meal type would be beneficial

		# breakfast = snack, side_dish
		breakfast_ids = []
		if @recipes.where("id <= ? AND meal_type IN (?)", cap, ['1','2']).length != 0
			@recipes.where("id <= ? AND meal_type IN (?)", cap, ['1','2']).order("RANDOM()").last(sample_count).each do |recipe|
				breakfast_ids << recipe.id
				shuffle_recommended_recipe_ids << recipe.id 
		  		@shuffle_recommended_recipes << recipe
		  	end
		end
		if breakfast_ids.length < sample_count
			count = sample_count - breakfast_ids.length
			Recipe.where("id <= ? AND meal_type IN (?)", cap, ['1','2']).order("RANDOM()").last(count).each do |recipe|
				shuffle_recommended_recipe_ids << recipe.id 
		  		@shuffle_recommended_recipes << recipe
		  	end
		end
		# morning snack = snack, side_dish
		morning_snack_ids = []
		# if @recipes.where("id <= ? AND meal_type IN (?)", cap, ['1','2']).length != 0
		# 	@recipes.where("id <= ? AND meal_type IN (?)", cap, ['1','2']).order("RANDOM()").last(sample_count).each do |recipe|
		# 		morning_snack_ids << recipe.id
		# 		shuffle_recommended_recipe_ids << recipe.id
		#   		@shuffle_recommended_recipes << recipe
		#   	end
		# end
		# if morning_snack_ids.length < sample_count
		# 	count = sample_count - morning_snack_ids.length
		# 	Recipe.where("id <= ? AND meal_type IN (?)", cap, ['1','2']).order("RANDOM()").last(count).each do |recipe|
		# 		shuffle_recommended_recipe_ids << recipe.id 
		#   		@shuffle_recommended_recipes << recipe
		#   	end
		# end
		# lunch = side_dish, main_dish
		lunch_ids = []
		if @recipes.where("id <= ? AND meal_type IN (?)", cap, ['2','3']).length != 0
			@recipes.where("id <= ? AND meal_type IN (?)", cap, ['2','3']).order("RANDOM()").last(sample_count).each do |recipe|
				lunch_ids << recipe.id
				shuffle_recommended_recipe_ids << recipe.id 
		  		@shuffle_recommended_recipes << recipe
		  	end
		end
		if lunch_ids.length < sample_count
			count = sample_count - lunch_ids.length
			Recipe.where("id <= ? AND meal_type IN (?)", cap, ['2','3']).order("RANDOM()").last(count).each do |recipe|
				shuffle_recommended_recipe_ids << recipe.id 
		  		@shuffle_recommended_recipes << recipe
		  	end
		end
		# afternoon snack = nsack, side_dish, dessert
		afternoon_snack_ids = []
		# if @recipes.where("id <= ? AND meal_type IN (?)", cap, ['1','2','4']).length != 0
		# 	@recipes.where("id <= ? AND meal_type IN (?)", cap, ['1','2','4']).order("RANDOM()").last(sample_count).each do |recipe|
		# 		afternoon_snack_ids << recipe.id
		# 		shuffle_recommended_recipe_ids << recipe.id 
		#   		@shuffle_recommended_recipes << recipe
		#   	end
		# end
		# if afternoon_snack_ids.length < sample_count
		# 	count = sample_count - afternoon_snack_ids.length
		# 	Recipe.where("id <= ? AND meal_type IN (?)", cap, ['1','2','4']).order("RANDOM()").last(count).each do |recipe|
		# 		shuffle_recommended_recipe_ids << recipe.id 
		#   		@shuffle_recommended_recipes << recipe
		#   	end
		# end
		# dinner = main_dish
		dinner_ids = []
		if @recipes.where("id <= ? AND meal_type IN (?)", cap, ['3']).length != 0
			@recipes.where("id <= ? AND meal_type IN (?)", cap, ['3']).order("RANDOM()").last(sample_count).each do |recipe|
				dinner_ids << recipe.id
				shuffle_recommended_recipe_ids << recipe.id 
		  		@shuffle_recommended_recipes << recipe
		  	end
		end
		if dinner_ids.length < sample_count
			count = sample_count - dinner_ids.length
			Recipe.where("id <= ? AND meal_type IN (?)", cap, ['3']).order("RANDOM()").last(count).each do |recipe|
				shuffle_recommended_recipe_ids << recipe.id 
		  		@shuffle_recommended_recipes << recipe
		  	end
		end
		  	
		@shuffle_recommended_recipe_ids = shuffle_recommended_recipe_ids
	end

	def load_user_recommended_recipes
	  recommended_recipe_ids = params[:ids]
	  loader_counter = 0
	  recommended_recipe_ids.each do |r|
		response = HTTParty.get("https://sleepy-escarpment-10890.herokuapp.com/recommend?recipe="+r+"")
		puts response.body
		response = response.body
		if response
      	  response.gsub!(/(\,)(\S)/, "\\1 \\2")
      	  array = YAML::load(response)
    	end
    	array.each do |response|
    	  if Recipe.exists?(id: response.to_i)
            puts "the recipe exists"
            recipe = Recipe.find(response)
            pic = recipe.retrieve_pic
            friendly_name = recipe.get_friendly_name
            truncated_name = truncate(recipe.name, length: 30)
            truncated_name_small = truncate(recipe.name, length: 15)
            ActionCable.server.broadcast "recommended_#{current_user.id}",
              recipe: recipe,
          	  pic: pic,
          	  recipe_class: "#{friendly_name}-#{recipe.id}",
          	  recipe_friendly_name: friendly_name,
          	  truncated_name: "#{truncated_name}",
          	  truncated_name_small: truncated_name_small

          	loader_counter += 1
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
		gon.shuffle_recommended_recipe_ids = @shuffle_recommended_recipe_ids
		if params[:zoom_level]
		  gon.zoomLevel = params[:zoom_level]
		else
		  gon.zoomLevel = 130
		end
		@calendar = true

		@expanded = ['none', 'none', 'none', 'none', 'none']

		gon.week
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
		@week_begin = day.at_beginning_of_week.strftime("%-d")
		@week_end = day.at_end_of_week.strftime("%-d")
		@date_string = @month + " " + @week_begin + " - " + @week_end

		@today = [DateTime.now.strftime('%A - %B %-d, %Y'), DateTime.now.strftime('%Y-%m-%d')]
	
		gon.start_day = day.at_beginning_of_week

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
    	gon.dayView = false
		gon.user_id = current_user.id

		#@layout = false

		@expanded = ['false','false','false','false','false']
		if params[:day]
		  	@day = params[:day].to_date
		  	puts "day here"
		  	puts @day
		else
		  @day = DateTime.now
		end

		if params[:view_type] == "day"
		  @events = current_user.events.where(start_at: (@day.strftime + "T00:00:00")..(@day.strftime + "T:2:00:00"))
		  puts "events count"
		  puts @events.length
		  @date_string = @day.strftime("%A")
		elsif params[:view_type] == "week"

			@beginning_of_week = @day.at_beginning_of_week.to_datetime
			@end_of_week = @day.at_end_of_week.to_datetime

		 	@events = current_user.events.where(start_at: (@beginning_of_week)..@end_of_week)

			@month = @day.strftime("%B")
			@week_begin = @day.at_beginning_of_week.strftime("%-d")
			@week_end = @day.at_end_of_week.strftime("%-d")
			@date_string = @month + " " + @week_begin + " - " + @week_end
		end


		@planned_recipes = []
		@custom_recipes = []
		@total_recipes = []

		@events.each do |e|
			puts "one event"
		  unless e.recipe_id < 0
		    recipe = Recipe.find(e.recipe_id)
		    if e.servings && e.servings.to_i != recipe.servings
		      @custom_recipes << [recipe, e.servings]
		      @total_recipes << recipe
		    else
		      @planned_recipes << recipe
		      @total_recipes << recipe
		    end
		  end
		end

		@shopping_items = []
		@categories = get_categories
		puts @categories


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

				@categories.each do |cat|
				  if i.category
					  if i.category.chomp == cat[0].chomp
					    cat[1] << [get_fraction(q.ounces, q.unit), get_unit(q.unit, q.amount), i.name, q.ounces, q.unit]
					  elsif i.category == nil
					  	 @categories[0][1] << [get_fraction(q.ounces, q.unit), get_unit(q.unit, q.amount), i.name, q.ounces, q.unit]
					  	 @categories.each do |cat|
					  	 	cat[1].uniq!
					     end
				  	  end
				   else
				     @categories[0][1] << [get_fraction(q.ounces, q.unit), get_unit(q.unit, q.amount), i.name, q.ounces, q.unit]
				  	   @categories.each do |cat|
				  	     cat[1].uniq!
				  	 end
				   end
				end
			  end
			end
		  end
		end

		@custom_recipes.each do |r|
		  r[0].ingredients.each do |i|
			i.quantities.where(recipe_id: r[0].id).each do |q|
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
				one_serving = (q.ounces / r[0].servings.to_i)
				new_serving = (one_serving * r[1].to_i)

				@categories.each do |cat|
					puts i.id
				  if i.category
					  if i.category == cat[0]
					    cat[1] << [get_fraction(new_serving, q.unit), get_unit(q.unit, q.amount), i.name, q.ounces, q.unit]
					  elsif i.category == nil
					  	 @categories[0][1] << [get_fraction(new_serving, q.unit), get_unit(q.unit, q.amount), i.name, q.ounces, q.unit]
					  	 @categories.each do |cat|
					  	 	cat[1].uniq!
					  	 end
					  end
				  else
				  	@categories[0][1] << [get_fraction(new_serving, q.unit), get_unit(q.unit, q.amount), i.name, q.ounces, q.unit]
				  	 @categories.each do |cat|
				  	 	cat[1].uniq!
				  	 end
				  end
				end
			  end
			end
		  end
		end
    end

    def shuffle
   	  recommended_recipe_ids = params[:ids]
	  loader_counter = 0
	  @shuffled_events = []
	  
	  if params[:start_day]
	    day = Date.parse(params[:start_day])
	  else
	  	day = Date.today
	  end

	  @month = day.strftime("%B")
	  @week_begin = day.at_beginning_of_week.strftime("%-d")
	  @week_end = day.at_end_of_week.strftime("%-d")

	  # @meal_types = [["Breakfast", "T00:00:00", [1,2]], ["Snack", "T00:30:00", [1,2]], ["Lunch", "T01:00:00", [2,3]], ["Snack", "T01:30:00", [1,2,4]], ["Dinner", "T02:00:00", [3]]]
	  # exclude snacks
	  @meal_types = [["Breakfast", "T00:00:00", [1,2]], ["Lunch", "T01:00:00", [2,3]], ["Dinner", "T02:00:00", [3]]]

	  start_day = params[:dayView] == 'true' ? day : day.at_beginning_of_week
	  end_day = params[:dayView] == 'true' ? day : day.at_end_of_week
	  @days_from_week = (start_day..end_day).map{|x| x}
	  @days_from_week.each do |day|
		@meal_types.each do |m|	
			slot_filled = @events.where(:start_at => day.strftime + m[1]).length == 0 ? false : true
			# if no event exists in that time slot, shuffle one in!
			if !slot_filled
				# 70% chance of using one of myFoods instead of calling the recommender
				if rand() < 0.7
					recommended_recipe_ids.shuffle.each do |r|
						if !slot_filled
						  if Recipe.exists?(id: r.to_i) && !slot_filled
					        recipe = Recipe.find(r)
					        if m[2].include?(recipe.meal_type.to_i)
					        	@shuffled_events << get_meal_type(recipe.meal_type) + '--for--' + recipe.name

					        	@event = current_user.events.build(recipe_id: recipe.id, start_at: day.to_s + m[1], recipe_name: recipe.name)
					        	@event.save

					        	slot_filled = true
					        end
					  	  end
						end
					end
				else
					recommended_recipe_ids.shuffle.each do |r|
					  	if !slot_filled
							response = HTTParty.get("https://sleepy-escarpment-10890.herokuapp.com/recommend?recipe="+r+"")
							response = response.body
							if response
					      	  response.gsub!(/(\,)(\S)/, "\\1 \\2")
					      	  array = YAML::load(response)
					    	end
					    	array.each do |response|
					    		# this loop is an unnecessary performance hit
					    		# we should format the recommender call so that we can use whatever it gives us
					    		# rather than looping through the results to find a recipe of the desired meal_type
					    	  if Recipe.exists?(id: response.to_i) && !slot_filled
					            recipe = Recipe.find(response)
					            if m[2].include?(recipe.meal_type.to_i)
					            	@shuffled_events << get_meal_type(recipe.meal_type) + '--for--' + recipe.name

					            	@event = current_user.events.build(recipe_id: recipe.id, start_at: day.to_s + m[1], recipe_name: recipe.name)
					            	@event.save

					            	slot_filled = true
					            end
					      	  end
							end
						end
					end
				end		
			end
		end
	  end
	  
	  puts '----------------shuffled events'
	  @shuffled_events.each do |e|
	  	puts e.inspect
	  end

	  respond_to do |format|
	  	# not formatted for json yet
	  	format.json { render :json => @shuffled_events } 
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

	def get_categories	

		array =	[
			    ["Uncategorized", []],
				["Baby Care", []],
				["Bakery Items", []],
				["Baking Supplies", []],
				["Basic Cooking Ingredients", []],
				["Beverages", []],
				["Canned Foods", []],
				["Cereals", []],
				["Condiments and Salad Dressings", []],
				["Dairy and Egg Products", []],
				["Dairy, Eggs and Milk", []],
				["Deli", []],
				["Ethnic Foods", []],
				["Fish", []],
				["Frozen Foods", []],
				["Herbs and Spices", []],
				["Meats", []],
				["Pasta", []],
				["Produce", []],
				["Seafood", []],
				["Soup", []],
				["Frozen", []],
				["Boxer Dinners & Sides", []],
				["Breads", []],
				["Syrups", []],
				["Canned Soups", []],
				["Chocolate", []],
				["Coffee & Teas", []],
				["Cooking Oils", []],
				["Dessert Toppings", []],
				["Gluten Free", []],
				["Cheeses", []],
				["Peanut Butter and Jelly", []],
				["Salad Dressings", []],
				["Baking", []],
				["Beverages", []],
				["Chocolate & Candy", []],
				["Condiment", []],
				["Dessert and Snack", []],
				["Fruit & Nuts", []],
				["Grains & Cereals", []],
				["Jam, Jelly & Spreads", []],
				["Meat, Seafood and Eggs", []],
				["Oil and Vinegar", []],
				["Pasta, Rice and Noodle", []],
				["Prepared Meals and Canned Food", []],
				["Regional Food", []],
				["Salada Dressing, Sauce and Marinade", []],
				["Salsa & Dip", []],
				["Spice and Seasoning", []],
				["Spices and Herbs", []],
				["Fruits and Fruit Juices", []],
				["Nut and Seed Products", []],
				["Lamb Veal and Game Products", []],
				["Vegetables and Vegetable Products", []],
				["Soups Sauces and Gravies", []],
				["Finfish and Shellfish Products", []],
				["Fats and Oils", []],
				["Fast Foods", []],
				["Baked Products", []],
				["Sweets", []],
				["Baby Foods", []],
				["Snacks", []],
				["Legumes and Legume Products", []],
				["Beef Products", []],
				["Poultry Products", []],
				["Branded Food Products Database", []],
				["Sausages and Luncheon Meats", []],
				["American Indian/Alaska Native Foods", []],
				["Cereal Grains and Pasta", []],
				["Breakfast Cereals", []],
				["Restaurant Foods", []],
				["Pork Products", []]
			]


		return array
	end
end




