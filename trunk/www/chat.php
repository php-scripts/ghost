<?php
  // parse and answer question
  $question = str_replace("\n"," ",htmlspecialchars(strip_tags($_REQUEST['question'])));
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

    // language override via cookie or param
    if ( ($_COOKIE['lang'] == 'en')||($_REQUEST['lang'] == 'en')||($_REQUEST['lang_en'] == 'on') ) $language = 'en';
    if ( ($_COOKIE['lang'] == 'sk')||($_REQUEST['lang'] == 'sk')||($_REQUEST['lang_sk'] == 'on') ) $language = 'sk';
    //echo "r-lang = ".$_REQUEST['lang']." language=$language<br/>\n";

    // quess language
    if (empty($language)) {
      $language = 'en';
      if (strpos(' '.$_SERVER['HTTP_ACCEPT_LANGUAGE'],'sk') > 0) 
        $language = 'sk';
    }   
    //echo "r-lang = ".$_REQUEST['lang']." language=$language<br/>\n";
    
    // ask various AI one by one

    // first is just a logger
    if (empty($answer)) $answer = ghostLurkerAsk($question,$language);

    // AI improved by users
    if (empty($answer)) $answer = ghostSamAsk($sentence,$language,'improve');

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
    $chat .= "<div class=\"question\">$question</div>\n";
    $chat .= "<div class=\"answer\">$answer<a class=\"improve\" title=\"Click to improve answer\" href=\"improve.php?question=$question&answer=$answer\">&#9997;</a></div>\n";
    $chat .= file_get_contents('chat.txt');
    // keep only first 20 lines
    $lines = explode("\n",$chat);
    $lines = array_splice($lines,0,20);
    $chat = implode("\n",$lines);
    // save chat
    file_put_contents('chat.txt',$chat);
  }
  
  // redirect back to index page
  if ($_REQUEST['redirect']!='false')
    header('Location: index.php?lang='.$language);
?>
