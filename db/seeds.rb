# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# json = ActiveSupport::JSON.decode(File.read('db/seeds/countries.json'))

# Recipe.destroy_all

# Manually clear all tables related to recipes
sql = "truncate table average_caches"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table commontator_comments"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table commontator_subscriptions"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table commontator_threads"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table cookeds"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table events"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table ingredients"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table instructions"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table others_photos"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table overall_averages"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table quantities"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table rates"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table rating_caches"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table recipes"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table relationships"
ActiveRecord::Base.connection.execute(sql)
sql = "truncate table votes"
ActiveRecord::Base.connection.execute(sql)

records = JSON.parse(File.read('app/assets/data/recipes_with_serving_sizes.json'))
records.each do |record|

  appetizers = ['appetizers']
  side_dishes = ['bread','chili','rice','salad','soup','vegetables','casseroles','healthy']
  main_dishes = ['beef','burgers','chicken','fish & seafood','italian','mexican','pasta','pizza','pork','sausage','steak','stew']
  desserts = ['cake', 'cookies', 'pies']
  drinks = []
  
  if appetizers.include? record['meal_type'].downcase
    meal_type = 1
  elsif side_dishes.include? record['meal_type'].downcase
    meal_type = 2
  elsif main_dishes.include? record['meal_type'].downcase
    meal_type = 3
  elsif desserts.include? record['meal_type'].downcase
    meal_type = 4
  else
    meal_type = 3
  end

  if record['servings:'] == ''
    servings = 1
  else
    servings = record['servings:']
  end

  total_mins = 0
  record['total_time'].chomp!
  if record['total_time'].include? "mins"
    total_mins += record['total_time'][-7,2].to_i
  end
  if record['total_time'].include? "hr"
    total_mins += record['total_time'].gsub(/\s.+/,'').to_i * 60
  end

  prep_mins = 0
  record['prep_time'].chomp!
  if record['prep_time'].include? "mins"
    prep_mins += record['prep_time'][-7,2].to_i
  end
  if record['prep_time'].include? "hr"
    prep_mins += record['prep_time'].gsub(/\s.+/,'').to_i * 60
  end

  if total_mins == 0
    cook_mins = 0
  else
    cook_mins = total_mins - prep_mins
  end

  difficulty = 1
  if total_mins > 30
    difficulty = 2
  elsif total_mins > 60
    difficulty = 3
  end

  recipe = Recipe.create!({
  	user_id: 0,
  	name: record['recipe_name'],
  	remote_photo_url: record['recipe_pic_url'],
  	description: record['recipe_description'],
  	prep_time: prep_mins,
  	cook_time: cook_mins,
  	difficulty: difficulty,
  	meal_type: meal_type,
  	servings: servings,
    category: record['meal_type']
  })


  instructions = record['recipe_instructions'].split(/\d+:\s/)
  counter = 0
  instructions.each do |i|
    if i != ""
      counter += 1
      new_instruction = Instruction.create!({
        recipe_id: recipe.id,
        description: i.chomp!,
        order: counter
      })
    end
  end

  ingredients = JSON.parse(File.read('app/assets/data/recipe_ingredients_parsed_with_units.json'))
  ingredients.each do |ingredient|
    if ingredient['recipe_id'] == record['recipe_id']
      new_ingredient = Ingredient.find_or_create_by!(name: ingredient['ingredient'])

      if ingredient['unit'].downcase.include? "cup"
        unit = 1
      elsif ingredient['unit'].downcase.include? "ounce"
        unit = 2
      elsif ingredient['unit'].downcase.include? "teaspoon"
        unit = 3
      elsif ingredient['unit'].downcase.include? "tablespoon"
        unit = 4
      elsif ingredient['unit'].downcase.include? "pinch"
        unit = 5
      else
        unit = nil
      end

      Quantity.create!({
        recipe_id: recipe.id,
        ingredient_id: new_ingredient.id,
        unit: unit,
        amount: ingredient['quantity'],
        ounces: ingredient['ounces'],
        detail: ingredient['detail']
      })
    end
  end

end



