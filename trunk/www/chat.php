<?php
  // parse and answer question
  $question = trim(str_replace("\n"," ",htmlspecialchars(strip_tags($_REQUEST['question']))));
  $answer = '';

  $debug = (@$_REQUEST['debug'] == 'true');

  if ($debug)
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
    require_once "eval.php";
    require_once "capital.php";
    require_once "asdf.php";
    require_once "antispam.php";
    require_once "attribute.php";
    require_once "next/common.php";
    require_once "next/next.php";

    // split question to words
    $sentence = ghostSentence($question);
    
    if ($debug) {
      print_r($sentence);
      echo "<br/>\n";
    }

    // detect language    
    $language = ghostLanguage();

    // ask various AI one by one
    
    // detect spam
    if (isSpam($question)) {
      logSpam($question);
      $question = '[SPAM REMOVED]';
      $answer = 'Sorry but your question was detected to be spam!';
    }
    
    // function for detecting which engine first replied
    $who_answered = 'nobody';
    function who($AEngine) {
      global $who_answered, $answer;
      if (!empty($answer))
        if ($who_answered == 'nobody')
          $who_answered = $AEngine;
    }

    // first is just a logger
    if (empty($answer)) $answer = ghostLurkerAsk('human: '.$question,$language);
    
    // AI improved by users
    if (empty($answer)) $answer = ghostSamAsk($sentence,$language,'improve');     who('improve');

    // real AIs
    if (empty($answer)) $answer = ghostEvalAsk($question);                        who('eval');
    if (empty($answer)) $answer = ghostDrknowAsk($sentence,$language);            who('drknow');
    if (empty($answer)) $answer = ghostCapitalAsk($sentence,$language);           who('capital');
    if (empty($answer)) $answer = ghostSamAsk($sentence,$language,'sam');         who('sam');
    if (empty($answer)) $answer = ghostVariationAsk($sentence,$language);         who('variation');
    if (empty($answer)) $answer = ghostAsdfAsk($question,$language);              who('asdf');
    if (empty($answer)) $answer = ghostNextAsk($question,$language,20,0.5,3);     who('next');
    if (empty($answer)) $answer = ghostTopicAsk($sentence,$language);             who('topic');

    // dumb is last resort
    if (empty($answer)) $answer = ghostDumbAsk($sentence,$language);              who('dumb');

    // parse answer for attributes
    $answer = ghostAttributeReplace($answer,$language);

    // lets lurker also log answer (so we see in lurker's log what was question and answer)
    ghostLurkerAsk("GHOST: $answer\n",$language);

    if ($debug)
      echo "Q: $question<br/>\nA: $answer<br/>\n";

    // store answer to the begining of chat file
    $chat = "";
    $chat .= "<div class=\"question\">$question</div>\n";
    $chat .= "<div class=\"answer\">$answer<a class=\"improve\" title=\"Click to improve answer\nEngine: $who_answered\" href=\"improve.php?lang=$language&question=$question&answer=$answer\">&#9997;</a></div>\n";
    $chat .= file_get_contents('chat.txt');
    // keep only first 20 lines
    $lines = explode("\n",$chat);
    $lines = array_splice($lines,0,39);
    $chat = implode("\n",$lines);
    // save chat
    file_put_contents('chat.txt',$chat);
  }
  
  // redirect back to index page
  if (!$debug)
    header('Location: index.php?lang='.$language);
?>
