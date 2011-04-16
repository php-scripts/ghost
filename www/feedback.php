<?php
  // save feedback
  $name = substr(htmlspecialchars(strip_tags($_REQUEST['name'])),0,30);
  $feedback = str_replace("\n","<br />",htmlspecialchars(strip_tags($_REQUEST['feedback'])));
  
  if ($name=='anonymous') $name = '';

  // store feedback to the begining of feedback file
  $chat = "";
  $chat .= "<div class=\"feedback\"><span class=\"name\">$name</span>$feedback</div>\n";
  $chat .= file_get_contents('feedback.txt');

  // keep only first 10 lines
  $lines = explode("\n",$chat);
  $lines = array_splice($lines,0,10);
  $chat = implode("\n",$lines);
 
  // save feedback
  file_put_contents('feedback.txt',$chat);
  
  // redirect back to index page
  header('Location: index.php');
?>
