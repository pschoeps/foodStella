$('.users.calendar').ready(function() {
	$('.add-meal-big, .add-meal-short').droppable({
    drop: function(event, ui) {
      $this = $(this)
      meal = $this.find('.add-meal')
      mealData = $(meal).attr('data-meal-id')
      date = $(meal).attr('data-date')
      time = $(meal).attr('data-meal-time')
      mealColor = $(meal).attr('data-meal-color')
      recipeFriendlyName = $(meal).attr('data-day-friendly')

      startAt = date + time 

      recipe = $(ui.draggable)
      recipeId = recipe.attr('data-id')
      recipeName = recipe.attr('data')
      recipeFriendlyName = recipe.attr('data-name')
      recipeServings = recipe.attr('data-servings')

      var data = {
                    event: {
                      start_at: startAt,
                      recipe_id: recipeId,
                      recipe_name: recipeName
                    }
                  };

      $.ajax({//ajax call 
        type:'POST',
        data: data,
        url:'/events',
              
        success:function (response) {
          dateDiv = '#' + date
          mealDiv = $(dateDiv).find('#' + mealData)

          $(mealDiv).find('.added-meals').append("<div class='meal week-meal desktop-meal' data="+recipeId+"><a class='desktop-event fc-event-container "+recipeName+"' id='mobile-event' data-event="+response+" data-recipe="+recipeId+" data-image="+recipeName+" data-servings="+recipeServings+" data-recipe-name="+recipeFriendlyName+"><span class='delete-event'></span><span class='servings'>"+recipeServings+"s</span><span class='event-title' style='background-color: "+mealColor+"'>"+recipeFriendlyName+"</span></a><div class='change-servings-box hidden'><span class='change-servings-box-close'>close</span><span class='glyphicon glyphicon-minus change-serving' id='minus-serving' aria-hidden='true'></span><span id='num-servings' data="+response+" data-servings="+recipeServings+">"+recipeServings+"</span><span class='glyphicon glyphicon-plus change-serving add' id='add-serving' aria-hidden=true></span></div>") 
          var addMealBig = $(mealDiv).children('.add-meal-big')
          var addMealSmall = $(mealDiv).children('.add-meal-short')
          var childCount =  $(mealDiv).children('.added-meals').children('.meal').length;
          console.log(addMealBig, addMealSmall, childCount)
          console.log("child count", childCount)
          //change add meal will only happen when there is on event left in category
          //in this case, since we update the box before the meal is deleted, the number of children
          //in the meal types category will be 1
          $(addMealBig).attr("id", "hidden")
          $(addMealSmall).removeAttr("id")
        } 
      });//end ajax call


    }
  })

  $(document).on('click', '.delete-event', function() {
    console.log("clicked")
    var event = $(this).closest('.desktop-event')
    var eventId = parseInt($(event).attr('data-event'));

    var data = {
                  event: {
                    id: eventId
                  }
                };

    $.ajax({//ajax call 
      type:'DELETE',
      data: data,
      url:'/events/destroy',
      success:function (response) {

        var mealDiv = $(event).closest('.meal-types')
        $(event).closest('.meal').remove()

        var addMealBig = $(mealDiv).children('.add-meal-big')
        var addMealSmall = $(mealDiv).children('.add-meal-short')
        var childCount =  $(mealDiv).children('.added-meals').children('.meal').length;
        console.log("biggy", addMealBig, "smalls", addMealSmall, "count", childCount)
        if (childCount == 0) {
            $(addMealSmall).attr("id", "hidden")
            $(addMealBig).removeAttr("id")
            console.log("this is evaling true")
          }
      }         
    });//end ajax call
  });
});