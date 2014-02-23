$(document).ready(function() {
    var currbg = $(".background").last();
    var nextbg = $(".background").first();
    var tmp;

    $('body').waitForImages({
        finished: function() {
            console.log('Both backgrounds loaded foo');
            $('.spinner-container').fadeOut(400);
        },
        waitForAll: true
    });

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
        // console.log(preload);
        nextbg = $('<div class="background" style="background-image: url('+preload+'); z-index: -3;"> </div>');
        $('body').append(nextbg);

      });
      nextbg.fadeIn(800);
    });

    $('.button.another').click(getTask);

    function getTask() {
        var fade = $('#mission').fadeTo(200, 0).promise();
        var json = $.getJSON( "/radness").promise();
        $.when(fade, json).done(function(a, json) {
          var data = json[0];
          // console.log(data);
          $('#mission').html(data.task+' <em>'+data.deadline+'</em>');
          $('#mission').fadeTo(100, 1);

          if (data.id == -1) {
            $('#missionlabel').fadeTo(100, 0);
          } else if (data.id == -2) {
            $('#missionlabel').fadeTo(100, 0);
            $('.button.another').attr('href', '/logout').html('Reset').off('click');
          } else {
            $('#missionlabel').fadeTo(100, 1);
          }
        });
    };
});

//Analytics
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-48153837-1', 'extraordinary.herokuapp.com');
ga('send', 'pageview');