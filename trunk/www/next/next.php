<?php
  // simplified api for ghost-next (use this if you want to embed ghost-next somewhere)
  // searching using NLP document retrieval with some basic scoring (sum(1/tf))

  require_once "common.php";
  require_once "tokenizer.php";
  require_once "stemmer.php";
  require_once "inverted.php";

  function ghostNextStems($AQuestion,$ATokenizer,$AStemmer,$AStemmerParameter) {
    // tokenize sentence and stem words, return stems as array
    $words = $ATokenizer($AQuestion);
    //$words = array_map($AStemmer,$words,array_fill(0,count($words),$AStemmerParameter));
    for ($i=0; $i<count($words); $i++)
      $words[$i] = $AStemmer($words[$i],$AStemmerParameter);
    return $words;
  }

  function ghostNextCandidates($AIndex,$AQuestion,$AMaxCandidates,$ATokenizer,$AStemmer,$AStemmerParameter) {
    //($AIndex,$AQuestionsAnswers,$AQuestion,$AMinScore = 0.50,$AMaxAnswers=20,$ATokenizer='tokenizerSimple',$AStemmer='stemmerSimple',$AStemmerParameter=3,&$AAbsoluteScore,&$ADocuments,&$AScores) {
    // find candidate answers using inverted index, return those with best score

    // split question to words
    $stems = ghostNextStems($AQuestion,$ATokenizer,$AStemmer,$AStemmerParameter);

    // find all documents which contains at least one word in question
    $docs = array();
    foreach ($stems as $stem) {
      // unseen words do not contribute to score
      if (!array_key_exists($stem,$AIndex))
        continue;

      // how often stem occurs in all documents? (more=common words (the,or,and), less=rare words (apple,name,brazil))
      $stem_freq = count($AIndex[$stem]);

      // update each document score
      foreach($AIndex[$stem] as $document_index) {
        // initialize document score for the first time
        if (!array_key_exists($document_index,$docs))
          $docs[$document_index] = 0;
        // add score 1/tf/number_of_words_in_sentence (so that score would not exceed 1.0)
        $docs[$document_index] += 1/$stem_freq/count($stems);
      }
    }

    // sort document (highest score first)
    arsort($docs);
    $candidates = array_slice($docs,0,$AMaxCandidates,true);
    return $candidates;
  }

  function ghostNextSentenceDifference($AIndex,$AQuestion,$ACandidate,$ATokenizer,$AStemmer,$AStemmerParameter) {
    // return 0 if all words in candidate are present in question and are rare, uniqe
    // return higher number if some words are missing (in either question or candidate)
    // return 1 if every single word is rare and is different
    /*
    'how are you' vs. 'how are you the'   - Returns 0.004 because 'the' is common word (sentences are almost the same)
    'how are you' vs. 'how are you alpha' - Returns 0.142 because 'alpha' is rare word
    'and the of'  vs  'how are you'       - Returns 0.050 because even though neither words match! All words are very
                                            common and thus sentences are quite simmilar, first contain few common
                                            words and second sentence also contain only common words.
                                            This will not be problem because document retrieval will not offer
                                            candidates with zero match.
    'the alpha'   vs. 'beta'              - Returns 0.677 because common word "the" lowered score somewhat
    'alpha'       vs. 'beta'              - Returns 1.000 because they are rare and different

    This function is quite slow, you should not run it on entire dataset, just
    on few candidate documents suggested by document retrieval.
    */
    $a = ghostNextStems($AQuestion,$ATokenizer,$AStemmer,$AStemmerParameter);
    $b = ghostNextStems($ACandidate,$ATokenizer,$AStemmer,$AStemmerParameter);
    $score = 0;
    foreach ($a as $w)
      if (!in_array($w,$b))
        if (array_key_exists($w,$AIndex))
          $score += 1/count($AIndex[$w]);
        else
          $score += 1;
    foreach ($b as $w)
      if (!in_array($w,$a))
        if (array_key_exists($w,$AIndex))
          $score += 1/count($AIndex[$w]);
        else
          $score += 1;
    return $score / (count($a) + count($b));
  }

  function ghostNextAsk($AQuestion,$ALanguage,$AMaxAnswers=20,$ABalance=0.5,$ARandom=5,$ADebug=false) {
    // retrieve optimal answer using ranked document retrieval and decide answer by comparing sentence difference
    // $AQuestion - user submited question
    // $ALanguage - 'en' or 'sk'
    // $AMaxAnswers - how many candidates should document retrieval returns
    // $ABalance - how much weight should be put on sentence similarity between question and candidates
    // $ARandom - when final score is calculated, from how many best candidates should we pick 1=choose best, 2=choose random from first 2 candidates,...
    // $ADebug - if true, print candidates and scores in nice table

    // get candidates
    $index = invertedLoad("data/$ALanguage/sam.idx",$stemmer_parameter);
    $candidates = ghostNextCandidates($index,$AQuestion,$AMaxAnswers,'tokenizerSimple','stemmerSimple',$stemmer_parameter);
    if (empty($candidates))
      return NULL;

    // calculate sentence difference for all documents
    $data = explode("\n",file_get_contents("data/$ALanguage/sam.dat").file_get_contents("data/$ALanguage/improve.dat"));
    $differeces = array();
    foreach($candidates as $document_index=>$score)
      $differences[$document_index] = ghostNextSentenceDifference($index,$AQuestion,$data[$document_index],'tokenizerSimple','stemmerSimple',$stemmer_parameter);

    // normalize document and difference score
    $max_candidates = max(max($candidates),1);
    $max_differences = max(max($differences),1);
    $min_candidates = min($candidates);
    $min_differences = min($differences);
    $candidates_norm = array_map(create_function('$a','return $a/'.$max_candidates.';'),$candidates);
    $differences_norm = array_map(create_function('$a','return $a/'.$max_differences.';'),$differences);

    // calculate final score
    $final = array();
    foreach($candidates_norm as $document_index=>$score)
      $final[$document_index] = $score - $ABalance * $differences_norm[$document_index];
    $max_final = max($final);
    //print_r($)

    //$final = array_map(create_function('$c,$d','return $c-0.2*$d;'),$candidates_norm,$differences_norm);
    /*
    echo "candidates: "; print_r($candidates);
    echo "candidates_norm: "; print_r($candidates_norm);
    echo "differences: "; print_r($differences);
    echo "mds=$max_differences_score\n";
    echo "differences_norm: "; print_r($differences_norm);
    */

    // pick 1 up to $random answers with highest final score, one of those answers will be returned
    $pick = $final;
    arsort($pick);
    $pick = array_slice($pick,0,$ARandom,true);

    // print table
    if ($ADebug) {
      echo "<div>Q: <i>$AQuestion</i> Balance:$ABalance</div>";
      echo "<table><tr>\n";
      echo "<th>Original question</th>\n";
      echo "<th>Answer</th>\n";
      echo "<th title=\"Document Retrieval Score\">DRS</th>\n";
      echo "<th title=\"Document Retrieval Score (normalized)\">DRSn</th>\n";
      echo "<th title=\"Sentence Difference\">SD</th>\n";
      echo "<th title=\"Sentence Difference (normalized)\">SDn</th>\n";
      echo "<th title=\"Final score = DRSn - balance * SDn\">Final</th>\n";

      // print table
      foreach($candidates as $document_index=>$score) {
        $good = (array_key_exists($document_index,$pick)) ? 'good' : '';
        $best = ($final[$document_index] == $max_final) ? 'best' : $good;
        echo "<tr>";
        echo "<td>".$data[$document_index]."</td>";
        echo "<td class=\"$good\">".ghostAttributeReplace($data[$document_index+1],$ALanguage)."</td>";
        echo "<td>".round($score,3)."</td>";
        echo "<td>".round($candidates_norm[$document_index],3)."</td>";
        $c = ($differences[$document_index] == $min_differences) ? 'similar' : '';
        echo "<td class=\"$c\">".round($differences[$document_index],3)."</td>";
        echo "<td>".round($differences_norm[$document_index],3)."</td>";
        echo "<td class=\"$best\">".round($final[$document_index],3)."</td>";
        echo "</tr>";
        //echo "$document_index = $score Q:".$data[$document_index]." --> A:".$data[$document_index+1]." sd=".$difference[$document_index]."\n";
      }
      echo "</table>\n";
      echo "Green: First $ARandom answers, Blue: best score, Orange: smallest difference<br/>";

      // print abs. score
      $s = max($candidates);
      echo "Document retrieval score: <b>".round(100*$s,1)."% (".ghostHumanScore($s).")</b></br>";
      $s = max($final);
      echo "Final score: <b>".round(100*$s,1)."% (".ghostHumanScore($s).")</b><br/>";
    }

    // decide answer
    return $data[array_rand($pick)+1];
  }

?>
