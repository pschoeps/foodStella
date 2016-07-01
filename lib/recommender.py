import re
from scipy import spatial
import csv
import numpy as np


mass_fractions = open("mass_fractions_matrix.txt")


mass_fractions_matrix = []
for line in mass_fractions:
	mass_fractions_matrix.append(line.split(' '))



def cosine_similarity(arr1, arr2):
	return 1 - spatial.distance.cosine(arr1, arr2)



recipesjson = open("recipes.json", "r")
meal_types_names = []
meal_type_vector = []
recipe_names = []
recipe_name_list = []
for line in recipesjson:
	matchObj = re.match(r'.*\"recipe_name\": \"([^\"]*)\".*', line)
	if matchObj:
		recipe_names.append(matchObj.group(1))
		if matchObj.group(1).split(' ')[-1] not in recipe_name_list:
			recipe_name_list.append(matchObj.group(1).split(' ')[-1])
	matchObj2 = re.match(r'.*\"meal_type\": \"([^\"]*)\".*', line)
	if matchObj2:
		if matchObj2.group(1) not in meal_types_names:
			meal_types_names.append(matchObj2.group(1))
		meal_type_vector.append(matchObj2.group(1))

#lambdamt is the weight of the meal type  - how much we want to weight meal type 
lambdamt = 0.5
#lambdadt is the weight of the dish type - how much we want to weight dish type
lambdadt = 0.7

meal_type_matrix = np.zeros((len(mass_fractions_matrix), len(meal_types_names)))
print meal_type_matrix[0, 0]
for i, l in enumerate(meal_type_vector):
	for j,k in enumerate(meal_types_names):
		if k == l:
			meal_type_matrix[i, j] = lambdamt
			break

dish_type_matrix = np.zeros((len(mass_fractions_matrix), len(recipe_name_list)))
for i, l in enumerate(recipe_names):
	for j, k in enumerate(recipe_name_list):
		if k.split(' ')[-1] == l:
			dish_type_matrix[i,j] = lambdadt
			break


description_vectors = np.column_stack((mass_fractions_matrix, meal_type_matrix, dish_type_matrix))

x = raw_input("Input the recipe_id (between 1 and 376) of the recipe you like and I will recommend similar recipes\n")

x = int(x)

print "The recipe you chose was:"
print recipe_names[x -1] + ": Meal Type: " + meal_type_vector[x-1] + ": Dish Type: " + recipe_names[x-1].split(' ')[-1]
print "\n\n"

#output the recipe_id and recipe names of the most similar recipes
print "Similar recipes using cosine similarity:"


cosine_distances = []

for j,i in enumerate(description_vectors):
	cosine_distances.append(cosine_similarity(map(float, description_vectors[x-1]), map(float, i)))
	#print cosine_similarity(map(float, mass_fractions_matrix[0]), map(float, i))


cosine_distances = np.asarray(cosine_distances)
order = cosine_distances.argsort()

for i in order[-10:][::-1]:
	print recipe_names[i-1]+ ": Meal Type: " + meal_type_vector[i-1] + ": Dish Type: " + recipe_names[i-1].split(' ')[-1]
