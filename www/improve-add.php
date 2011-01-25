<?php
  // add improved Q-A to data file
  
  $question = str_replace("\n"," ",htmlspecialchars(strip_tags($_REQUEST['question'])));
  $improved = str_replace("\n"," ",htmlspecialchars(strip_tags($_REQUEST['improved'])));
  
  echo "question=$question improved=$improved";

?>