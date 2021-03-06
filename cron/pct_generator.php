<?php
define( 'DC', true );
/*
 * Каждые 2 недели собираем инфу о голосах за % и создаем тр-ию, которая
 * попадет в DC сеть только, если мы окажемся генератором блока
 * */

define( 'ABSPATH', dirname(dirname(__FILE__)) . '/' );

set_time_limit(0);

require_once( ABSPATH . 'includes/errors.php' );
require_once( ABSPATH . 'db_config.php' );
require_once( ABSPATH . 'includes/class-mysql.php' );
require_once( ABSPATH . 'includes/fns-main.php' );
require_once( ABSPATH . 'includes/class-parsedata.php' );

require_once( ABSPATH . 'phpseclib/Math/BigInteger.php');
require_once( ABSPATH . 'phpseclib/Crypt/Random.php');
require_once( ABSPATH . 'phpseclib/Crypt/Hash.php');
require_once( ABSPATH . 'phpseclib/Crypt/RSA.php');
require_once( ABSPATH . 'phpseclib/Crypt/AES.php');

$db = new MySQLidb(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME, DB_PORT);

upd_deamon_time($db);

main_lock();
$block_id = get_block_id($db);
if (!$block_id) {
	main_unlock();
	exit;
}

// а майнер ли я ?
$my_miner_id = get_my_miner_id($db);
if (!$my_miner_id) {
	main_unlock();
	exit;
}

$variables = ParseData::get_all_variables($db);
$time = time();
// проверим, прошло ли 2 недели с момента последнего обновления pct
$pct_time = $db->query( __FILE__, __LINE__,  __FUNCTION__,  __CLASS__, __METHOD__, "
		SELECT max(`time`)
		FROM `".DB_PREFIX."pct`
		", 'fetch_one' );
if ( $time - $pct_time > $variables['new_pct_period'] ) {

	$my_user_id = get_my_user_id($db);

	// берем все голоса miner_pct
	$res = $db->query( __FILE__, __LINE__,  __FUNCTION__,  __CLASS__, __METHOD__, "
			SELECT `currency_id`,
						 `pct`,
						  count(`user_id`) as `votes`
			FROM `".DB_PREFIX."votes_miner_pct`
			GROUP BY  `currency_id`, `pct`
			");
	while ( $row = $db->fetchArray( $res ) )
		$pct_votes[$row['currency_id']]['miner_pct'][$row['pct']] = $row['votes'];

	// берем все голоса user_pct
	$res = $db->query( __FILE__, __LINE__,  __FUNCTION__,  __CLASS__, __METHOD__, "
			SELECT `currency_id`,
						 `pct`,
						  count(`user_id`) as `votes`
			FROM `".DB_PREFIX."votes_user_pct`
			GROUP BY  `currency_id`, `pct`
			");
	while ( $row = $db->fetchArray( $res ) )
		$pct_votes[$row['currency_id']]['user_pct'][$row['pct']] = $row['votes'];

	if (!isset($pct_votes)) {
		debug_print( '!isset($pct_votes)', __FILE__, __LINE__,  __FUNCTION__,  __CLASS__, __METHOD__);
		main_unlock();
		exit;
	}

	debug_print( $pct_votes, __FILE__, __LINE__,  __FUNCTION__,  __CLASS__, __METHOD__);

	foreach ( $pct_votes as $currency_id => $data ) {

		$pct_arr = ParseData::makePctArray($data['miner_pct']);
		$key = get_max_vote($pct_arr, 0, 1000, 100);
		$new_pct[$currency_id]['miner_pct'] = ParseData::getPctValue($key);

		$pct_arr = ParseData::makePctArray($data['user_pct']);
		$key = get_max_vote($pct_arr, 0, 1000, 100);
		$new_pct[$currency_id]['user_pct'] = ParseData::getPctValue($key);
	}

	debug_print( $new_pct, __FILE__, __LINE__,  __FUNCTION__,  __CLASS__, __METHOD__);

	$node_private_key = $db->query( __FILE__, __LINE__,  __FUNCTION__,  __CLASS__, __METHOD__, "
					SELECT `private_key`
					FROM `".DB_PREFIX."my_node_keys`
					WHERE `block_id` = (SELECT max(`block_id`) FROM `".DB_PREFIX."my_node_keys` )
					", 'fetch_one');

	$json_data = json_encode($new_pct);
	// подписываем нашим нод-ключем данные транзакции
	$data_for_sign = ParseData::findType('new_pct').",{$time},{$my_user_id},{$json_data}";
	$rsa = new Crypt_RSA();
	$rsa->loadKey($node_private_key);
	$rsa->setSignatureMode(CRYPT_RSA_SIGNATURE_PKCS1);
	$signature = $rsa->sign($data_for_sign);
	debug_print( '$data_for_sign='.$data_for_sign."\n", __FILE__, __LINE__,  __FUNCTION__,  __CLASS__, __METHOD__);

	// создаем тр-ию. пишем $block_id, на момент которого были актуальны голоса в табле 'pct'
	$data = dec_binary (ParseData::findType('new_pct'), 1) .
		dec_binary ($time, 4) .
		ParseData::encode_length_plus_data($my_user_id) .
		ParseData::encode_length_plus_data($json_data) .
		ParseData::encode_length_plus_data($signature) ;
	$hash = ParseData::dsha256($data);

	insert_tx($data, $db);

	// и не закрывая main_lock переводим нашу тр-ию в verified=1, откатив все несовместимые тр-ии
	// таким образом у нас будут в блоке только актуальные голоса.
	// а если придет другой блок и станет verified=0, то эта тр-ия просто удалится.
	$new_tx_data['data'] = $data;
	$new_tx_data['hash'] = hextobin(md5($data));
	tx_parser ($new_tx_data, true);

}

main_unlock();


?>