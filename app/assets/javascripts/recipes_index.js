$('.recipes.index').ready(function() {
  if (gon.user_login_count == 1) {
    $('.recipes.index').ready(function() {
      var intro = introJs();
      intro.setOptions({
        scrollToElement: false
      });
      intro.start();
      $('.footer').css('display', 'none')

      $('.introjs-skipbutton').click(function() {
        $('.footer').css('display', 'block')
      })
    });
  };
});

