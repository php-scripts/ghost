<html>
	<head>
		<title>Ghost</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="icon" href="icon.png" />
    <link rel="alternate" type="application/rss+xml" href="rss-news.php" title="Ghost news" />
    <link rel="alternate" type="application/rss+xml" href="rss-chat.php" title="Ghost recent chats" />
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
  
    <form action="index.php" method="get">
      <input name="question" autofocus />
      <input type="submit" />
    </form>  
    
    <?php
    $question = htmlspecialchars($_REQUEST['question']);
    $answer = "neviem";
    echo "<div class=\"answer\">$answer</div>";    
    echo "<div class=\"question\">$question<div>";    
    ?>  
	
	</body>
</html>
