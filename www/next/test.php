<?php
  // various temporary test code
  header('Content-Type: text/plain; charset=utf-8');

  require_once "../sentence.php";
  require_once "tokenizer.php";
  require_once "stemmer.php";
  require_once "inverted.php";

  /*
  // compare old and new tokenizer and stemmer
  $data = explode("\n",file_get_contents('data/en/sam.dat').file_get_contents('data/en/improve.dat'));
  $stemmer_parameter = 15;

  for ($i=0; $i<count($data); $i++) {
    // new version
    $words = tokenizerSimple($data[$i]);
    for ($w=0; $w<count($words); $w++)
      $words[$w] = stemmerSimple($words[$w],$stemmer_parameter);
    $new = implode(' ',$words);

    // old version
    $old = ghostSentenceNormalize($data[$i]);

    if ($old != $new)
      echo ($i+1)."\nO=$old\nN=$new\n\n";
    //if ($i >= 100)
     // break;
  }
  */

  // testing slovak stemmer
  /*
  //$data = "Kŕdeľ ďatľov učí koňa žrať kôru. Žľuťoučký kůň úpěl své ódy.";
  $data = file_get_contents('data/sk/sam.dat');
  $words = array_unique(tokenizerSimple($data));
  $words = array_map('stemmerSlovak',$words);
  sort($words);
  print_r($words);

  echo stemmerSlovakRemoveAccents($data);
  */

  // manually counting score in sample sentence

  // load index and data
  $index = invertedLoad('data/en/sam.idx',$sp);
  $data = explode("\n",file_get_contents('data/en/sam.dat'));

  // get some sample sentence
  $words = array('free','talk','is','good');
  echo "question: ".implode(',',$words)."\n\n";

  // print in what documents these words occurs
  foreach ($words as $word) {
    $docs = array();
    if (array_key_exists($word,$index))
      $docs = $index[$word];
    echo "word '$word' is in ".count($docs)." documents: ".implode(',',$docs)."\n";
  }
  echo "\n";

  // calculate term frequencies (tf) for few words
  $tf_free = count($index['free']);
  $tf_talk = count($index['talk']);
  $tf_is = count($index['is']);
  $tf_good = count($index['good']);

  // calculate score for document 222
  echo "score for document 128 (".$data[128]." --> ".$data[128+1]."):\n";
  echo "  'free' 0 times, $tf_free times in all documents\n";
  echo "  'talk' 0 times, $tf_talk times in all documents\n";
  echo "  'is'   1 times, $tf_is times in all documents\n";
  echo "  'good' 1 times, $tf_good times in all documents\n";
  echo "  Score(doc128) = 0/$tf_free + 0/$tf_talk + 1/$tf_is + 1/$tf_good = ".(0/$tf_free + 0/$tf_talk + 1/$tf_is + 1/$tf_good)."\n";
  echo "  - as you can see this document match for words 'is' and 'good'\n";
  echo "  - these words are very common, thus score is low: 0.06\n";
  echo "\n";

  // calculate score for document 1866
  echo "score for document 1866 (".$data[1866]." --> ".$data[1866+1]."):\n";
  echo "  'free' 1 times, $tf_free times in all documents\n";
  echo "  'talk' 0 times, $tf_talk times in all documents\n";
  echo "  'is'   0 times, $tf_is times in all documents\n";
  echo "  'good' 0 times, $tf_good times in all documents\n";
  echo "  Score(doc128) = 1/$tf_free + 0/$tf_talk + 0/$tf_is + 0/$tf_good = ".(1/$tf_free + 0/$tf_talk + 0/$tf_is + 0/$tf_good)."\n";
  echo "  - this document match only one word: 'free'\n";
  echo "  - this word is quite rare in our data, occured only twice\n";
  echo "  - thus it must be important word, score is higher: 0.5\n";
  echo "\n";

  // calculate score for document 1868
  echo "score for document 1868 (".$data[1868]." --> ".$data[1868+1]."):\n";
  echo "  'free' 1 times, $tf_free times in all documents\n";
  echo "  'talk' 0 times, $tf_talk times in all documents\n";
  echo "  'is'   0 times, $tf_is times in all documents\n";
  echo "  'good' 0 times, $tf_good times in all documents\n";
  echo "  Score(doc128) = 1/$tf_free + 0/$tf_talk + 0/$tf_is + 0/$tf_good = ".(1/$tf_free + 0/$tf_talk + 0/$tf_is + 0/$tf_good)."\n";
  echo "  - this document has exactly same score as previous case\n";
  echo "\n";

  echo "- We would calculate score for all available documents.\n";
  echo "- The highest scored document 'won' and we display answer.\n";
  echo "- In this case documents #1866 and 1866 has highest score of 0.5\n";
  echo "  so we show answers to one of those two winning documents.\n";
  echo "\n";

  echo "How to choose winning document if they have same score?\n\n";
  echo "Look at candidate questions:\n";
  echo "  document 1866, score 0.5: Q: ".$data[1866]."\n";
  echo "                            A: ".$data[1866+1]."\n";
  echo "  document 1868, score 0.5: Q: ".$data[1868]."\n";
  echo "                            A: ".$data[1868+1]."\n";
  echo "\n";
  echo "Document 1866 contains 1 word that is not in question. It's 'questionmark'.\n";
  echo "Document 1868 contains 2 words that are not in question: 'mine' and 'was'\n";
  echo "\n";
  echo "Frequencies for these words are:\n";
  echo "\n";
  $tf_q = count($index['?']);
  $tf_mine = count($index['mine']);
  $tf_was = count($index['was']);
  echo "  ?    = $tf_q\n";
  echo "  mine = $tf_mine\n";
  echo "  was  = $tf_was\n";
  echo "\n";
  echo "What does it mean? Question mark is in 173 documents, so it must be very common word.\n";
  echo "Word 'mine' is only in one document so it must be important word, not just some filler words.\n";
  echo "Word 'was' is in 11 documents. Assuming thera are around 1000 documents, it is quite rare\n";
  echo "and thus meaningfull words. But none of these meaningfull words are in original question.\n";
  echo "So we should lower score somehow. Here is 'punishment score'.\n";
  echo "\n";
  $ps1 = (1/173);
  $ps2 = (1/2+1/11);
  echo "punish_score(?) = 1/173 = $ps1\n";
  echo "punish_score(mine,was) = 1/2+1/11 = $ps2\n";
  echo "\n";
  echo "Now you have to decide how much does it matter if candidate documents contains\n";
  echo "some other words that are not in question. You set a coeficient 'k' for that.\n";
  echo "If k=0 it doesnt matter at all. If k=0.5, it somehow matter. If k=1.0 it matter a lot.\n";
  echo "Then you lower score:\n";
  echo "\n";
  function fin($k) {
    global $ps1, $ps2;
    echo "k=$k:\n";
    echo "  final_score(free ?)        = 0.5 - k * $ps1 = ".(0.5 - $k * $ps1)."\n";
    echo "  final_score(mine was free) = 0.5 - k * $ps2 = ".(0.5 - $k * $ps2)."\n";
    echo "\n";
  }
  fin(0);
  fin(0.5);
  fin(1);
  echo "- you can see that question mark does not affect score very much because it is very common\n";
  echo "- words 'mine' and 'was' affects score because they are rare and thus important, we cannot ignore them\n";
  echo "- if we use k=0.5, best answer would be \"It's never free\" with score 0.49\n";

  // calculate score for document 1988
//  $tf = count($index['alpha']);
//  echo "score for document 1988 is 1/$tf = ".(1/$tf)."\n";

?>
