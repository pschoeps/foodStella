class RecipesController < ApplicationController

  def new
    @recipe = current_user.recipes.build
    @recipe.quantities.build
    @recipe.quantities.last.build_ingredient
    @recipe.instructions.build

    if params[:recipe]
      @other_recipe = Recipe.find(params[:recipe])
    end
  end

  def create
    @recipe = current_user.recipes.build(recipe_params)

    if @recipe.save
      redirect_to dashboard_user_path(current_user)
      flash[:success] = "Recipe Created"
    else
      render 'new'
    end
  end

  def edit
    @recipe = Recipe.find(params[:id])
  end

  def destroy
    @recipe = Recipe.find(params[:id]).destroy
    flash[:success] = "Recipe deleted"
    redirect_to dashboard_user_path
  end

  def update
    @recipe = Recipe.find(params[:id])
    @recipe.update_attributes(recipe_params)
      respond_to do |format|
        format.html  { redirect_to recipe_path(@recipe) }
        flash[:success] =  "Recipe Updated"
    end
  end

  def show
    @recipe = Recipe.find(params[:id])
    @difficulty = get_difficulty(@recipe.difficulty) if @recipe.difficulty
    @meal_type = get_meal_type(@recipe.meal_type) if @recipe.meal_type
    @category = get_category(@recipe.category) if @recipe.category
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

    @recipes = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
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
                end
    string
  end

  def recipe_params
  	params.require(:recipe).permit(:name, :photo_url, :category, :prep_time, :cook_time, :difficulty, :meal_type, :description, :servings, :website_url,
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