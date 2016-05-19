var currentMousePos = {
    x: -1,
    y: -1
};




$(document).ready(function() {
  
  


   $(document).on("mousemove", function (event) {
        currentMousePos.x = event.pageX;
        currentMousePos.y = event.pageY;
    });

    var calendarWidth = $('#calendar').outerWidth()

    $('.calendar-header').css('width', calendarWidth + 'px');


            /* initialize the external events
            -----------------------------------------------------------------*/

            $('#external-events .fc-event').each(function() {

                // store data so the calendar knows to render an event upon drop
                $(this).data('event', {
                    title: $.trim($(this).attr('data')),
                    stick: true // maintain when user navigates (see docs on the renderEvent method)
                });

                // make the event draggable using jQuery UI
                if( $('.calendar-nav').length ){  // only make items draggable on calendar view
                  $(this).draggable({
                      zIndex: 999,
                      revert: true,      // will cause the event to go back to its
                      revertDuration: 0  //  original position after the drag
                  });

                  $(this).mousedown(function(){
                    // $(this).closest('.selection').addClass('selection-dragging');
                  });

                  $(this).mouseup(function(){
                    // $(this).closest('.selection').removeClass('selection-dragging');
                  });
                }

              });

  //   $('#snacks').click(function() {
  //   if ( $('#snacks-selection').css('display') == 'none' )
  //     $('#snacks-selection').css('display','block');
  //   else
  //     $('#snacks-selection').css('display','none');
  // });

  // $('#sidedish').click(function() {
  //   if ( $('#sidedish-selection').css('display') == 'none' )
  //     $('#sidedish-selection').css('display','block');
  //   else
  //     $('#sidedish-selection').css('display','none');
  // });

  // $('#maindish').click(function() {
  //   if ( $('#maindish-selection').css('display') == 'none' )
  //     $('#maindish-selection').css('display','block');
  //   else
  //     $('#maindish-selection').css('display','none');
  // });

  // $('#dessert').click(function() {
  //   if ( $('#dessert-selection').css('display') == 'none' )
  //     $('#dessert-selection').css('display','block');
  //   else
  //     $('#dessert-selection').css('display','none');
  // });

  // $('#drink').click(function() {
  //   if ( $('#drink-selection').css('display') == 'none' )
  //     $('#drink-selection').css('display','block');
  //   else
  //     $('#drink-selection').css('display','none');
  // });



  // $('button').click(function() {
  //   var containerHeight = $('.meal-selection').outerHeight() + 80;
  //   var sidebarHeight = $('.sidebar').outerHeight()

  //   if (containerHeight > sidebarHeight) {
  //     $('.sidebar').css('height', containerHeight + 'px');
  //     // $('.sidebar').css('overflow', 'scroll');
  //   }
  //   else {
  //      // $('.sidebar').css('overflow', 'auto');
  //   }
  // })

  if ( $('#filterrific_latest_').is(":checked") )
    $(this).css('color', 'white');
  else
    $(this).css('color', '#819800');

 $('.latest').click(function() {
    console.log("checked")
    if ( $('#filterrific_latest_').is(":checked") )
      $(this).css('color', 'white');
    else
      $(this).css('color', '#819800');

  });

 function checkFilters(){
    $('.dropdown').each(function(){
      var clear = true;
      $(this).find(':input').each(function(){
        if($(this).is(':checked'))
          clear = false;
      });
      if(clear) $(this).find('.dropdown-toggle').css('color','white');
      else $(this).find('.dropdown-toggle').css('color','#819800');
    });
  }

 $('.dropdown').find(':input').each(function(){
  $(this).click(function(){
    checkFilters();
  });

  checkFilters();

 })



 // if( $('.recipes-page').length && $('.sidebar').length ){
 //    console.log('recipes page');
 //    var contentHeight = $('.recipes-page').outerHeight();
 //    contentHeight += 100;   // for footer margin
 // }



});











