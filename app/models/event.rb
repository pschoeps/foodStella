class Event < ActiveRecord::Base
  belongs_to :user
  has_one :recipe


  def get_recipe(recipe_id)
  	recipe = Recipe.find(recipe_id)
  	recipe
  end
end
