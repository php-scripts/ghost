<?php
  // parse and answer question
  $question = htmlspecialchars(strip_tags($_REQUEST['question']));
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
    
    if ($_REQUEST['redirect']=='false') {
      print_r($sentence);
      echo "<br/>\n";
    }

    // quess language
    $language = 'en';
    if (strpos(' '.$_SERVER['HTTP_ACCEPT_LANGUAGE'],'sk') > 0) 
      $language = 'sk';
    
    // language override via cookie or param
    if ( ($_COOKIE['lang'] == 'en')||($_REQUEST['lang'] == 'en') ) $language = 'en';
    if ( ($_COOKIE['lang'] == 'sk')||($_REQUEST['lang'] == 'sk') ) $language = 'sk';
    
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

    // parse answer for attributes
    if (strpos(' '.$answer,'$') > 0) {
      $attr = explode("\n",file_get_contents("data/$language/attribute.dat"));
      print_r($attr);
      for ($a=0; $a<count($attr) / 2; $a++)
        $answer = str_replace($attr[2*$i],$attr[2*$i+1],$answer);
    }

    // lets lurker also log answer (so we see in lurker's log what was question and answer)
    ghostLurkerAsk("--> $answer",$language);

    if ($_REQUEST['redirect']=='false')
      echo "Q: $question<br/>\nA: $answer<br/>\n";

    // store answer to the begining of chat file
    $chat = "<div class=\"answer\">$answer</div>\n<div class=\"question\">$question</div>\n";
    $chat .= file_get_contents('chat.txt');
    file_put_contents('chat.txt',$chat);
  }
  
  // redirect back to index page
  if ($_REQUEST['redirect']!='false')
    header('Location: index.php');
?>
