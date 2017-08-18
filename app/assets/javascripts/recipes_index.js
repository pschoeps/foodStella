$('.recipes.index').ready(function() {
  // window.localStorage.setItem('indoctrinated', false);
  if (gon.user_login_count == 1 && !window.localStorage.getItem('indoctrinated') ){
    window.localStorage.setItem('indoctrinated', true);
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

  // $(document).click('#indoctrinate', function(){
  //   $('.recipes.index').ready(function() {
  //     var intro = introJs();
  //     intro.setOptions({
  //       scrollToElement: false
  //     });
  //     intro.start();
  //     $('.footer').css('display', 'none')

  //     $('.introjs-skipbutton').click(function() {
  //       $('.footer').css('display', 'block')
  //     })
  //   });
  // });
});

