<?php
if(!empty($_POST))
{
	$name = filter_var($_POST["name"], FILTER_SANITIZE_STRING);
	$email = filter_var($_POST["email"], FILTER_SANITIZE_EMAIL);

	if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
		$output = json_encode(array('type'=>'error', 'text'=>'Please enter a valid email!'));
		die($output);
	}

	list($nameFirst, $nameLast) = explode(' ', $name, 2);

	$output = json_encode(array('type'=>'message', 'text'=>$nameFirst.', thank you for your interest in HitBox!'));

	$filename = "C:\Emails\Emails.txt";
	$current = file_get_contents($filename);
	$current .= $name.", ".$email."\r\n";
	file_put_contents($filename, $current);

	die("$output");
}
?>