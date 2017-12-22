
$('.users.calendar').ready(function() {


	$('.add-meal-big, .add-meal-short').droppable({
    hoverClass: "ui-state-active",
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

      if ($(recipe).attr('id') == "in-list-recommended") {
        console.log("from recommended")
        imageUrl = recipe.attr('data-image-src')
        console.log(imageUrl)
      }

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

          $(mealDiv).find('.added-meals').append("<div class='meal week-meal desktop-meal "+recipeName+"' data="+recipeId+"><a class='desktop-event fc-event-container "+recipeName+"' id='mobile-event' data-event="+response+" data-recipe="+recipeId+" data-image="+recipeName+" data-servings="+recipeServings+" data-recipe-name="+recipeFriendlyName+"><span class='delete-event'></span><span class='servings' id='desktop-week-servings'>"+recipeServings+"s</span><span class='event-title' style='background-color: "+mealColor+"'>"+recipeFriendlyName+"</span></a><div class='change-servings-box hidden'><span class='change-servings-box-close'>close</span><span class='glyphicon glyphicon-minus change-serving' id='minus-serving' aria-hidden='true'></span><span id='num-servings' data="+response+" data-servings="+recipeServings+">"+recipeServings+"</span><span class='glyphicon glyphicon-plus change-serving add' id='add-serving' aria-hidden=true></span></div>")
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
          if (imageUrl) { //evaling if a recipe was dropped from the recommended view, in which case follow the recipe and take a different method for adding image
            console.log(true)
            meals = $(mealDiv).find('.added-meals').children('.'+recipeName)
            $(meals).find('a').css('background-image', "url("+imageUrl+")");
            followRecipe(recipeId);
          }
        }
      });//end ajax call


    }
  });

  function followRecipe(recipeId) {
    data = {id:recipeId}
    $.ajax({//ajax call
        type:'POST',
        data: data,
        url:'/relationships',
        success:function (response) {
          console.log("this was succesful")
        }
    });//end ajax call
  }

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

  $(document).on('click', '.event-title', function() {
    var event = $(this).closest('.desktop-event')
    var recipeId = parseInt($(event).attr('data-recipe'));
    console.log(recipeId);
    document.location.href = "/recipes/"+recipeId;
  });

  console.log(gon.nextWeek)
  console.log(gon.previousWeek)

  $('.next-week-link').click(function(){
      var updated_week = (gon.nextWeek)
      console.log(updated_week)
      this.href = this.href + '?week=' + (updated_week)
    });

  $('.prev-week-link').click(function(){
    updated_week = gon.previousWeek
    this.href = this.href + '?week=' + (updated_week)
  });

  setTimeout(function(){
    // $('.recommended-banner').animate({'opacity': 0}, 1000)
  }, 5000);

  // Shuffle!
  $('.shuffle-button .shuffle, .shuffle-tag').click(function(){
		// alert('shuffle');
		// return;
    $(".desktop-calendar-container").css("background-color", "lightgrey");
    $('.shuffle-button .glyphicon-refresh').show();
    shuffle();
  });

  $('.start_over').click(function(){
    $(".desktop-calendar-container").css("background-color", "lightgrey");
    $('.shuffle-button .glyphicon-refresh').show();
    clearPlanner();
  });

  function shuffle() {
    // console.log(gon.shuffle_recommended_recipe_ids);
    // return;
    data = {
      breakfast_ids: gon.shufflable_breakfast_ids,
      lunch_ids: gon.shufflable_lunch_ids,
      dinner_ids: gon.shufflable_dinner_ids,
      start_day: gon.start_day,
      dayView: gon.dayView
    }
    console.log(data)

    $.ajax({//ajax call for questions
                  type:'GET',
                  data: data,
                  url: "/users/"+gon.user_id+"/shuffle",
                  success:function (response) {
                    // controller should return full json of new events,
                    // and then those can be appended here
                    // the code to create the json has not been written yet

                    // respone.each(function(i, event){
                    //   // event json will require the following values:
                    //   event = {
                    //     recipe_id: 1,
                    //     recipe_friendly_name: 'name',
                    //      recipe_truncated_name: truncate(name, length: 18)'
                    //     meal: 'breakfast',
                    //      color: '#ffffff'
                    //     servings: 1,
                    //   }

                      // newEvent =
                      //   "<div class='meal week-meal desktop-meal' data='" + event.recipe_id + "'>" +
                      //     "<a class='desktop-event fc-event-container " + event.recipe_friendly_name + "id-" + event.recipe_id + " id='desktop-event' data-event='" + event.id + "' data -recipe='" + event.recipe_id + "' data-recipe-name='' data-image='' data-serving='' style='background-image: url();'>" +
                      //       "<span class='delete-event'></span>" +
                      //       "<span class='servings' id='desktop-week-servings'>" + event.servings + "</span>" +
                      //       "<span class='event-title' style='background-color: " + event.color + "'>" + event.recipe_truncated_name + "</span>" +
                      //      "</a>" +
                      //       "<div class='change-servings-box hidden'>" +
                      //           "<span class='change-servings-box-close'>close</span>" +
                      //           "<span class='glyphicon glyphicon-minus change-serving' id='minus-serving' aria-hidden='true'></span>" +
                      //           "<span id ='num-servings' data='" + event.id + "' data-servings='" + event.servings + "'>" + event.servings + "</span>" +
                      //           "<span class='glyphicon glyphicon-plus add change-serving' id='add-serving' aria-hidden='true'></span>" +
                      //         "</div>" +
                      //       "</div>";

                    //   $('.meal-types#' + event.meal + ' added-meals').append(newEvent);
                    // });

                    // until return json is written, just reload page
                    location.reload();

                    $('.shuffle-button .glyphicon-refresh').hide();
                  }
    });//end ajax call
  }

  function unshuffle() {
    // console.log(gon.shuffle_recommended_recipe_ids);
    // return;
    data = {
      ids: gon.shuffle_recommended_recipe_ids,
      start_day: gon.start_day,
      dayView: gon.dayView
    }
    console.log(data)
    $.ajax({//ajax call for questions
                  type:'GET',
                  data: data,
                  url: "/users/"+gon.user_id+"/unshuffle",
                  success:function (response) {
                    location.reload();

                    $('.shuffle-button .glyphicon-refresh').hide();
                  }
    });//end ajax call
  }

  function clearPlanner() {
    data = {
      ids: gon.shuffle_recommended_recipe_ids,
      start_day: gon.start_day,
      dayView: gon.dayView
    }
    $.ajax({//ajax call for questions
                  type:'GET',
                  data: data,
                  url: "/users/"+gon.user_id+"/clear_planner",
                  success:function (response) {
                    location.reload();
                    // $('.desktop-event').remove();
                    $('.shuffle-button .glyphicon-refresh').hide();
                  }
    });//end ajax call
  }

});
