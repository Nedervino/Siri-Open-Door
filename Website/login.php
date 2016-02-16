<?php
        session_start();

        use google\appengine\api\users\User;
        use google\appengine\api\users\UserService;

        $user = UserService::getCurrentUser();

        if (isset($user)) {
          if($user->getNickname())
          $mailTim = '<EMAIL_RESIDENT_1>';
          $mailJetse = '<EMAIL_RESIDENT_2>';
          $mailMees = '<EMAIL_RESIDENT_3>';

          //if logged in as house resident
          if ((strcmp(htmlspecialchars($user->getNickname()), $mailTim) == 0) || (strcmp(htmlspecialchars($user->getNickname()), $mailJetse) == 0) || (strcmp(htmlspecialchars($user->getNickname()), $mailMees) == 0)) {     
              $_SESSION['loggedIn'] = "1";
              header("Location: opendoor.php");
          } else {
              $_SESSION['loggedIn'] = "";
              echo sprintf('Your current Google account, %s, does not have access to this application (<a href="%s">sign out</a>)',
              $user->getNickname(),
              UserService::createLogoutUrl('/'));
              exit;
          }
          
        }
?>