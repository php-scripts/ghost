<?php
  // answer geographical question about capital cities (e.g. "What is captal city of Uganda?")
  /*
  Data format:
  
  keyword1
  keyword2
  keyword3
  answer
  <empty line> 
  keyword1
  keyword2
  keyword3
  answer
  <empty line>
  ...
  */ 
  require_once "sentence.php";

  function ghostCapitalAsk($ASentence,$ALanguage) {
    // find capital city if asked for one
    $country = "";
    
    // find questioned country name
    $q4 = ghostSentencePartString($ASentence,0,3);
    if (
          ($q4 == "ake je hlavne mesto")
        ||($q4 == "co je hlavne mesto")
        ||($q4 == "povedz mi hlavne mesto")
       ) $country = ghostSentencePartString($ASentence,4,99);                   

    $q3 = ghostSentencePartString($ASentence,0,2);
    if (
          ($q3 == "vymenuj hlavne mesto")
        ||($q3 == "poznas hlavne mesto")
       ) $country = ghostSentencePartString($ASentence,3,99);                   

    $q2 = ghostSentencePartString($ASentence,0,1);
    if (
          ($q2 == "hlavne mesto")
       ) $country = ghostSentencePartString($ASentence,2,99);                   
  
    // reply random sentence from data file
    $file = file_get_contents("../data/$ALanguage/capital.dat");
    $lines = explode("\n",$file);

    if (!empty($country)) {
      //echo "country=..$country..<br/>";
      for ($i=0; $i<count($lines); $i++)
        // echo $lines[$i]." ?= ".$country."<br/>";
        if ($lines[$i] == $country) {
          while ($i<count($lines)) {
            if (empty($lines[$i]))
              return $lines[$i-1];
            $i++;
          }
        }
    }
    
    // TODO: if unable to detect question, we can ignore all words and just look for name of coutnries, e.g. for "????? ??? ????? ?? france ??? ???? ???", valid answer is "Capital of France is Paris"
    // TODO: backward searach "for question containing 'paris', answer could be: I like France"  
    
    // give up
    return '';        
  }
  
  $sentence = ghostSentence("Aké je hlavné mesto barmy?");  echo ghostCapitalAsk($sentence,"sk")."<br/>";
  $sentence = ghostSentence("Poznas hlavne mesto barmy?");    echo ghostCapitalAsk($sentence,"sk")."<br/>";
  $sentence = ghostSentence("hlavne mesto barmy?");           echo ghostCapitalAsk($sentence,"sk")."<br/>";
?>