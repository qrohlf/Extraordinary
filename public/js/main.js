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
            $('footer').fadeIn(200);
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
            $('#mission').fadeTo(400, 0, function() {
              $('#mission').html(data.task+' <em>'+data.deadline+'</em>');
              $('#mission').fadeTo(400, 1);
            });
            

            if (data.id == -1) {
              $('#missionlabel').fadeTo(400, 0);
            } else if (data.id == -2) {
              $('#missionlabel').fadeTo(400, 0);
              $('.button.another').attr('href', '/logout').html('Reset').off('click');
            } else {
              $('#missionlabel').fadeTo(400, 1);
            }
        });
    };

    $('.submission.button').click(function() {
        var task = $('#what').text();
        var deadline = $('#when').text();
        $.post('/submit', {task: task, deadline: deadline}, function(data) {
          console.log(data);
          if (data == 'success') {
            $('#submit-form').fadeTo(400, 0, function() {
              $('#success').fadeTo(400, 1);
            });

          }
        });
    });
});