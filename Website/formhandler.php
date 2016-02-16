<?php 

$psw = htmlspecialchars($_REQUEST["psw"]);
$answerString = "";

//replace with your access token, you can find this in your Particle build page, under SETTINGS
	$my_access_token= "<INSERT_ACCESS_TOKEN>";

//replace with your photon device ID, you can find this in the Particle build page, under DEVICES
	$my_device="<INSERT_DEVICE_ID>";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL,"https://api.spark.io/v1/devices/" . $my_device . "/open");
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);					//stops automatic print of results, allowing curl_exec to return them instead
curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query(array('access_token' => $my_access_token, 'psw' => $psw)));

$response = curl_exec ($ch);

curl_close ($ch);
$json = json_decode($response, true);

$returnValue = $json['return_value'];

if ($returnValue == "1") {
	$answerString = "Door opened";
} else if ($returnValue == "-1"){
	$answerString = "Invalid code";
} else {
	$error = $json['error'];
	
	$answerString = "Request failed. Photon offline";
	//	$answerString = "Request failed. The following error occured: " . $error;

}
echo $answerString;

?>