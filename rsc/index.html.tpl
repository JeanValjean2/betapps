<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
<title>batipad-dev - Beta Release</title>
<style type="text/css">
body {background:#fff;margin:0;padding:0;font-family:arial,helvetica,sans-serif;text-align:center;padding:10px;color:#333;font-size:16px;}
#container {width:450px;margin:70px auto;}
h1 {margin:0;padding:0;font-size:20px;}
h2 {margin:0;padding:0;font-size:14px;}
p {font-size:13px;}
.link {background:#ecf5ff;border-top:1px solid #fff;border:1px solid #dfebf8;margin:2em auto 4em auto;padding:0.6em; width:300px;}
.link a {text-decoration:none;font-size:15px;display:block;color:#069;}
#entitlements		{	margin-top:1em; border:1px solid blue; width:464px; padding:7px; border-radius: 7px; border-color: rgb(161, 178, 205); background-color:rgb(240, 247, 255); font-family:HelveticaNeue-Light; line-height: 1.4em;	}
#provisioneddevices	{	margin-top:2em; border:1px solid blue; width:464px; padding:7px; border-radius: 7px; border-color: rgb(161, 178, 205); background-color:rgb(240, 247, 255); font-family:HelveticaNeue-Light; line-height: 1.4em;	}

</style>
</head>
<body>

<div id="container">

	<h1>%APP_NAME% par %APP_PUBLISHER%</h1>
	<h2>version %BUNDLE_SHORTVERSION% (Build %BUNDLE_VERSION%)</h2>
	<h2>iOS %MINIMUM_OSVERSION%</h2>
	<div style='margin-top:2em;'><img style='margin-bottom:1em;' src='%ICON_FILENAME%' border='0' title='' alt=''/></div>
	<div class="link"><a href="itms-services://?action=download-manifest&url=%MANIFEST_PLIST_URL%">Installer !</a></div>

	<div id='entitlements'><h2>Droits</h2>%ENTITLEMENTS%</div>
	<div id='provisioneddevices'><h2>UUIDs</h2>%PROVISIONEDDEVICES%</div>

	<p><strong>Le lien ne fonctionne pas ?</strong><br />
		Visualisez cette page depuis votre appareil iPad et pas depuis un ordinateur.</p>

</div>
<!--
<p><strong>On a version of iOS before 4.0?</strong><br />
Reload this page in your computer browser and download a zipped archive and provisioning profile here:
</p>

<div class="link"><a href="beta_archive.zip">batipad-dev<br />Archive w/ Provisioning Profile</a></div>
-->

</body>
</html>
