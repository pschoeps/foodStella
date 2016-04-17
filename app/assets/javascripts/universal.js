$(document).ready(function() {
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
    }
  })

  $('.x').each(function() {
    //set size
    var th = $(this).height(),//box height
        tw = $(this).width(),//box width
        im = $(this).find('a').children('img'),//image
        ih = im.height(),//inital image height
        iw = im.width();//initial image width
    if (ih>iw) {//if portrait
        im.addClass('ww').removeClass('wh');//set width 100%
    } else {//if landscape
        im.addClass('wh').removeClass('ww');//set height 100%
    }
    //set offset
    var nh = im.height(),//new image height
        nw = im.width(),//new image width
        hd = (nh-th)/2,//half dif img/box height
        wd = (nw-tw)/2;//half dif img/box width
    if (nh<nw) {//if portrait
        im.css({marginLeft: '-'+wd+'px', marginTop: 0});//offset left
    } else {//if landscape
        im.css({marginTop: '-'+hd+'px', marginLeft: 0});//offset top
    }
  });

});