<script>
	function send_data() {
		$.post( 'ajax/save_queue.php', {
			'type' : '<?php echo $tpl['data']['type']?>',
			'time' : '<?php echo $tpl['data']['time']?>',
			'user_id' : '<?php echo $tpl['data']['user_id']?>',
			'race' : '<?php echo $tpl['data']['race']?>',
			'country' : '<?php echo $tpl['data']['country']?>',
			'latitude' : '<?php echo $tpl['data']['latitude']?>',
			'longitude' : '<?php echo $tpl['data']['longitude']?>',
			'host' : '<?php echo $tpl['data']['host']?>',
			'face_hash' : '<?php echo $tpl['data']['face_hash']?>',
			'profile_hash' : '<?php echo $tpl['data']['profile_hash']?>',
			'face_coords' : '<?php echo $tpl['data']['face_coords']?>',
			'profile_coords' : '<?php echo $tpl['data']['profile_coords']?>',
			'video_type' : '<?php echo $tpl['data']['video_type']?>',
			'video_url_id' : '<?php echo $tpl['data']['video_url_id']?>',
			'node_public_key' : '<?php echo $tpl['data']['node_public_key']?>',
			'signature1': $('#signature1').val(),
			'signature2': $('#signature2').val(),
			'signature3': $('#signature3').val()
		}, function (data) {
			if (!data)
				alert = '<?php echo $lng['sent_to_the_net'] ?>';
			else
				alert = data;
			fc_navigate ('upgrade', {'alert': alert} );
		});
	}
</script>

<!-- container -->
<div class="container">

	<legend><h2><?php echo $lng['upgrade_title']?></h2></legend>
	
    <ul class="nav nav-tabs">
		<li><a href="#" onclick="fc_navigate('upgrade_0')">Step 0</a></li>
		<li><a href="#" onclick="fc_navigate('upgrade_1')">Step 1</a></li>
		<li><a href="#" onclick="fc_navigate('upgrade_2')">Step 2</a></li>
		<li><a href="#" onclick="fc_navigate('upgrade_3')">Step 3</a></li>
	    <li><a href="#" onclick="fc_navigate('upgrade_4')">Step 4</a></li>
	    <li class="active"><a href="#" onclick="fc_navigate('upgrade_5')">Step 5</a></li>
    </ul>
    
	<legend><?php echo $lng['sending_data_to_net']?></legend>

	<p><?php echo @$tpl['upgrade_limit_text']?></p>

	<?php echo $lng['data']?>:<br>
	<textarea id="for-signature" style="width:500px; height:100px"><?php echo "{$tpl['data']['type_id']},{$tpl['data']['time']},{$tpl['data']['user_id']},{$tpl['data']['race']},{$tpl['data']['country']},{$tpl['data']['latitude']},{$tpl['data']['longitude']},{$tpl['data']['host']},{$tpl['data']['face_hash']},{$tpl['data']['profile_hash']},{$tpl['data']['face_coords']},{$tpl['data']['profile_coords']},{$tpl['data']['video_type']},{$tpl['data']['video_url_id']},{$tpl['data']['node_public_key']}"; ?></textarea><br>
	<label><?php echo $lng['sign']?></label>
	<textarea id="signature1" style="width:500px;" rows="4"></textarea>
	<label><?php echo $lng['sign']?> 2</label>
	<textarea id="signature2" style="width:500px;" rows="4"></textarea>
	<label><?php echo $lng['sign']?> 3</label>
	<textarea id="signature3" style="width:500px;" rows="4"></textarea>
	<br>
	
	</textarea><br>

	<button class="btn btn-success" onclick="send_data()">Send</button>
	
	
	<br><br><br><br><br><br><br>
		
       

</div>
<!-- /container -->