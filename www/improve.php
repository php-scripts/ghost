<html>
	<head>
		<title>Ghost - Improve</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="icon" href="icon.png" />
    <link rel="alternate" type="application/rss+xml" href="rss.php" title="Ghost recent chats" />
    <link rel="alternate" type="application/rss+xml" href="rss-pending.php" title="Pending corrections" />
    <link rel="stylesheet" type="text/css" href="index.css" />
	</head>
	<script src="index.js"></script>
  
	<body>
  
    <div id="logo">
      <a href="http://code.google.com/p/ghost/">
        <h1>ghost</h1>
        <h2>a tiny chat bot</h2>
      </a>
    </div>
  
    <form action="improve-add.php" method="get">
      <?php
        require_once "sentence.php";
        $lang = ghostLanguage();
        if ($lang == 'en') {
          $en1 = ' checked';
          $sk1 = ' ';
        } else {
          $en1 = ' ';
          $sk1 = ' checked';
        };
        echo '<input type="radio" id="lang_en" name="lang" value="en" '.$en1.'/><label for="lang_en">english</label>';
        echo '<input type="radio" id="lang_sk" name="lang" value="sk" '.$sk1.'/><label for="lang_sk">slovensky</label>';
        $question = str_replace("\n"," ",htmlspecialchars(strip_tags($_REQUEST['question'])));
        $answer = str_replace("\n"," ",htmlspecialchars(strip_tags($_REQUEST['answer'])));
      ?>

      <div class="improve">Question</div>
      <input type="text" name="question" value="<?php echo$question?>" />

      <div class="improve">Answer</div>
      <input type="text" name="answer" value="<?php echo$answer?>" />

      <div class="improve">Improved answer</div>
      <input type="text" name="improved" autofocus />
      
      <input class="improve" type="submit" />
    </form>  
    
	</body>
</html>
