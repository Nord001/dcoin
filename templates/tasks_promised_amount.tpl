<!-- container -->
<div class="container">

<script>

function write_for_signature (result) {
	if ($('#comment').val()=='') {
		$('#comment').val('null');
	}
	$("#for-signature").val( '<?php echo "{$tpl['data']['type_id']},{$tpl['data']['time']},{$tpl['data']['user_id']},{$tpl['data']['id']}"?>,'+result+','+$('#comment').val() );
}

$('#btn-bad').bind('click', function () {

	$('#step_1').css('display', 'none');	
	$('#sign').css('display', 'block');	
	$('#result').val( '0' );

	write_for_signature(0);

} );


$('#btn-success').bind('click', function () {
	
	$('#step_1').css('display', 'none');
	$('#sign').css('display', 'block');	
	$('#result').val( '1' );

	write_for_signature(1);

} );

$('#send_to_net').bind('click', function () {

	$.post( 'ajax/save_queue.php', {
			'type' : '<?php echo $tpl['data']['type']?>',
			'time' : '<?php echo $tpl['data']['time']?>',
			'user_id' : '<?php echo $tpl['data']['user_id']?>',
			'promised_amount_id' : $('#promised_amount_id').val(),
			'result' : $('#result').val(),
			'comment' : $('#comment').val(),
			'signature1': $('#signature1').val(),
			'signature2': $('#signature2').val(),
			'signature3': $('#signature3').val()
			}, function () { } );
	fc_navigate ('tasks', {'alert': '<?php echo $lng['sent_to_the_net'] ?>'} );
	
});

function init (lat, lng, map_canvas, drag=true) {
	$("#"+map_canvas).css("display", "block");

	var point = new google.maps.LatLng(lat, lng);
	var mapOptions = {
		center: point,
		zoom: 15,
		mapTypeId: google.maps.MapTypeId.ROADMAP,
		streetViewControl: false
	};
	map = new google.maps.Map(document.getElementById(map_canvas), mapOptions);

	var marker = new google.maps.Marker({
		position: point,
		map: map,
		draggable: drag,
		title: 'You'
	});

	google.maps.event.trigger(map, 'resize');

	google.maps.event.addListener(marker, "dragend", function() {
		document.getElementById('latitude').value = marker.getPosition().lat();
		document.getElementById('longitude').value = marker.getPosition().lng();

	});
	marker.setMap(map);
}

</script>


	<legend><h2><?php echo $lng['tasks_title_promised_amount']?></h2></legend>

	<?php require_once( ABSPATH . 'templates/alert_success.php' );?>
	
	<div id="step_1">

		<?php echo $lng['new_promise_amount']?>
		<table>
			<tr>
				<!-- выдаем слева фото юзера -->
				<td>
					<img width="300"  src="<?php echo "{$tpl['data']['miner_host']}public/profile_{$tpl['data']['user_info']['user_id']}.jpg"?>"><img width="300"  src="<?php echo "{$tpl['data']['miner_host']}public/face_{$tpl['data']['user_info']['user_id']}.jpg"?>">
				</td>
				<!-- а справа - видео юзера -->
				<td>
					<?php
					echo $lng['check_video'].'<br>';
					if ( $tpl['data']['video_url_id']!='null' )
					echo '<iframe width="320" height="240" src="http://www.youtube.com/embed/'.$tpl['data']['video_url_id'].'" frameborder="0" allowfullscreen></iframe>';
					else
					echo '<video class="video-js vjs-default-skin" controls preload="none" width="320" height="240" data-setup="{}"><source src="'.$tpl['data']['host'].'public/promised_amount_'.$tpl['data']['currency_id'].'.mp4" type="video/mp4" /><source src="'.$tpl['data']['host'].'public/promised_amount_'.$tpl['data']['currency_id'].'.webm" type="video/webm" /><source src="'.$tpl['data']['host'].'public/promised_amount_'.$tpl['data']['currency_id'].'.ogv" type="video/ogg" /></video>';
					?>
				</td>
			</tr>
		</table>
		<!-- снизу - юзер на  карте -->
		<?php echo $lng['location_on_map']?>
		<div id="map_canvas" style="width: 640px; height: 480px;"></div>
		<script>
			init (<?php echo $tpl['data']['user_info']['latitude']?>, <?php echo $tpl['data']['user_info']['longitude']?>, 'map_canvas', false);
		</script>

		<?php echo $lng['main_question']?><br>

		Comment: <input type="text" id="comment" value="">(English only)<br>
		<button class="btn btn-inverse" id="btn-bad"><?php echo $lng['no']?></button>
		<button class="btn btn-success" id="btn-success"><?php echo $lng['yes']?></button>
	</div>

	<?php require_once( 'signatures.tpl' );?>
    
    <input type="hidden" id="user_id" value="<?php echo $tpl['data']['user_id']?>">
    <input type="hidden" id="promised_amount_id" value="<?php echo $tpl['data']['id']?>">
    <input type="hidden" id="time" value="<?php echo time()?>">
    <input type="hidden" id="result">
    
</div>
<!-- /container -->