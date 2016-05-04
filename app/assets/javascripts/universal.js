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
                $(this).draggable({
                    zIndex: 999,
                    revert: true,      // will cause the event to go back to its
                    revertDuration: 0  //  original position after the drag
                });

                // $(this).click(function(){
                //   $('#external-events-listing').css('height', $('#external-events-listing').height() + 'px');
                //   $('.fc-slats td').css('box-shadow', 'inset 0 0 90px #e8e8e8');
                //   $(this).css({
                //     'box-shadow': '2px 2px 18px #888',
                //     'float': 'left'
                //   });
                //   $(this).animate({
                //     'height': '108px',
                //     'width': '108px',
                //     'margin': '4px',
                //   }, 200, function(){
                //     $(this).animate({
                //       'height': '100px',
                //       'width': '100px',
                //       'margin': '8px',
                //       }, 200, function(){
                //         $(this).css({
                //           'box-shadow': '0 0 0px #444',
                //           'float': 'none'
                //         });
                //         $('.fc-slats td').css('box-shadow', 'inset 0 0 0px #fff');
                //         $('#external-events-listing').css('height', 'auto');
                //       });
                //   });
                // });


            });

    $('#snacks').click(function() {
    if ( $('#snacks-selection').css('display') == 'none' )
      $('#snacks-selection').css('display','block');
    else
      $('#snacks-selection').css('display','none');
  });

  $('#sidedish').click(function() {
    if ( $('#sidedish-selection').css('display') == 'none' )
      $('#sidedish-selection').css('display','block');
    else
      $('#sidedish-selection').css('display','none');
  });

  $('#maindish').click(function() {
    if ( $('#maindish-selection').css('display') == 'none' )
      $('#maindish-selection').css('display','block');
    else
      $('#maindish-selection').css('display','none');
  });

  $('#dessert').click(function() {
    if ( $('#dessert-selection').css('display') == 'none' )
      $('#dessert-selection').css('display','block');
    else
      $('#dessert-selection').css('display','none');
  });

  $('#drink').click(function() {
    if ( $('#drink-selection').css('display') == 'none' )
      $('#drink-selection').css('display','block');
    else
      $('#drink-selection').css('display','none');
  });



  $('button').click(function() {
    var containerHeight = $('.meal-selection').outerHeight() + 80;
    var sidebarHeight = $('.sidebar').outerHeight()

    if (containerHeight > sidebarHeight) {
      $('.sidebar').css('height', containerHeight + 'px');
      // $('.sidebar').css('overflow', 'scroll');
    }
    else {
       // $('.sidebar').css('overflow', 'auto');
    }
  })


 $('.latest').click(function() {
    console.log("checked")
    if ( $('#filterrific_latest_').is(":checked") )
      $(this).css('color', 'white');
    else
      $(this).css('color', '#819800');

  });

 if( $('.recipes-page').length && $('.sidebar').length ){
    console.log('recipes page');
    var contentHeight = $('.recipes-page').outerHeight();
    contentHeight += 100;   // for footer margin

    // $('.footer').css('margin-top', 0);
    // $('.sidebar').css({
    //   'height': contentHeight + 'px',
    //   'max-height': contentHeight + 'px'
    // });
 }

  






});











