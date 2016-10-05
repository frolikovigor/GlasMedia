<?php
	$permissions = Array(
		'login' => Array(),
		'registrate' => Array('checkEmail', 'authorization', 'registration', 'remindPassword', 'activation',
                              'getInterestsOfUser', 'removeInterestsOfUser', 'addInterestsOfUser',
                              'saveSettings', 'getCurrentUserId', 'getUserNotification','identification'),
		'settings' => Array('getProfile', 'upload_image_profile', 'removePhoto', 'checkPassword'),
		'users_list' => Array(),
		'profile' => Array()
	);
?>