<?php

session_start();

define( 'DC', TRUE);

define( 'ABSPATH', dirname(__FILE__) . '/' );

set_time_limit(0);

require_once( ABSPATH . 'includes/errors.php' );
require_once( ABSPATH . 'includes/fns-main.php' );

//require_once( ABSPATH . 'db_config.php' );
require_once( ABSPATH . 'includes/class-mysql.php' );

if (!isset($lang)) {
	if (@$_SESSION['lang'])
		$lang = $_SESSION['lang'];
	else if (@$_COOKIE['lang'])
		$lang = $_COOKIE['lang'];
}
if (!@$lang)
	$lang = 'en';

if (!preg_match('/^[a-z]{2}$/iD', $lang))
	die('lang error');
require_once( ABSPATH . 'lang/'.$lang.'.php' );

//$db = new MySQLidb(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME, DB_PORT);

//$tpl['title'] = 'Авторизация';
//print_R($_SESSION);
//if ( $_SESSION['DC_ADMIN'] != 1 ) {
//	$tpl['main_include'] = 'login.tpl';
//}else{
require_once( ABSPATH . 'templates/index.tpl' );
//}



?>