<?php
$redirto = 'https://dennyhalim.blogspot.com/?utm_source=denny.wordpress.com';
header("Location: $redirto");
?>
<html><head>
<base target="_top">
<!-- dennyhalim.com html redirects -->
<!-- use meta refresh -->
<meta http-equiv="refresh" content="1;url=<?php echo $redirto; ?>">
<!-- use javascript -->
<script type="text/javascript"> top.location="<?php echo $redirto; ?>"; </script>
</head>
<body id="denny.wordpress.com">
<!-- use iframe -->
<iframe src="<?php echo $redirto; ?>" style="width:100%; height:100%; border:0" scrolling="yes" ></iframe>
</body>
</html>
