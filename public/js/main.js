$( "#main" ).on( "click", ".button.next", function() {
  var current = $(this).parents(".slide").first();
  var next = current.next();
  console.log(current);
  current.toggleClass("active");
  next.toggleClass("active");
});