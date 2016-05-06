# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# json = ActiveSupport::JSON.decode(File.read('db/seeds/countries.json'))
records = JSON.parse(File.read('app/assets/data/recipes_test.json'))
records.each do |record|
  Recipe.create!({
  	user_id: 0,
  	name: record['recipe_name'],
  	photo_url: record['recipe_pic_url'],
  	category: 0,
  	description: record['recipe_description'],
  	prep_time: record['prep_time'],
  	cook_time: record['total_time'],
  	difficulty: 2,
  	meal_type: 2,
  	servings: record['servings']
  })
end