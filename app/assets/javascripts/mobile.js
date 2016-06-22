$(document).ready(function() {
    calcContainerHeight()
    //hide color defs
  	$('#hide-chevron').click(function() {
        $('.planner-instructions').addClass('closed');
        $('.planner-instructions').removeClass('open');
        //$('.planner-instructions').animate({width:'0px'}, 500);
        $('.planner-instructions').css('display', 'none');
        //$('.weekly-planner').animate({top:'-3em'}, 500);
        //$('.slider-container').animate({top:'-3em'}, 500);
        $('#unhide-chevron').css('display', 'block');
     });

    //unhide color defs
  	$('#unhide-chevron').click(function() {
  		$('.planner-instructions').addClass('open');
        $('.planner-instructions').removeClass('closed');
        $('.planner-instructions').css('display', 'block');
        $('.planner-instructions').animate({width:'100%'}, 500);
        $('.weekly-planner').animate({top:'0em'}, 500);
        $('.slider-container').animate({top:'0em'}, 500);
        $('#unhide-chevron').css('display', 'none');
  	});

    //tapped minus zoom out
    $('#tap-zoom-out').click(function() {
      var zoomLevel = $('#zoomSlider').slider( "value" )
      var incrementZoom = zoomLevel - 15
      $('#zoomSlider').slider({ value: incrementZoom })
    });

    //tapped minus zoo in
    $('#tap-zoom-in').click(function() {
      var zoomLevel = $('#zoomSlider').slider( "value" )
      var incrementZoom = zoomLevel + 15
      $('#zoomSlider').slider({ value: incrementZoom })
    });

    //slide bar handlers
    $('#zoomSlider').slider({
      orientation: "horizontal",
      range: "min",
      max: 200,
      min: 60,
      value: 130,
      slide: changeZoom,
      change: changeZoom
    });

    //changes zoom of '.weekly-planner'
    function changeZoom(){
      var zoomLevel = $('#zoomSlider').slider( "value" )
      zoom = zoomLevel * .01
      console.log(zoom)

      if (zoom < .45) {
        $('.week-meal').css('height', '7em');
        $('.week-meal').css('margin-bottom', '1em');
      }
      else {
        $('.week-meal').css('height', '6em')
        $('.week-meal').css('margin-bottom', '10px')
      }

      if (zoom < .9) {
        $('.add-meal-box').find('h3').css('margin-bottom', '-1em');
        $('.add-meal-box').find('h3').css('font-size', '.6em');
      }
      else {
        $('.add-meal-box').find('h3').css('margin-bottom', '0')
        $('.add-meal-box').find('h3').css('font-size', '.75em');
      }

      $('.weekly-planner').animate({ 'zoom': zoom }, 100);
      $('.daily-planner').animate({ 'zoom': zoom }, 100);
    };

    //need to go old school because .click function doesn't work on newly appended elements
    //opens actios for an existing event on the page
    $(document).on('click', '.mobile-event', function() {
      $(".event-actions-mobile").css("display", "block");
      $("html, body").animate({ scrollTop: 0 }, "slow");
      var imageClass = $(this).attr('data-image')
      var recipeId =   $(this).attr('data-recipe')
      var recipeLink = "/recipes/"+recipeId+""
      var recipeName = $(this).attr('data-name')
      var recipeName = $(this).attr('data-recipe-name')
      var recipeServings = $(this).attr('data-servings')
      var eventId = $(this).attr('data-event')

      $(".image-container").addClass(imageClass)
      $("#recipe-title-link").attr("href", recipeLink)
      $("#recipe-title").text(recipeName)
      $("#servings").find('h3').text(recipeServings + "s")
      $("#num-servings").text(recipeServings)
      $("#num-servings").attr("data", eventId)
      $("#remove-event").attr("data", eventId)
    });

    //user clicked the 'add meal' box
  	$('.add-meal').click(function() { 
  		date = $(this).attr('data');
  		meal = $(this).attr('data-one');
  		weekDay = $(this).attr('data-two')
  		startAt= $(this).attr('data-three')
  		mealData = $(this).attr('data-four')
  		mealColor = $(this).attr('data-five')

  		$("#meal-day").attr("data", date);
  		$("#meal-day").attr("data-one", meal);
  		$("#meal-day").attr("data-two", weekDay)
  		$("#meal-day").attr("data-three", startAt)
  		$("#meal-day").attr("data-four", mealData)
  		$("#meal-day").attr("data-five", mealColor)
  		$("#meal-day").text(weekDay + " " + meal);

      loadEvents(date, mealData)
  		$(".recipe-selection-mobile").css("display", "block");
      $("html, body").animate({ scrollTop: 180 }, "slow");
  	});

    //user clicked the x in the recipe selection modal
  	$('#hide-recipe-selection').click(function() { 
  		$('.recipe-selection-mobile').css('display', 'none');
      recipes = $('.fc-event');
      recipes.each(function(i, obj) {
        selected = $(obj).find('#selected');
        if ( selected )
          selected.remove()

      })
  	});

    //user clicked x in the event actions modal
    $('#hide-event-actions').click(function() { 
      hideEventActions()
    });

    function hideEventActions() {
      $('.event-actions-mobile').css('display', 'none');
      $('.image-container').attr('class', 'image-container');
      $('#recipe-title-link').attr('href', '');
      $('#recipe-title').text('');
    }

    //user clicked either the plus or the minus for add servings in the event actions modal
    $(".change-serving").click(function() {
      var id = parseInt($("#num-servings").attr("data"))
      var add
      var numServings = parseInt($('#num-servings').text)
      if ($(this).hasClass("add")) {
       add = true
      }
      else {
        add = false
      }
      var data = {
          id: id,
          add: add
                  };

        $.ajax({//ajax call 
                  type:'POST',
                  data: data,
                  url:"/events/"+id+"/change_serving",
              
                  success:function (response) {
                    console.log("response")
                    $('#num-servings').text(response)
                    $('#servings').find('h3').text(response + "s")
                    events = $('.mobile-event')
                    events.each(function(i, obj) {
                      if (parseInt($(obj).attr("data-event")) == id) {
                        $(obj).find('.servings').text(response + "s")
                        $(obj).attr('data-servings', response)
                      }
                    });
                  }

        });//end ajax call
    });

    //user clicked the remove event option in the event actions modal
    $('#remove-event').click(function() {
        var id = parseInt($("#remove-event").attr("data"))
        var weekCounter = parseInt($(".prev-week-link").attr("data"))

        data = {
          event: {
            id: id,
            week_counter: weekCounter,
          }
        }

        $.ajax({//ajax call 
            type:'DELETE',
            data: data,
            url:'/events/destroy',
            success:function (response) {
              events = $('.mobile-event')
              events.each(function(i, obj) {
                if (parseInt($(obj).attr("data-event")) == id) {
                  var meal = $(obj).parent('.meal')
                  var mealTypes = $(obj).closest('.meal-types')
                  var addMealBig = $(mealTypes).find('.add-meal-big')
                  var addMealSmall = $(mealTypes).find('.add-meal-short')
                  var childCount = $(mealTypes).find('.added-meals div').length;
                  //change add meal will only happen when there is on event left in category
                  //in this case, since we update the box before the meal is deleted, the number of children
                  //in the meal types category will be 1
                  if (childCount == 1) {
                    $(addMealSmall).attr("id", "hidden")
                    $(addMealBig).removeAttr("id")
                  }
                  $(meal).remove()
                }
              });

              hideEventActions()
            }
        });
    });

    //loops through recipes in recipe selection modal and puts a white star with green background circle if those recipes
    //have been selected
    function loadEvents(day, mealData) {
      element = "#" + day
      childElement = "#" + mealData
      section =  $(element).find(childElement);
      events = section.children('.added-meals').children()
      eventIds = []
      events.each(function(i, obj) {
        id = parseInt($(obj).attr('data'));
        eventIds.push(id);
      });
      updateSelection(eventIds);
    };

    function updateSelection(eventIds) {
      recipes = $('.fc-event');
      recipes.each(function(i, obj) {
        recipeId = parseInt($(obj).attr('data-one'));
        isSelected = ( $.inArray( recipeId, eventIds ) );
        if ( isSelected == 1 || isSelected == 0 )
          $(obj).append("<span id='selected'></span>");
      });
    };





    //user clicked a recipe in the recipe selection modal, adding it to there planner
  	$('.fc-event').click(function() {
      if ($(this).find('#selected').length) {
      }
      else {
  		  date = $("#meal-day").attr('data');
  		  meal = $("#meal-day").attr('data-one');
  		  weekDay = $("#meal-day").attr('data-two')
  		  time = $("#meal-day").attr('data-three')
  		  mealData = $("#meal-day").attr('data-four')
  		  mealColor = $("#meal-day").attr('data-five')
  		  recipeFriendlyName = $(this).attr('data-three')
  		  recipeServings = $(this).attr('data-two')
  		  recipeId = $(this).attr('data-one')
  		  recipeName = $(this).attr('data')
  		  startAt = date + time 
        $(this).append("<span id='selected'></span>");

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
                    element = "#" + date 
                    childElement = "#" + mealData
                    hideMealNameBig = "." + date + "-" + mealData + "-big"
                    hideMealNameSmall = "." + date + "-" + mealData + "-small"

                    updateContainerHeight(50)
                    
                    $(element).find(childElement).children('.added-meals').append("<div class='meal' data="+recipeId+"><a class='mobile-event fc-event-container "+recipeName+"' id='mobile-event' data-event="+response+" data-recipe="+recipeId+" data-image="+recipeName+" data-servings="+recipeServings+" data-recipe-name="+recipeFriendlyName+"><span class='servings'>"+recipeServings+"s</span><span class='event-title' style='background-color: "+mealColor+"'>"+recipeFriendlyName+"</span></a></div>")

                    $(hideMealNameBig).attr("id", "hidden")
                    $(hideMealNameSmall).removeAttr("id")

                  }

        });//end ajax call

      };

  	});

    //udpates the weekly planner height based on the number of recipes in the largest container when the user adds a recipe
    function updateContainerHeight(change) {
        container = $('.meals')
        containerHeight = container.outerHeight()
        newHeight = containerHeight + change
        container.css('height', newHeight)
    };
    //sets the container height as the user first visist the page based on the number of recipes
    function calcContainerHeight() {
      outerHeights = []
      days = $('.one-day')
      days.each(function(i, obj) {
        height = $(this).outerHeight()
        outerHeights.push(height)
      });
      tallest = Math.max.apply(Math, outerHeights) + 300; 
      $('.meals').css('height', tallest)
    };

});