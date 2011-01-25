<html>
	<head>
		<title>Ghost</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="icon" href="icon.png" />
    <link rel="alternate" type="application/rss+xml" href="rss.php" title="Ghost recent chats" />
    <link rel="alternate" type="application/rss+xml" href="rss-pending.php" title="Pending corrections" />
    <link rel="stylesheet" type="text/css" href="index.css" />
	</head>
	<script src="index.js"></script>
  
	<body>

    <div id="logo">
      <a href="http://code.google.com/p/ghost/">
        <h1>ghost</h1>
        <h2>a tiny chat bot</h2>
      </a>
    </div>
  
    <form action="chat.php" method="get">
      <?php
        $lang = $_REQUEST['lang'];
        if ($lang == 'en') {
          $en1 = ' checked';
          $sk1 = ' ';
        } else {
          $en1 = ' ';
          $sk1 = ' checked';
        };
        echo '<input type="radio" id="lang_en" name="lang" value="en" '.$en1.'/><label for="lang_en">english</label>';
        echo '<input type="radio" id="lang_sk" name="lang" value="sk" '.$sk1.'/><label for="lang_sk">slovensky</label>';
      ?>
      <br/>
      <input type="text" name="question" autofocus />
      <input type="submit" />
    </form>  
    
    <?php
      //  no question, so only show chats
      $chat = explode("\n",file_get_contents('chat.txt'));
      for ($i=0; ($i<2*20)&&($i<count($chat)-1); $i++)
        echo $chat[$i]."\n";

      /*
      TODO:
      - overit ci ? alebo & v odpovedi alebo v improved nieco nerozbije, napr. ten improved lebo pouziva get parametre
      - 1 + 1 neprejde cez spliter
      - nevie kolko je hodin lebo to robil eval ktory este nie je spraveny
      - rss
        - pending improvements (v podstate 1 item data/en|sk/improve.dat)
      - for performance reasons, I should append new answers to the end of file or something (or maybe just use mysql like other sane people)
      */
    ?>  

	</body>
</html>
