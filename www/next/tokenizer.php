<?php
  // sentence tokenizers (split sentence into words)

  function tokenizerSimple($ASentence) {
    // dead simple tokenizer, split sentence into array of words
    $ASentence = str_replace('?',' ?',$ASentence);
    $ASentence = str_replace('!',' !',$ASentence);
    $words = array();                        // \'\-:\.\!
    preg_match_all('/[a-zA-Z0-9ľščťžýáíéúäňôďŕůěó\?\'\,\;\$\!\-_]+/',$ASentence,$words);
    return $words[0];
  }

?>
