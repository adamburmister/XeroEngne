$(document).ready(function() {

  // Clickable rows
  $('#btnConnect').on('click', function(e) {
    e.preventDefault();

    var btn = $(this);
    var orgName = $(this).data('orgname');
    var short_code = $(this).data('shortcode');
    var btnRow = $('.oauthConnectButtons .connect');
    var statusRow = $('.oauthConnectButtons .waiting');

    btn.attr('disabled');

    btnRow.hide();
    statusRow.show();

    new $.XeroLogin({
        url: e.currentTarget.href // The local URL used to generate the new token request
      })
      .done(function(win, json) {
        win.close();
        var connectedOrg = $.parseJSON(json);
        if(short_code && connectedOrg.short_code !== short_code) {
          btnRow.show();
          btn.removeAttr('disabled');
          statusRow.hide();
          alert("Oops! You connected to the wrong Xero Organisation! You connected to " + connectedOrg.name + " instead of " + orgName + ".\n\nTry again, selecting the correct organisation \nname from the dropdown on Xero.");
        } else {
          // Handle successful connection
          statusRow.html('<b>Connected successfully! Please wait...</b>');
          window.location.href = '/';
        }
      })
      .fail(function(reason) {
        btn.removeAttr('disabled');
        btnRow.show();
        statusRow.hide();
        // Handle failed connection
        switch(reason) {
          case $.XeroLogin.CANCELLED:
          case $.XeroLogin.CLOSED:
            // alert("Login cancelled by user");
            break;
          case $.XeroLogin.FAILED:
            alert("Login failed! Please try again.");
            break;
        }
      });

      return false;
  });
});