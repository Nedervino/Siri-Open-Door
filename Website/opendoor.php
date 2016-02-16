<?php
  use google\appengine\api\users\User;
  use google\appengine\api\users\UserService;
  $user = UserService::getCurrentUser();
  session_start();
  if($_SESSION["loggedIn"] != true) {
    if (isset($user)) {
      echo sprintf('Your current Google account, %s, does not have access to this application (<a href="%s">sign out</a>)',
      $user->getNickname(),
      UserService::createLogoutUrl('/'));
    }
    exit();
  } else {
    if (isset($user)) {
      if($user->getNickname())

      $mailTim = '<EMAIL_RESIDENT_1>';
      $mailJetse = '<EMAIL_RESIDENT_2>';
      $mailMees = '<EMAIL_RESIDENT_3>';

      if (strcmp(htmlspecialchars($user->getNickname()), $mailTim) == 0)        {$nameString = "Tim";}
      else if (strcmp(htmlspecialchars($user->getNickname()), $mailJetse) == 0) {$nameString = "Jetse";}
      else if (strcmp(htmlspecialchars($user->getNickname()), $mailMees) == 0)  {$nameString = "Mees";}     
    }
  }
?>

<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>
      Open Your Front Door Via The Internet
    </title>

    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
    <link rel="stylesheet" href="http://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.4.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
    <style>

    </style>
  </head>

  <body >
    <!--<div><a href="/dashboard.php" color:#49c0f0>Dashboard</a></div>-->

    <div id="parent">
      <div id="child" style="text-align:center">
        <h3>Welcome<?php echo ", $nameString" ?></h3>
        <form action="formhandler.php" method="POST" autocomplete="on">
          <br><br><br><br>
          <input type="password" placeholder="Password" name="psw" class="pwordinput" font-color="black" pattern="[0-9]{4}" title="Enter a four digit password" required>
          <br><br>
          <button type="submit" id="submit" class="submitButton" value="Send command" title ="Send HTTP post request to server">Let me in</button>
         </form>

         <div id="result"></div>
         <br>
      </div>
    </div> 


    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
    <script> 
      $(document).ready(function() {    //run as soon as document is ready to be manipulated, so  possibly before all images are loaded
        $("form").on('submit',function (e) {  //$(selector).action is the basic jquery syntax, you can use all css selectors and some custom jquery ones

          e.preventDefault();
          document.getElementById("submit").innerHTML = "<div class=\"spinner\"><div class=\"spinner__item1\"></div><div class=\"spinner__item2\"></div><div class=\"spinner__item3\"></div><div class=\"spinner__item4\"></div></div>";  //"<i class=\"fa fa-spinner fa-pulse\"></i>";
          $.ajax({
            type: 'post',
            url: 'formhandler.php',
            data: $('form').serialize(),
            success: function (data) {
              //alert(data);
              document.getElementById("submit").innerHTML = data;
            }
          });

        });
      });
    </script>

  </body>
</html>
