<?php
$redirto = 'https://dennyhalim.blogspot.com/?' . $_SERVER['QUERY_STRING'];
header("Location: $redirto");
?>
<html><head>
<base target="_top">
<!-- denny.wordpress.com html redirects -->
<!-- use meta refresh -->
<meta http-equiv="refresh" content="1;url=<?php echo $redirto; ?>">
<!-- use javascript -->
<script type="text/javascript"> top.location="<?php echo $redirto; ?>"; </script>
  <script>window.goatcounter={path:function(p){return location.host+p}}</script>
  <script data-goatcounter="https://mypolaris.goatcounter.com/count"
        async src="//gc.zgo.at/count.js"></script>
</head>
<body id="denny.wordpress.com">
<!-- use iframe -->
<iframe src="<?php echo $redirto; ?>" style="width:100%; height:100%; border:0" scrolling="yes" ></iframe>
</body>
</html>
