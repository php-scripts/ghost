<?php
  // recalculate index and save it to file
  // example: reindex.php?password=secret&language=en&hints=true&stemmer_parameter=10
  header('Content-Type: text/plain; charset=utf-8');
  require_once "common.php";
  require_once "tokenizer.php";
  require_once "stemmer.php";
  require_once "inverted.php";

  // prevent unauthorized persons calculate index with wrong attributes
  if (ghostParamStr('password') != 'secret')
    die('error: reindexing needs password');

  // get user inputs
  $hints = ghostParamBool('hints');
  $language = ghostLanguage();
  $stemmer_parameter = ghostParamInt('stemmer_parameter',10);
  echo "hints=$hints\n";
  echo "language=$language\n";
  echo "stemmer_parameter=$stemmer_parameter\n";
  ghostLog("reindex hints=$hints, language=$language, stemmer_parameter=$stemmer_parameter\n",'reindex.log');

  // load data
  $data = explode("\n",file_get_contents("data/$language/sam.dat").file_get_contents("data/$language/improve.dat"));
  echo "data_count=".count($data)."\n";
  $index_file = "data/$language/sam.idx";
  echo "index_file=$index_file\n";

  // check if questions are canonical ("tokenizer+stemmer+implode" must reuturn the same question)
  for ($i=0; $i<count($data); $i+=2) {
    $row = $i+1;
    $words = tokenizerSimple($data[$i]);
    for ($w=0; $w<count($words); $w++)
      $words[$w] = stemmerSimple($words[$w],$stemmer_parameter);
    // non-canonical question means that when you stem question and then create
    // sentence by joining stems, you don't get original question. There are
    // two possible cases:
    //   1. tokenizer fault - for example question is "hello. world" will be
    //      tokenized into "hello world". That's because tokenizer currently
    //      ignore dots.
    //   2. stemmer fault - for example 'hello international', when stemmer
    //      limits words lenth to 10, it will became 'hello internatio'.
    // You can ignore both hints. The only reason why would you want to fix
    // these hints if you don't want to use stemmer in ghostNextBestAnswer for
    // speed reason but it usually process only few final candidate questions so
    // it is not real problem.
    if ($hints)
      if ($data[$i] != implode(' ',$words) )
        echo "hint($row): non-canonical question '".$data[$i]."'\n                         expected '".implode(' ',$words)."'\n";
    // extra checks for common errors, you should fix these!
    for ($w=0; $w<count($words); $w++) {
      if (strstr($words[$w],'?')&&($words[$w]!='?'))
        echo "warning($row): non-standalone question mark in question '".$data[$i]."'\n";
      if (strstr($words[$w],'!')&&($words[$w]!='!'))
        echo "warning($row): non-standalone exclamation mark in question '".$data[$i]."'\n";
      if (strstr($words[$w],'.')&&($words[$w]!='.'))
        echo "warning($row): non-standalone dot in question '".$data[$i]."'\n";
      if (strstr($words[$w],',')&&($words[$w]!=','))
        echo "warning($row): non-standalone comma in question '".$data[$i]."'\n";
    }
  }

  // create index
  $index = invertedCreate($data,'tokenizerSimple','stemmerSimple',$stemmer_parameter);

  // save index
  invertedSave($index_file,$index,$stemmer_parameter);
  echo "done, index '$index_file' count=".count($index)." size=".filesize($index_file)."\n";
  ghostLog("reindex_done $index_file, count=".count($index)." size=".filesize($index_file)."\n",'reindex.log');

?>
