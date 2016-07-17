

$('.recipes.show').ready(function() {
	console.log('this is the recommended channel booting')

App.recommendations = App.cable.subscriptions.create('RecommendedChannel', {  
  received: function(data) {
    console.log("recieved data")
    console.log(data.recipe)
    recipe = data.recipe
    similar_recipes_container = $('.recipe-similar').find('.slider-horizontal')
    $(similar_recipes_container).append("<a href=recipes/"+recipe.id+"><div class='similar-recipe'><img src='"+data.pic+"' alt='"+recipe.name+"'><span>"+data.truncated_name+"</span></div></a>")
  }
});
});
