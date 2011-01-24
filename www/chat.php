<?php
  // parse and answer question
  $question = htmlspecialchars($_REQUEST['question']);
  $answer = '';

  if ( $question != '' ) {

    // include parts
    require_once "drknow.php";
    require_once "dumb.php";
    require_once "lurker.php";
    require_once "sentence.php";
    require_once "sam.php";

    // split question to words
    $sentence = ghostSentence($question);

    // quess language
    $language = 'en';
    if (strpos(' '.$_SERVER['HTTP_ACCEPT_LANGUAGE'],'sk') > 0) 
      $language = 'sk';
    
    // ask various AI one by one

    // first is just a logger
    if (empty($answer)) $answer = ghostLurkerAsk($question,$language);

    // real AIs
    if (empty($answer)) $answer = ghostDrknowAsk($sentence,$language);
    if (empty($answer)) $answer = ghostSamAsk($sentence,$language,'sam');

    // dumb is last resort
    if (empty($answer)) $answer = ghostDumbAsk($sentence,$language);

    // store answer to the begining of chat file
    $chat = "<div class=\"answer\">$answer</div>\n<div class=\"question\">$question</div>\n";
    $chat .= file_get_contents('chat.txt');
    file_put_contents('chat.txt',$chat);
  }
  
  // redirect back to index page
  header('Location: index.php');
?>
