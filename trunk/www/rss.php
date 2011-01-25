<?php
  // basic rss feed of recent chats
  require_once "purin2/rss/rss.php";
  puRssBegin("Recent ghost chat","Last 20 chats from ghost main page","dusan.halicky@gmail.com","http://ayass.xf.cz/ghost/rss.php");
  $file = file_get_contents('chat.txt');
  $lines = explode("\n",$file);
  for ($i=0; $i<count($lines); $i++) {
    $lines[$i] = str_replace('question">','question"><br/>Q: ',$lines[$i]);
    $lines[$i] = str_replace('answer">','answer">A: ',$lines[$i]);
  }
  $file = implode("\n",$lines);
  puRssItem(md5($file),"New comments","http://ayass.xf.cz/ghost/rss.php","http://ayass.xf.cz/ghost/rss.php",$file);
  puRssEnd();
?>