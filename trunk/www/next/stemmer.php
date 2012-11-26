<?php
  // word stemmers (derivate word into it's basic core meaning)
  mb_internal_encoding("UTF-8");

  function stemmerSimple($AWord,$AMaxWordLength = 10) {
    // very simple stemmer optimized for english and slovak language

    // limit word length (it is unlikely that our dataset will contain words
    // longer than 10 characters which only differ after those 10 characters,
    // and even then, those words are probably related so we can assume they
    // are the same). For example "international" and "internationalization"
    // will became the same word "internatio".
    $AWord = mb_substr($AWord,0,$AMaxWordLength);

    // remove accents (e.g. väčší->vacsi, currently slovak and czech)
    preg_match_all('/.{1}|[^\x00]{1}$/us', 'ľščťžýáíůúäôóřŕďěéĺňĽŠČŤŽÝÁÍŮÚÄÔÓŘŔĎĚÉĹŇ', $a);
    preg_match_all('/.{1}|[^\x00]{1}$/us', 'lsctzyaiuuaoorrdeelnLSCTZYAIUUAOORRDEELN', $b);
    $AWord = str_replace($a[0], $b[0], $AWord);

    // lowercase
    return mb_strtolower($AWord);
  }

?>
