var currentMousePos = {
    x: -1,
    y: -1
};

//selects for all pages that show sidebar on desktop
$('.users.calendar.comp, .recipes.index.comp, .users.day_calendar.comp').ready(function() {
  console.log("inside")
  resetSidebar();
  $(window).resize( function(e){
        resetSidebar();
  });

  function resetSidebar() {
    $('#sidebar-col').trigger('detach.ScrollToFixed');
    console.log("is this working");
    $('#sidebar-col').scrollToFixed({
      limit: $('.footer').offset().top - $('#sidebar-col').height(),
      spacerClass: 'sidebar-spacer'
    });
  };
});




$(document).ready(function(e) {


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


  if ( $('#filterrific_latest_').is(":checked") )
    $(this).css('color', '#819800');
  else
    $(this).css('color', 'white');

 $('.latest').click(function() {
    console.log("checked")
    if ( $('#filterrific_latest_').is(":checked") )
      $(this).css('color', '#819800');
    else
      $(this).css('color', 'white');

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

function getMobileOperatingSystem() {
  var userAgent = navigator.userAgent || navigator.vendor || window.opera;

  if( userAgent.match( /iPad/i ) || userAgent.match( /iPhone/i ) || userAgent.match( /iPod/i ) )
    return 'iOS';
  else if( userAgent.match( /Android/i ) )
    return 'Android';
  else
    return 'unknown';
}