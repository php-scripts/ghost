<html>
	<head>
		<title>Ghost</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="icon" href="icon.png" />
    <link rel="alternate" type="application/rss+xml" href="rss-news.php" title="Ghost news" />
    <link rel="alternate" type="application/rss+xml" href="rss-chat.php" title="Ghost recent chats" />
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
      <input name="question" autofocus />
      <input type="submit" />
    </form>  
    
    <?php
      //  no question, so only show chats
      $chat = explode("\n",file_get_contents('chat.txt'));
      for ($i=0; ($i<2*20)&&($i<count($chat)-1); $i++)
        echo $chat[$i]."\n";

      /*
      TODO:
      - dialect
      - attribute (veci ako meno, vek, miesto, ...) 
      - sam
      - variation
      - topic
    
      Later:
      - add full locale support (e.g. localized questions to drknow.php)
      - anglicke what's teraz sentence rozdeli zle na "what s", tak isto I'm, I'll, don't
      - for performance reasons, I should append new answers to the end of file or something
      - rss s nezodpovedanymi otazkami + pre admina webstranku na pridavanie odpovedi
      */
    ?>  

	</body>
</html>
