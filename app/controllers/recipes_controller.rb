class RecipesController < ApplicationController

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
    @category = get_category(@recipe.category) if @recipe.category
    commontator_thread_show(@recipe)
    @others_photos = @recipe.others_photos
  end

  def index
    #variables contained in recipes sidebar
    @followed_recipes = current_user.following
    @user_recipes = current_user.recipes
    @recipes = @user_recipes + @followed_recipes
    @calendar_title = Time.now.strftime("%A")
    @events = current_user.events

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
      },
      persistence_id: false
      # default_filter_params: {latest: false}
    ) or return

    pp params[:filterrific]
    @recipes = @filterrific.find.page(params[:page])

puts '======================================================================'
@recipes.each do |r|
  # @cach = RatingCache.where(:cacheable_id => r.id)
  # @cach.each do |c|
  #   puts c.avg
  # end
  @cach = Rate.where(:rateable_id => r.id)
  puts @cach.length
end
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
    @snacks = @user_recipes.where(:meal_type => "1") + @followed_recipes.where(:meal_type => "1")
    @side_dishes = @user_recipes.where(:meal_type => "2") + @followed_recipes.where(:meal_type => "2")
    @main_dishes = @user_recipes.where(:meal_type => "3") + @followed_recipes.where(:meal_type => "3")
    @desserts = @user_recipes.where(:meal_type => "4") + @followed_recipes.where(:meal_type => "4")
    @drinks = @user_recipes.where(:meal_type => "5") + @followed_recipes.where(:meal_type => "5")
    # render :partial => '/layouts/recipe_sidebar'
    
    # if params[:expanded]
    #   @expanded = params[:expanded]
    # else
    #   @expanded = ['false','false','false','false','false']
    # end
    ######### expanded sidebar sections are now handled entirely by js
    @expanded = ['false','false','false','false','false']

    if params[:new_recipe_id]
      @newRecipe = Recipe.where(:id => params[:new_recipe_id]).first
      @new_category = @newRecipe.meal_type
    else
      @new_category = nil
    end

    respond_to do |format|
      format.js
    end
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