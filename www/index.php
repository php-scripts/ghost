<?php
    require "config.php";
?>
<html>
	<head>
		<title>Ghost</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="icon" href="icon.png" />
    <link rel="alternate" type="application/rss+xml" href="rss.php" title="Ghost recent chats" />
    <link rel="alternate" type="application/rss+xml" href="rss-improve.php?lang=sk" title="Recent slovak improvements" />
    <link rel="alternate" type="application/rss+xml" href="rss-improve.php?lang=en" title="Recent english improvements" />
    <link rel="alternate" type="application/rss+xml" href="rss-feedback.php" title="Recent feedbacks" />
    <link rel="stylesheet" type="text/css" href="index2.css" />
    <meta name="viewport" content="width=device-width" />
	</head>
	<script src="index.js"></script>
	
  <!-- uncomment this if you want text-to-speech support -->
  <script src="mespeak/mespeak.js"></script>
  <script type="text/javascript">
    function sayInit() {
      if (meSpeak) {
        meSpeak.loadConfig("mespeak/config.json");
        meSpeak.loadVoice("mespeak/en.json");
      }
    }

    function sayAnswer() {
	  if (meSpeak) {	
        try {
          if (location.search.match('&answer=')) {
            var answer = decodeURIComponent(location.search.split('&answer=').slice(-1)[0]).replace(/\+/g, ' ');
            meSpeak.speak(answer, { amplitude: 100, wordgap: 0, pitch: 50, speed: 175, variant: 0 })
          }
        } catch(e) {
        }
      }
    }
  </script>

	<body onload="document.getElementById('input1').focus(); if (localStorage && localStorage['name']) document.getElementById('name').value = localStorage['name']; sayInit(); sayAnswer();">
	<script>
	    function link()
	    {
		window.location.href = "<?php echo $param["site_link"]; ?>";
	    }
	</script>
    <?php
      if ($_SERVER['HTTP_HOST'] == 'localhost') {
        echo '<center><div style="border: 1px solid gray; background: #FFFFAA;">localhost</div></center>';
      }
    ?>

    <div id="logo" onclick="link()"></div>

    <!-- char form -->
    <form action="chat.php" method="get">
      <?php
        require_once "next/common.php";
        // detect language    
        $language = ghostLanguage();
        if ($language == 'en') {
          $en1 = ' checked';
          $sk1 = ' ';
        } else {
          $en1 = ' ';
          $sk1 = ' checked';
        };
        echo '<input type="radio" id="lang_en" name="lang" value="en" '.$en1.'/><label for="lang_en"><u>English</u></label>';
        echo '<input type="radio" id="lang_sk" name="lang" value="sk" '.$sk1.'/><label for="lang_sk"><u>Slovensky</u></label>';
      ?>
      <input type="submit" id="top_sub"/>
      <br/>
      <input id="input1" type="text" name="question" autofocus />
    </form>  

    <!-- feedback form -->
    <div class="feedbackform">
      <form action="feedback.php" method="post">
        <div class="middle">
        </div>
        <div class="name">
          Name: <input id="name" type="text" name="name" value="anonymous"/>
        </div>
        <div class="message">
          Feedback message: <textarea id="input2" name="feedback"></textarea>
        </div>
        <div class="buttons">
          <input type="submit" onclick="localStorage.setItem('name',document.getElementById('name').value)"/>
        </div>
      </form>
      <!-- feedback messages -->
      <?php
        $chat = explode("\n",file_get_contents('feedback.txt'));
        for ($i=0; ($i<2*20+1)&&($i<count($chat)-1); $i++)
          echo $chat[$i]."\n";
      ?>
    </div>

    <!-- chat messages -->
    <?php
      //  no question, so only show chats
      $chat = explode("\n",file_get_contents('chat.txt'));
      for ($i=0; ($i<2*20+1)&&($i<count($chat)-1); $i++)
        echo $chat[$i]."\n";

      /*
      TODO:
      - rss feed for recent changes in topic user improvements
      - something for cleaning up lurker files from web, not just via ftp
      - database of capital cities and countries? or geographic AI
      - learn it few course words
      - add to drknow: "just tell me everything you know about fish."
      - 
      
      Later:
      - use eval class from phpclassess once their stupid site start working
      - for performance reasons, I should append new answers to the end of file or something (or maybe just use mysql like other sane people)
      */

    if ( $_SERVER['HTTP_HOST'] != 'localhost' ) {
        $fp = fopen('log.txt', 'a');
        fwrite($fp,"\n[".date(DATE_RFC822)."]\n");
        fwrite($fp,$_SERVER["REMOTE_ADDR"]."\n");
        fwrite($fp,@$_SERVER["HTTP_USER_AGENT"]."\n");
        fwrite($fp,@$_SERVER["HTTP_REFERER"]."\n");
        fclose($fp);
    }

    ?>  
        <div class="copy">© <?php echo date("Y"); ?> <a href="<?php echo $param["site_link"]; ?>"><?php echo $param["site_shrt"]; ?></a> [  Design By: <u>Ghost Fan</u> , Powered by <u>dvh</u> ] </div>
    
	</body>
</html>
