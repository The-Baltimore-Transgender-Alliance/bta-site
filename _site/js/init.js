(function($){
  $(function(){

	$('.button-collapse').sideNav();
	$('.carousel').carousel();
	$('.parallax').parallax();
	$('.materialboxed').materialbox();
	$('#cwmodal').modal({});
	$('#cwmodal').modal('open');
  });
   // end of document ready
})(jQuery); // end of jQuery name space

function goBack() {
	window.history.back();
}
