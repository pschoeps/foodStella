class RecipesController < ApplicationController

  def new
    @recipe = current_user.recipes.build
    @recipe.quantities.build
    @recipe.quantities.last.build_ingredient
    @recipe.instructions.build
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
  end

  def index
    @recipes = current_user.recipes 
  end

  def recipe_params
  	params.require(:recipe).permit(:name, :photo_url, :category, :prep_time, :cook_time, :difficulty, :meal_type, :description,
  	  :quantities_attributes => [
        :id,
        :amount,
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