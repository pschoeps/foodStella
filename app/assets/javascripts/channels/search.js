console.log("the search channel is up")

App.recommendations = App.cable.subscriptions.create('SearchChannel', {  
  received: function(data) {
    console.log("recieved data")
    console.log(data.recipe)
    recipe = data.recipe
    $('.recommended').prepend("<li><div class='box'><a href='/recipes/"+recipe.id+"'><img src='"+data.pic+"' alt='"+recipe.name+"'></a></div><div class='details'><h3>"+data.truncated_name+"</h3><p>"+data.truncated_description+"</p><span class='cook-time'>Cook Time: <p>"+data.recipe_short_cook+"</p></span><span class='prep-time'>Prep Time: <p>"+data.recipe_short_prep+"</p></span><div class='recipe-footer'>"+data.recipe_by+"</div></div>"+data.spatula+"")
  }
});
