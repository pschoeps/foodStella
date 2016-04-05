class RecipesController < ApplicationController

  def new
    @recipe = current_user.recipes.build
    @recipe.quantities.build
    @recipe.quantities.last.build_ingredient
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

  def show
    @recipe = Recipe.find(params[:id])
  end

  def index
    @recipes = current_user.recipes 
  end

  def recipe_params
    params.require(:recipe).permit(:name, :photo_url, :category,
      :quantities_attributes => [
      :id,
      :amount,
      :_destroy,
      :ingredient_attributes => [
        #:id commented bc we pick 'id' for existing ingredients manually and for new we create it
        :name
  ]])
  end
end