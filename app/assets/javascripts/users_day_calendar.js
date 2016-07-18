$('.users.day_calendar, .users.calendar').ready(function(e) {

  $('#minus-all-servings, #plus-all-servings').on('click', function() { 
    var events = $('.desktop-meal')
    events_array = []
    var add 
    if ($(this).hasClass('add')) {
      add = true
    }
    events.each(function(i, obj) {
      var eventBox = $(obj).find('.desktop-event')
      var eventId = $(eventBox).attr('data-event')
      console.log(eventId)
      var servingsSmallBox = $(eventBox).children('.servings')
      var servingsBigBox = $(obj).find('.change-servings-box').find('#num-servings')
      var servingsCount = $(servingsBigBox).attr('data-servings')
      console.log(servingsCount)
      if (add == true) {
        var newServingsCount = parseInt(servingsCount) + 1
      }
      else {
        var newServingsCount = parseInt(servingsCount) - 1
      }
      servingsSmallBox.text(newServingsCount + "s")
      servingsBigBox.text(newServingsCount)
      servingsBigBox.attr("data-servings", newServingsCount)
      events_array.push(eventId);
    });

    data = {
      add: add,
      events: events_array
    }

    $.ajax({//ajax call for questions
      type:'POST',
      data: data,
      url:'/events/change_all_servings',  
    });//end ajax call
  });


  $('a#shopping-list').on('click', function() { 
    console.log("clicked link")
    day_counter = $('#next-day').attr('data')
    prev_day_counter = $('#previous-day').attr('data')
    this.href = this.href + '?day_counter=' + day_counter + '&prev_day_counter=' + prev_day_counter
  });

  $(document).on('click','#next-day',function(){
    $this = $(this)
    day_counter = $this.attr('data')
    $.ajax({//ajax call for questions
      type:'GET',
      data: {day_counter: day_counter},
      url:'/users/add_day',
              
        success:function (response) {
          console.log("ajax success")
          $("#day-" + day_counter).html(response);

          new_day_counter = parseInt(day_counter) + 1
          console.log(new_day_counter)
          $this.attr('data', new_day_counter)
          string = parse('<div class="row added-day" id="day-%s"> </div>', new_day_counter);
          $('.added-days').append($(string))
          element_id = '#day-' + new_day_counter
          $(element_id)[0].scrollIntoView( false );
          resetSidebar();     
        }   
    });//end ajax call
  });

  $(document).on('click','#previous-day',function(){
    $this = $(this)
    previous_day_counter = $this.attr('data')
    $.ajax({//ajax call for questions
      type:'GET',
      data: {day_counter: previous_day_counter},
      url:'/users/previous_day',
      success:function (response) {
        console.log("ajax success")
        $("#prev-day-" + previous_day_counter).html(response);
        new_day_counter = parseInt(previous_day_counter) + 1
        $this.attr('data', new_day_counter)
        string = parse('<div class="row prev-day" id="prev-day-%s"> </div>', new_day_counter);
        $('.prev-days').prepend($(string))
        element_id = '#day-' + new_day_counter
        // recalc scrollToFixed
        resetSidebar();
      }   
    });//end ajax call
  });

  function parse(str) {
    args = [].slice.call(arguments, 1),
    i = 0;
    return str.replace(/%s/g, function() {
    return args[i++];
    });
  };

  $(document).on('click', '.servings', function() {
    console.log("clicked")
    meal = $(this).closest('.meal')
    $(meal).find('.change-servings-box').removeClass('hidden')
  });

  $(document).on('click', '.change-servings-box-close', function() {
    $(this).closest('.change-servings-box').addClass('hidden');
  });

  $(document).on('click', '.change-serving', function() {
    console.log("Clicked on change servings")
      var servingsBox = $(this).closest(".change-servings-box")
      var numServingsEl = $(servingsBox).find('#num-servings')
      var id = parseInt($(numServingsEl).attr("data"))
      var numServings = parseInt($(numServingsEl).attr("data-servings"))
      if ($(this).hasClass("add")) {
       add = true
      }
      else {
        add = false
      }
      var data = {
          id: id,
          num_servings: numServings,
          add: add
                  };

        $.ajax({//ajax call 
                  type:'POST',
                  data: data,
                  url:"/events/"+id+"/change_serving",
              
                  success:function (response) {
                    console.log(response)
                    $(numServingsEl).text(response)
                    $(numServingsEl).attr("data-servings", response)
                    event = $(servingsBox).closest('.meal')
                    servings = $(event).find('.desktop-event').children('.servings')
                    $(servings).attr('data-servings', response)
                    $(servings).text(response + "s")
                  }
        });
  });
  
});

$('.users.day_calendar').ready(function() {
  $('.add-meal-big').droppable({
    drop: function(event, ui) {
      $this = $(this)
      meal = $this.find('.add-meal')
      mealData = $(meal).attr('data-four')
      date = $('#desktop-day-date').attr('data')
      time = $(meal).attr('data-three')
      mealColor = $(meal).attr('data-five')
      recipeFriendlyName = $(meal).attr('data-three')



      startAt = date + time 

      recipe = $(ui.draggable)
      recipeId = recipe.attr('data-id')
      recipeName = recipe.attr('data')
      recipeFriendlyName = recipe.attr('data-name')
      recipeServings = recipe.attr('data-servings')
      console.log("inside the function")


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
          console.log("this was succesful")
          element = '#' + mealData
          $(element).find('.added-meals').prepend("<div class='meal desktop-meal col-md-4' data="+recipeId+"><a class='mobile-event desktop-event fc-event-container "+recipeName+"' id='mobile-event' data-event="+response+" data-recipe="+recipeId+" data-image="+recipeName+" data-servings="+recipeServings+" data-recipe-name="+recipeFriendlyName+"><span class='delete-event'></span><span class='servings'>"+recipeServings+"s</span><span class='event-title' style='background-color: "+mealColor+"'>"+recipeFriendlyName+"</span></a><div class='change-servings-box hidden'><span class='change-servings-box-close'>close</span><span class='glyphicon glyphicon-minus change-serving' id='minus-serving' aria-hidden='true'></span><span id='num-servings' data="+response+" data-servings="+recipeServings+">"+recipeServings+"</span><span class='glyphicon glyphicon-plus change-serving add' id='add-serving' aria-hidden=true></span></div>")  
                }
      });//end ajax call


    }
  })

  $(document).on('click', '.delete-event', function() {
    console.log("clicked")
    var event = $(this).closest('.mobile-event')
    var eventId = parseInt($(event).attr('data-event'));
    console.log(eventId)

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
        $(event).closest('.meal').remove()
      }         
    });//end ajax call



  });

  


  $('.next-day-link').click(function(){ 
      var updated_day = (gon.nextDay)
      console.log(updated_day)
      this.href = this.href + '?day=' + (updated_day)
    });

    $('.prev-day-link').click(function(){ 
      updated_day = gon.previousDay
      this.href = this.href + '?day=' + (updated_day)
    });
 

});
