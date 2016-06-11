class Ingredient < ActiveRecord::Base
  has_many :quantities
  has_many :recipes, through: :quantities
  # has_many :users, through: :preferred_ingredients

  # def self.search(term)
  #   where('LOWER(name) LIKE :term OR LOWER(abbreviated) LIKE :term', term: "%#{term.downcase}%")
  # end

end
