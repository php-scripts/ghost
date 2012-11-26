<?php
  // common code used by ghost-next

  function ghostParamStr($AName,$ADefault='',$AMaxLength=255) {
    // return input parameter, $ADefault if nothing was sent
    if (isset($_REQUEST[$AName]))
      return substr(trim(str_replace("\n"," ",htmlspecialchars(strip_tags($_REQUEST[$AName])))),0,$AMaxLength);
    else
      return $ADefault;
  }

  function ghostParamInt($AName,$ADefault=1) {
    // return input parameter as integer, $ADefault if nothing was sent
    return 1*ghostParamStr($AName,$ADefault);
  }

  function ghostParamFloat($AName,$ADefault=1) {
    // return input parameter as float, $ADefault if nothing was sent
    return 1.0*str_replace(',','.',ghostParamStr($AName,$ADefault));
  }

  function ghostParamBool($AName,$ADefault=false) {
    // return input parameter as boolean, $ADefault if nothing was sent
    $s = strtolower(ghostParamStr($AName,$ADefault));
    return ($s == '1')||($s == 'true')||($s == 'on')||($s == 'checked')||($s == 'enabled');
  }

  function ghostLanguage() {
    // guess which language user want to use

    // language override via cookie or param
    if ( (@$_COOKIE['lang'] == 'en')||(@$_REQUEST['lang'] == 'en')||(@$_REQUEST['lang_en'] == 'on') ) $language = 'en';
    if ( (@$_COOKIE['lang'] == 'sk')||(@$_REQUEST['lang'] == 'sk')||(@$_REQUEST['lang_sk'] == 'on') ) $language = 'sk';

    // quess language
    if (empty($language)) {
      $language = 'en';
      if (strpos(' '.$_SERVER['HTTP_ACCEPT_LANGUAGE'],'sk') > 0)
        $language = 'sk';
    }

    return $language;
  }

  function ghostLog($AMessage,$ALogFile = 'next.log') {
    // append message to end of log file
    $f = fopen($ALogFile,"a") or die("Error: cannot open log file '$ALogFile' for append");
    fwrite($f,$AMessage);
    fclose($f);
  }

  function ghostHumanScore($AScore) {
    // convert score from range 0-1 to something meaningful
    // NOTE: I just guessed those thresholds, perhaps we should ask 1000 real world questions and watch what score it returns and then decide thresholds
    $a = 'perfect';
    if ($AScore < 0.8) $a = 'very good';
    if ($AScore < 0.6) $a = 'good';
    if ($AScore < 0.3) $a = 'poor';
    if ($AScore < 0.1) $a = 'bad';
    if ($AScore < 0.01) $a = 'trash';
    if ($AScore < 0) $a = 'negative';
    return $a;
  }

?>
