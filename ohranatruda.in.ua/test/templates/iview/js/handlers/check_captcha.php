<?php
session_start();

include_once '../../../../standalone.php';

if (isset($_REQUEST['captcha'])) {
    $_SESSION['user_captcha'] = md5((int) getRequest('captcha'));
}

if (!umiCaptcha::checkCaptcha()) {
    echo "false";
    die;
}

echo "true";
die;

?>