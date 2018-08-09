$(document).ready(function(){
  $(".youtube-video").fitVids();

  var myForm = $('myForm');
  if (myForm.length > 0) {
    myForm.find('[type=text], textarea').each(function(el) {
      new OverText(el);
    });

    new Form.Validator.Inline(myForm[0]);
  }
});
