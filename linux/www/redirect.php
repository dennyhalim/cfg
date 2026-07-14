<?php
// just change this urlto to your new web, 
// include a trailing slash if it's not ended with extension like php/html
$urlto = 'https://dennyhalim.blogspot.com/';
// just save and it will work, no need to change anything elses
$params = $_GET;
if (!isset($params['utm_source'])) {
    $params['utm_source'] = 'denny.wordpress.com';
}
$redirto = $urlto . '?' . http_build_query($params);
header("Location: $redirto");
header("Refresh: 0;url=$redirto");
header("phpredirect-by: mypolaris.com");
?>
<html><head>
<base target="_top">
<!-- denny.wordpress.com html redirects -->
  <script>window.goatcounter={path:function(p){return location.host+p}}</script>
  <script data-goatcounter="https://mypolaris.goatcounter.com/count"
        async src="//gc.zgo.at/count.js"></script>
<!-- use meta refresh -->
<meta http-equiv="refresh" content="1;url=<?php echo $redirto; ?>">
<!-- use javascript -->
<script type="text/javascript"> top.location="<?php echo $redirto; ?>"; </script>
</head>
<body id="denny.wordpress.com">
<!-- use iframe -->
<iframe src="<?php echo $redirto; ?>" style="width:100%; height:100%; border:0" scrolling="yes" ></iframe>
<a href="https://mypolaris.com">PHP Redirect by Polaris Network Tools</a>
</body>
</html>
