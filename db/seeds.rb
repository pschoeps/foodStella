# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# json = ActiveSupport::JSON.decode(File.read('db/seeds/countries.json'))
records = JSON.parse(File.read('app/assets/data/recipes.json'))
records.each do |record|
  
  if record['meal_type'] == 'Appetizers'
    meal_type = 1
  elsif record['meal_type'] == 'Chili' || record['meal_type'] == 'Rice' || record['meal_type'] == 'Salad' || record['meal_type'] == 'Soup' || record['meal_type'] == 'Vegetables'
    meal_type = 2
  elsif record['meal_type'] == 'Cake' || record['meal_type'] == 'Cookies' || record['meal_type'] == 'Pies'
    meal_type = 4
  else
    meal_type = 3
  end

  if record['servings'] == ''
    servings = 1
  else
    servings = record['servings']
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

  cook_mins = total_mins - prep_mins

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
  	category: 0,
  	description: record['recipe_description'],
  	prep_time: prep_mins,
  	cook_time: cook_mins,
  	difficulty: difficulty,
  	meal_type: meal_type,
  	servings: servings
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

  ingredients = JSON.parse(File.read('app/assets/data/recipe_ingredients.json'))
  ingredients.each do |ingredient|
    if ingredient['recipe_id'] == record['recipe_id']
      new_ingredient = Ingredient.create!({
        name: ingredient['ingredient']
      })

      unit_s = ingredient['quantity'][/[a-zA-Z].+/]
      if unit_s
        if unit_s.downcase.include? "cup"
          unit = 1
        elsif unit_s.downcase.include? "ounce"
          unit = 2
        elsif unit_s.downcase.include? "teaspoon"
          unit = 3
        elsif unit_s.downcase.include? "tablespoon"
          unit = 4
        elsif unit_s.downcase.include? "pinch"
          unit = 5
        else
          unit = nil
        end
      end

      amount_s = ingredient['quantity'].gsub(/[a-zA-Z\-].+/, '')
      amount_a = amount_s.split(' ')
      if amount_a.length == 1                             # ex. "1/2" || "3"
        if amount_a[0].include? "/"                       # "1/2" 
          fraction = amount_a[0].split('/')               # ["1","2"]
          amount = fraction[0].to_f / fraction[1].to_f    # 0.5
        else
          amount = amount_a[0].to_f                       # = 3.0
        end
      elsif amount_a.length == 2                          # ex. "1/2 4 oz package" || "3 1/2" || "2 8 ounce packages"
        if amount_a[0].include? "/"                       # "1/2 4"
          amount_f = amount_a[0].split('/')
          amount = amount_f[0].to_f / amount_f[1].to_f
          amount *= amount_a[1].to_f
        elsif amount_a[1].include? "/"                    # "3 1/2"
          amount = amount_a[0].to_f
          additional_f = amount_a[1].split('/')
          additional = additional_f[0].to_f / additional_f[1].to_f
          amount += additional                            # = 3.0 + 0.5
        else
          amount = amount_a[0].to_f * amount_a[1].to_f    # = 2.0 * 8.0
        end
      elsif amount_a.length == 3                          # ex. "1 10 3/4 ounce can"
        amount = amount_a[0].to_f                         # 1.0
        additonal = amount_a[1].to_f                      # 10.0
        fraction = amount_a[2].split('/')                 # ["3","4"]
        additional += fraction[0].to_f / fraction[1].to_f # 10.0 + 0.75
        amount *= additional                              # = 1 * 10.75
      else
        amount = amount_a[0].to_f * (amount_a[1].to_f + amount_a[2].to_f + amount_a[3].to_f) # take a guess...
      end
      
      amount = (amount*100).round / 100.0

      Quantity.create!({
        amount: amount,
        recipe_id: recipe.id,
        ingredient_id: new_ingredient.id,
        unit: unit
      })
    end
  end

end



