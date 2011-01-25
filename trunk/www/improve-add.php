<?php
  // add improved Q-A to data file
  
  $question = str_replace("\n"," ",htmlspecialchars(strip_tags($_REQUEST['question'])));
  $improved = str_replace("\n"," ",htmlspecialchars(strip_tags($_REQUEST['improved'])));
  
  // language override via cookie or param
  if ( ($_COOKIE['lang'] == 'en')||($_REQUEST['lang'] == 'en')||($_REQUEST['lang_en'] == 'on') ) $language = 'en';
  if ( ($_COOKIE['lang'] == 'sk')||($_REQUEST['lang'] == 'sk')||($_REQUEST['lang_sk'] == 'on') ) $language = 'sk';
  // quess language
  if (empty($language)) {
    $language = 'en';
    if (strpos(' '.$_SERVER['HTTP_ACCEPT_LANGUAGE'],'sk') > 0) 
      $language = 'sk';
  }   

  // append question to log
  $f = fopen("data/$ALanguage/improve.dat", "a") or die("improve: can't open file");
  fwrite($f, $question."\n");
  fwrite($f, $improved."\n");
  fclose($f);  

  // done
  header("Location: index.php?lang=$language");

?>