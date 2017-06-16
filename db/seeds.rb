# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# json = ActiveSupport::JSON.decode(File.read('db/seeds/countries.json'))


# Recipe.destroy_all

#=========================== Manually clear all tables related to recipes
sql = "TRUNCATE table average_caches RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table commontator_comments RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table commontator_subscriptions RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table commontator_threads RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table cookeds RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table events RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table ingredients RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table instructions RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table others_photos RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table overall_averages RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table quantities RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table rates RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table rating_caches RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table recipes RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table relationships RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)
sql = "TRUNCATE table votes RESTART IDENTITY"
ActiveRecord::Base.connection.execute(sql)


records = JSON.parse(File.read('app/assets/data/recipes_400.json'))
records.each do |record|

  #=========================== meal_type (int)
  appetizers = ['appetizers']
  side_dishes = ['bread','chili','rice','salad','soup','vegetables','casseroles','healthy']
  main_dishes = ['beef','burgers','chicken','fish & seafood','italian','mexican','pasta','pizza','pork','sausage','steak','stew']
  desserts = ['cake', 'cookies', 'pies']
  drinks = []
  breakfasts = ['breakfast']
  
  if appetizers.include? record['meal_type'].downcase
    meal_type = 1
  elsif side_dishes.include? record['meal_type'].downcase
    meal_type = 2
  elsif main_dishes.include? record['meal_type'].downcase
    meal_type = 3
  elsif desserts.include? record['meal_type'].downcase
    meal_type = 4
  elsif drinks.include? record['meal_type'].downcase
    meal_type = 5
  elsif breakfasts.include? record['meal_type'].downcase
    meal_type = 6
  else
    meal_type = 3
  end

  #=========================== category (string)
  styles = ['burgers','casserole','chili','healthy','italian','mexican','salad','seafood','soup','mediterranean']
  category = ''
  # styles.each_with_index do |s, index|
  #   if record['meal_type'].downcase.include? s
  #     category = styles[index]
  #   end
  # end
  if category.blank?
    category = record['meal_type'].downcase
  end

  if !record['servings'] == ''
    servings = 1
  else
    servings = record['servings'].to_i
  end

  #=========================== cook_time and prep_time
  total_mins = 0
  if record['total_time']
    record['total_time'] = record['total_time'].gsub("\n","").gsub("\\n","").chomp
    # '1 hr 30 mins' format
    if record['total_time'].include? "mins"
      total_mins += record['total_time'][-7,2].to_i
    end
    if record['total_time'].include? "hr"
      total_mins += record['total_time'].gsub(/\s.+/,'').to_i * 60
    end
    # 'PT1H30M' format
    if record['total_time'][0..1] == "PT"
      if record['total_time'].include? "H"
        total_mins += record['total_time'].split('H')[0].gsub(/[^0-9]/, '').to_i * 60
        total_mins += record['total_time'].split('H')[1].gsub(/[^0-9]/, '').to_i
      else
        total_mins += record['total_time'].gsub(/[^0-9]/, '').to_i
      end
    end
  end

  prep_mins = 0
  if record['prep_time']
    record['prep_time'] = record['prep_time'].gsub("\n","").gsub("\\n","").chomp
    # '1 hr 30 mins' format
    if record['prep_time'].include? "mins"
      prep_mins += record['prep_time'][-7,2].to_i
    end
    if record['prep_time'].include? "hr"
      prep_mins += record['prep_time'].gsub(/\s.+/,'').to_i * 60
    end
    # 'PT1H30M' format
    if record['prep_time'][0..1] == "PT"
      if record['prep_time'].include? "H"
        prep_mins += record['prep_time'].split('H')[0].gsub(/[^0-9]/, '').to_i * 60
        prep_mins += record['prep_time'].split('H')[1].gsub(/[^0-9]/, '').to_i
      else
        prep_mins += record['prep_time'].gsub(/[^0-9]/, '').to_i
      end
    end
  end

  if total_mins == 0
    cook_mins = 0
  else
    cook_mins = total_mins - prep_mins
  end

  #=========================== estimate difficulty
  difficulty = 1
  if total_mins > 30
    difficulty = 2
  elsif total_mins > 60
    difficulty = 3
  end

  #=========================== create Recipe
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
    category: category
  })


  #=========================== create Instructions
  if record['recipe_instructions'][0..2] == '0: '
    instructions = record['recipe_instructions'].split(/\d+:\s/)
  else
    if record['recipe_instructions'][0..10] == 'Directions '
      record['recipe_instructions'].slice!(0..10)
    end
    instructions = record['recipe_instructions'].split('.').map(&:strip)
  end

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

  #=========================== create or reference Ingredients
  ingredients = JSON.parse(File.read('app/assets/data/ingredients_400.json'))
  ingredients.each do |ingredient|
    if ingredient['recipe_id'] == record['recipe_id']
      new_ingredient = Ingredient.find_or_create_by!(name: ingredient['ingredient'])
      new_ingredient.update_attributes(:abbreviated => ingredient['abbreviated'])

      if ingredient['unit'].downcase.include? "cup" #|| ingredient['quantity'].downcase.include? "cup"
        unit = 1
      elsif ingredient['unit'].downcase.include? "ounce" #|| ingredient['quantity'].downcase.include? "ounce"
        unit = 2
      elsif ingredient['unit'].downcase.include? "ounce" #|| ingredient['quantity'].downcase.include? "ounce"
        unit = 3
      elsif ingredient['unit'].downcase.include? "tablespoon" #|| ingredient['quantity'].downcase.include? "tablespoon"
        unit = 4
      elsif ingredient['unit'].downcase.include? "pinch" #|| ingredient['quantity'].downcase.include? "pinch"
        unit = 5
      else
        unit = nil
      end

      if ingredient.has_key?('ounces')
        # ounces = ingredient['ounces'].to_s.tr('()', '').map(&:strip)
        ounces = ingredient['ounces']
      else
        ounces = 0
      end

      # amount = ingredient['quantity'].to_s.tr('()', '').map(&:strip)
      # detail = ingredient['detail'].to_s.tr('()', '').map(&:strip)
      amount = ingredient['quantity']
      detail = ingredient['detail']

      #=========================== create Quantities
      Quantity.create!({
        recipe_id: recipe.id,
        ingredient_id: new_ingredient.id,
        unit: unit,
        amount: amount,
        ounces: ounces,
        detail: detail
      })
    end
  end


end