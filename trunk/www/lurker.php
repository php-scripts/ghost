<?php
  // This AI module never know the answer, but he remember every question and store it to log

  function ghostLurkerAsk($AQuestion,$ALanguage) {
    // append question to log
    $f = fopen("data/$ALanguage/lurker.dat", "a") or die("lurker: can't open file");
    fwrite($f, $AQuestion."\n");
    fclose($f);  
    return '';  
  }

?>
