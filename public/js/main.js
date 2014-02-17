$(document).ready(function() {
    var currbg = $(".background").last();
    var nextbg = $(".background").first();
    var tmp;

    $( "#main" ).on( "click", ".button.next", function() {
      var current = $(this).parents(".slide").first();
      var next = current.next();
      
      if(next.attr('data-prefetch-task')) getTask();

      // Crossfade the divs
      current.fadeOut(400, function() {
        next.fadeIn();
      });

      // Crossfade the backgrounds
      currbg.fadeTo(800, 0, function() {
        currbg.remove();
        // swap
        currbg = nextbg;
        currbg.css("z-index", -2);

        // preload the next background
        var preload = $(next.next()[0]).attr("data-bg");
        if (preload == undefined) {
            $('footer').fadeIn(400);
            return;
        }
        console.log(preload);
        nextbg = $('<div class="background" style="background-image: url('+preload+'); z-index: -3;"> </div>');
        $('body').append(nextbg);

      });
      nextbg.fadeIn(800);
    });

    $('.button.another').click(getTask);

    function getTask() {
        $.getJSON( "/radness", function( data ) { 
            console.log(data);
            $('#mission').html(data.task+' <em>'+data.deadline+'</em>');
            window.location.hash = data.id;
        });
    };
});