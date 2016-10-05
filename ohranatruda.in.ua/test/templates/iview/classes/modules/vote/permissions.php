<?php
	$permissions = Array(
		'add_poll' => Array(), 
		'edit_poll' => Array(),
		'del_poll' => Array(), 
		'poll' => Array(
						'get','listPollsOfFeeds','getListFitFeeds', 'getlist', 'getListFeeds','new_feed',
						'upload_photo_cover_feed', 'settings', 'subscribe', 'upload_photo_profile_feed', 'checkUrlLent',
						'xsltCache', 'upload_image_poll', 'getPoll', 'votePoll', 'getNewPollForm',
                        'saveNewPoll', 'optimal_layout', 'getPollMap', 'changeUserPolls', 'getListVotesOfUser',
                        'getListVotesOfCategory', 'viewsCounter','create_poll', 'preview', 'editPoll', 'activate', 'geo',
						'getRandPoll', 'banner', 'attachPollToArticle', 'remove_photo_profile_feed', 'newPollAutocomplete',
						'feed_add_tag', 'feed_del_tag', 'createPollFromTemplate'),
		'post' => Array()
	);
?>