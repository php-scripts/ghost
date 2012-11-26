<?php
  // calculating, saving and loading inverted index

  /*
  What is "invered index" and how to calculate it

  Inverted index is data structure optimized for searching words in documents.
  Google uses it and ghost-next uses it too. Our data (sam.dat) contains simple
  pairs of questions and answers. User ask question and we are looking for
  candidate questions with best match. I completely ommit answers here because
  we don't need them to calculate index, we are only searching in questions.

  Let's assume these questions:

    1: how are you            --> answer1
    2: who you are            --> answer2
    3: what is your name      --> answer3
    4: where do you live      --> answer4
    5: where are you from     --> answer5

  There are 12 unique words: "are, do, from, how, is, live, name, what, where,
  who, you, your". We create associative array of these words. And we fill it
  with indices of documents where they appears. For example word "are" is in
  document 1,2 and 5. Thus invered index for word "are" will look like this:

    $index['are'] = array(1,2,5)

  You can do it for all words, it will look like this:

    $index['are']   = array(1,2,5)
    $index['do']    = array(4)
    $index['from']  = array(5)
    $index['how']   = array(1)
    $index['is']    = array(3)
    $index['live']  = array(4)
    $index['name']  = array(3)
    $index['what']  = array(3)
    $index['where'] = array(4,5)
    $index['who']   = array(2)
    $index['you']   = array(1,2,4,5)
    $index['your']  = array(3)

  And that is inveted index. Not only you know that word "are" appears in
  documents 1,2 and 5, but you also know how often this word appear (3 times).
  Simply by using count($index['are']). It is important to know how often word
  appears in all documents because this lets you ignore common words and put
  more weight on rare words that has some actual meaning.

  It take quite long to calculate inverted index on big data sets. So it is
  better to save it somewhere and use this precalculated index instead of
  calculating it at every user request.
  */

  function invertedCreate($AQuestionsAnswers,$ATokenizer,$AStemmer,$AStemmerAttribute) {
    // calculate inverted index
    // $AQuestionsAnswers - array of questions and answers, e.g. (Q1,A1,Q2,A2,...,Qn,An)
    // $ATokenizer - function that split sentence to words
    // $AStemmer - function that reduce word to it's basic meaning
    // $AStemmerAttribute - attribute for stemmer function

    // first stem all questions (for speed reasons) and initialize empty index
    $index = array();
    $stemq = $AQuestionsAnswers;
    for ($i=0; $i<count($AQuestionsAnswers); $i+=2) {
      //echo "q[$i]: ".$AQuestionsAnswers[$i]." --> ".$AQuestionsAnswers[$i+1]."\n";
      $words = $ATokenizer($AQuestionsAnswers[$i]);
      for ($j=0; $j<count($words); $j++) {
        $words[$j] = $AStemmer($words[$j],$AStemmerAttribute);
        $index[$words[$j]] = NULL;
      }
      $stemq[$i] = $words;
    }
    //echo "stemq="; print_r($stemq); echo "count($stemq)=".count($stemq)."\n";

    // find in which questions words of index appears
    foreach (array_keys($index) as $stem) {
      $found = array();
      // in which questions this stem is?
      //echo "searching in which questions is $stem, count(stemq)=".count($stemq)."\n";
      for ($i=0; $i<count($stemq); $i+=2) {
        //echo "testing if $stem is in #$i: ".implode(',',$stemq[$i])."\n";
        if (in_array($stem,$stemq[$i])) {
          //echo "--> stem $stem is in question $i\n";
          array_push($found,$i);
        }
      }
      //echo "==> stem $stem is in these questions: ".implode(",",$found)."\n";
      $index[$stem] = $found;
    }
    return $index;
  }

  function invertedSave($AFileName,$AIndex,$AStemmerParameter) {
    // save inverted index into file
    $f = fopen($AFileName,"w");
    // first line of file contains stemmer parameter because if you count index
    // with one parameter, and then try to find something with different
    // parameter you won't find anything
    fwrite($f,"$AStemmerParameter\n");
    // write stemX=doc1,doc2,...docN
    foreach ($AIndex as $stem=>$docs)
      fwrite($f,"$stem=".implode(',',$docs)."\n");
    fclose($f);
  }

  function invertedLoad($AFileName,&$AStemmerParameter) {
    // load inverted index from file
    $index = array();
    $lines = explode("\n",file_get_contents($AFileName));
    // load stemmer parameter from first line
    $AStemmerParameter = 1*$lines[0];
    // load lines: stemX=doc1,doc2,...docN
    for ($i=1; $i<count($lines); $i++) {
      $line = $lines[$i];
      $a = strpos($line,'=');
      if ($a > 0) {
        $stem = substr($line,0,$a);
        $docs = explode(',',substr($line,$a+1,strlen($line)));
        $index[$stem] = $docs;
      }
    }
    return $index;
  }

?>
