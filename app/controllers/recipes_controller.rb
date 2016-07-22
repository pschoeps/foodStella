class RecipesController < ApplicationController
  include MobileHelper
  include ActionView::Helpers::TextHelper
  before_action :check_for_mobile
  respond_to :html, :json

  autocomplete :ingredient, :name #, :full => true

  def new
    @recipe = current_user.recipes.build
    @recipe.quantities.build
    @recipe.quantities.last.build_ingredient
    @recipe.instructions.build

    if params[:recipe]
      @other_recipe = Recipe.find(params[:recipe])
    end

    respond_to do |format|
      format.html
      # format.json
    end
  end

  def create
    @recipe = current_user.recipes.build(recipe_params)

    @recipe.quantities.each do |q|
      if ingredient = Ingredient.where(name: q.ingredient.name).first
        q.ingredient = ingredient
      else
        q.ingredient.abbreviated = q.ingredient.name.split(' ').last
      end

      q.ounces = q.convert_to_ounces()
    end

    if @recipe.save
      # redirect_to dashboard_user_path(current_user)
      # redirect_to action: 'index'
      redirect_to :action => 'show', :controller => 'recipes', :id => @recipe.id
      flash[:success] = "Recipe Created"
    else
      render 'new'
    end
  end

  def edit
    @recipe = Recipe.find(params[:id])
  end

  def destroy
    puts Recipe.find(params[:id])
    @recipe = Recipe.find(params[:id]).destroy
    flash[:success] = "Recipe deleted"
    # redirect_to dashboard_user_path
    redirect_to action: 'index'
  end

  def update
    @recipe = Recipe.find(params[:id])
    if @recipe.update_attributes(recipe_params)
      if params[:others_photo_url]
        @recipe.others_photos.create(photo_url: params[:others_photo_url], user_id: current_user.id)
      end

      respond_to do |format|
        format.html  { redirect_to recipe_path(@recipe) }
        flash[:success] =  "Recipe Updated"
      end
    end
  end

  def show
    @recipe = Recipe.find(params[:id])
    @difficulty = get_difficulty(@recipe.difficulty) if @recipe.difficulty
    @meal_type = get_meal_type(@recipe.meal_type) if @recipe.meal_type
    # @cookware = get_meal_type(@recipe.meal_type) if @recipe.meal_type
    # @category = get_category(@recipe.category) if @recipe.category
    commontator_thread_show(@recipe)
    @others_photos = @recipe.others_photos
    gon.recipes_page = true
    gon.recipe_id = @recipe.id
    gon.user_id = current_user.id
  end

  def get_recommended_recipes
    recipe_id = params[:recipe_id]
    response = HTTParty.get("https://sleepy-escarpment-10890.herokuapp.com/recommend?recipe="+recipe_id+"")
    puts response.body, response.code, response.message, response.headers.inspect
    puts "searchy"
    response = response.body
    if response
      response.gsub!(/(\,)(\S)/, "\\1 \\2")
      array = YAML::load(response)
    end
    puts "search for array"
    puts array

    array.each do |response|
      puts response
      #check if the recipe exists and make sure the response isn't the recipe of the current page
      if Recipe.exists?(id: response) && response.to_i != recipe_id.to_i
        puts "the recipe exists"
        recipe = Recipe.find(response)
        pic = recipe.retrieve_pic
        truncated_name = truncate(recipe.name, length: 55)

        ActionCable.server.broadcast "recommended_#{current_user.id}",
          recipe: recipe,
          pic: pic,
          truncated_name: truncated_name
      end

    end
  end

  def broadcast
    # Use the class methods to get down to business quickly
    response = HTTParty.get("https://sleepy-escarpment-10890.herokuapp.com/search")
    puts response.body, response.code, response.message, response.headers.inspect
    puts "searchy"
    response = response.body
    if response
      response.gsub!(/(\,)(\S)/, "\\1 \\2")
      array = YAML::load(response)
    end

    array.each do |response|
      if Recipe.exists?(id: response)
        recipe = Recipe.find(response)
        pic = recipe.retrieve_pic
        truncated_name = truncate(recipe.name, length: 30)
        truncated_description = truncate(recipe.description, length: 60)
        recipe_short_cook = recipe.get_short_time('cook') 
        recipe_short_prep = recipe.get_short_time('prep') 

        if recipe.user_id != 0 
          recipe_by = recipe.get_user(recipe.user_id).retrieve_name('check') 
        else
          recipe_by = "Stock"
        end

        unless current_user.owns?(recipe) 
          if current_user.following?(recipe) 
            spatula = "<div data='"+recipe.id.to_s+"' class='spatula spatula-selected' id='unfollow'><div class='label'></div></div>" 
          else
            spatula = "<div data='"+recipe.id.to_s+"' class='spatula spatula-unselected' id='follow'><div class='label'></div></div>" 
          end
        end

        ActionCable.server.broadcast 'search',
          recipe: recipe,
          pic: pic,
          truncated_name: truncated_name,
          truncated_description: truncated_description,
          recipe_short_cook: recipe_short_cook,
          recipe_short_prep: recipe_short_prep,
          recipe_by: recipe_by,
          spatula: spatula
      end
    end
  end

  def index
    gon.user_login_count = current_user.sign_in_count
    gon.recipes_page = true
    #variables contained in recipes sidebar
    @followed_recipes = current_user.following
    @user_recipes = current_user.recipes
    @recipes = @user_recipes + @followed_recipes
    @calendar_title = Time.now.strftime("%A")
    @events = current_user.events

    #broadcast

    @snacks = @user_recipes.where(:meal_type => "1") + @followed_recipes.where(:meal_type => "1")
    @side_dishes = @user_recipes.where(:meal_type => "2") + @followed_recipes.where(:meal_type => "2")
    @main_dishes = @user_recipes.where(:meal_type => "3") + @followed_recipes.where(:meal_type => "3")
    @desserts = @user_recipes.where(:meal_type => "4") + @followed_recipes.where(:meal_type => "4")
    @drinks = @user_recipes.where(:meal_type => "5") + @followed_recipes.where(:meal_type => "5")

    if params[:expanded]
      @expanded = params[:expanded]
    else
      @expanded = ['false','false','false','false','false']
    end

    # if params[:mobile_tab]
    #   @mobile_tab = params[:mobile_tab]
    # else
    #   @mobile_tab = 'my_foods'
    # end
    # #filtering links to model 
    # @filterrific_my_foods = initialize_filterrific(
    #   Recipe,
    #   params[:filterrific] #,
    #   # :select_options => {
    #   #   sort_my_foods:   Recipe.options_for_sort_my_foods
    #   # },
    #   # :search_query_my_foods
    # ) or return
    # @filtered_my_foods = Recipe.filterrific_find(@filterrific_my_foods)
    # @snacks = @snacks & @filtered_my_foods
    # @side_dishes = @side_dishes & @filtered_my_foods
    # @main_dishes = @main_dishes & @filtered_my_foods
    # @desserts = @desserts & @filtered_my_foods
    # @drinks = @drinks & @filtered_my_foods
    
    #filtering links to model 
    @filterrific = initialize_filterrific(
      Recipe,
      params[:filterrific],
      :select_options => {
        sorted_by:   Recipe.options_for_sorted_by,
        sort_by_ingredients: Recipe.options_for_sort_by_ingredients,
        latest: Recipe.options_for_latest,
        style: Recipe.options_for_style,
        difficulty: Recipe.options_for_difficulty,
        meal_type: Recipe.options_for_meal_type,
        cook_time: Recipe.options_for_cook_time,
        prep_time: Recipe.options_for_prep_time,
        ratings_count: Recipe.options_for_ratings_count,
        ratings_average: Recipe.options_for_ratings_average,
        my_favorites: Recipe.options_for_my_favorites,
        cooked: Recipe.options_for_cooked,
        following: Recipe.options_for_following,
        owns: Recipe.options_for_owns,
        trending: Recipe.options_for_trending,
        total_time: Recipe.options_for_total_time,
      },
      persistence_id: false
      # default_filter_params: {latest: false}
    ) or return

    @recipes = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def next_page
    #filtering links to model 
    @filterrific = initialize_filterrific(
      Recipe,
      params[:filterrific],
      :select_options => {
        sorted_by:   Recipe.options_for_sorted_by,
        sort_by_ingredients: Recipe.options_for_sort_by_ingredients,
        latest: Recipe.options_for_latest,
        style: Recipe.options_for_style,
        difficulty: Recipe.options_for_difficulty,
        meal_type: Recipe.options_for_meal_type
      }
    ) or return
    puts '======================================================================'
    puts @filterrific
    @more_recipes = @filterrific.find.page(params[:page])
    puts @more_recipes
    respond_to do |format|
      format.html
      format.js #{ render partial: "recipes/list", locals: {recipes: @more_recipes} }
    end
    # render partial: "recipes/list", locals: {recipes: @more_recipes}
    # render(partial: 'recipes/next_page', locals: { recipes: @more_recipes })
  end

  def sidebar
    @followed_recipes = current_user.following
    @user_recipes = current_user.recipes
    # @recipes = @user_recipes + @followed_recipes

    @snacks = @user_recipes.where(:meal_type => "1") + @followed_recipes.where(:meal_type => "1")
    @side_dishes = @user_recipes.where(:meal_type => "2") + @followed_recipes.where(:meal_type => "2")
    @main_dishes = @user_recipes.where(:meal_type => "3") + @followed_recipes.where(:meal_type => "3")
    @desserts = @user_recipes.where(:meal_type => "4") + @followed_recipes.where(:meal_type => "4")
    @drinks = @user_recipes.where(:meal_type => "5") + @followed_recipes.where(:meal_type => "5")

    @expanded = ['false','false','false','false','false']

    @filterrific_my_foods = initialize_filterrific(
      Recipe,
      params[:filterrific] #,
      # :select_options => {
      #   sort_my_foods:   Recipe.options_for_sort_my_foods
      # },
      # :search_query_my_foods
    ) or return
    @filtered_my_foods = Recipe.filterrific_find(@filterrific_my_foods)
    @snacks = @snacks & @filtered_my_foods
    @side_dishes = @side_dishes & @filtered_my_foods
    @main_dishes = @main_dishes & @filtered_my_foods
    @desserts = @desserts & @filtered_my_foods
    @drinks = @drinks & @filtered_my_foods

    if params[:new_recipe_id]
      @newRecipe = Recipe.where(:id => params[:new_recipe_id]).first
      @new_category = @newRecipe.meal_type
    else
      @new_category = nil
    end

    if params[:mobile]
      respond_to do |format|
        format.html
        format.js
      end
    else
      respond_to do |format|
        format.js
      end
    end
    gon.recipes_page = true
  end

  def get_difficulty(diff)
    string = case diff
                when "1"
                  "Easy"
                when "2"
                  "Moderate"
                when "3"
                  "Difficult"
              end
    string
  end

  def get_category(cat)
    string = case cat 
                when "1"
                  "Medit."
                when "2"
                  "Chinese"
                end
    string
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

  def recipe_params
  	params.require(:recipe).permit(:name, :photo_url, :category, :prep_time, :cook_time, :difficulty, :meal_type, :description, :servings, :website_url, :cookware,
  	  :quantities_attributes => [
        :id,
        :amount,
        :unit,
        :_destroy,
        :ingredient_attributes => [
          #:id commented bc we pick 'id' for existing ingredients manually and for new we create it
          :name
        ]
      ],
      :instructions_attributes => [:id, :description, :order, :_destroy]
    )
  end
end