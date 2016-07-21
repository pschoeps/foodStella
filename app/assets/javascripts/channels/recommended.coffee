

$('.recipes.show').ready ->
  App.recommendations = App.cable.subscriptions.create { channel: "RecommendedChannel", id: gon.user_id },
    received: (data) ->
      console.log("recieved data")
      console.log(data.recipe)
      recipe = data.recipe
      similar_recipes_container = $('.recipe-similar').find('.slider-horizontal')
      $(similar_recipes_container).append("<a href=recipes/"+recipe.id+"><div class='similar-recipe'><img src='"+data.pic+"' alt='"+recipe.name+"'><span>"+data.truncated_name+"</span></div></a>")
    

$('.users.day_calendar, .users.calendar').ready ->
  App.recommendations = App.cable.subscriptions.create { channel: "RecommendedChannel", id: gon.user_id },
    received: (data) ->
      console.log("recieved data")
      recipe = data.recipe
      recommended_recipes_container = $('.sidebar').find('.recommended-recipes')
      $(recommended_recipes_container).append("<div class='fc-event "+data.recipe_class+"' id='in-list-recommended' data-id="+recipe.id+" data-image-src="+data.pic+" data-servings="+recipe.servings+" data-name="+data.truncated_name+" data="+data.recipe_friendly_name+"><span class='recipe-title'>"+data.truncated_name+"</span><img src='"+data.pic+"' alt='"+recipe.name+"'></div>")
      $('.fc-event').draggable({
                      zIndex: 999,
                      revert: true,      # will cause the event to go back to its
                      revertDuration: 0  #  original position after the dra
                  });

