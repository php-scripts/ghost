<?php
  // parse and answer question
  $question = htmlspecialchars($_REQUEST['question']);
  $answer = '';

  if ($_REQUEST['redirect']!='false')
    header('Content-Type: text/plain; charset=utf-8');

  if ( $question != '' ) {

    // include parts
    require_once "drknow.php";
    require_once "dumb.php";
    require_once "lurker.php";
    require_once "sentence.php";
    require_once "sam.php";
    require_once "variation.php";
    require_once "topic.php";

    // split question to words
    $sentence = ghostSentence($question);
    
    print_r($sentence);

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
    if (empty($answer)) $answer = ghostVariationAsk($sentence,$language);
    if (empty($answer)) $answer = ghostTopicAsk($sentence,$language);

    // dumb is last resort
    if (empty($answer)) $answer = ghostDumbAsk($sentence,$language);

    // lets lurker also log answer (so we see in lurker's log what was question and answer)
    ghostLurkerAsk("--> $answer",$language);

    // store answer to the begining of chat file
    $chat = "<div class=\"answer\">$answer</div>\n<div class=\"question\">$question</div>\n";
    $chat .= file_get_contents('chat.txt');
    file_put_contents('chat.txt',$chat);
  }
  
  // redirect back to index page
  if ($_REQUEST['redirect']!='false')
    header('Location: index.php');
?>
