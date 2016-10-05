<?php

require_once CURRENT_WORKING_DIR."/files/scripts-parsing/default.php";

class users_custom extends users {

    public function users_custom(){

    }

    public function isGuest(){

    }

    public function getCurrentUserId(){
        return permissionsCollection::getInstance() -> getUserId();
    }

    //Проверка, есть ли пользователь с таким email при авторизации и регистрации + валидация email
    public function checkEmail($ajax = false, $check = false){
        $email = getRequest('email');
        $new_user = (getRequest('new_user') == "on") ? true : false;
        //Проверка валидности email

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            if ($ajax){
                if ($check) return false;
                else {
                    $buffer = outputBuffer::current();
                    $buffer->charset('utf-8');
                    $buffer->contentType('text/plane');
                    $buffer->clear();
                    $buffer->push("false");
                    $buffer->end();
                }
            } else {
                return array("result"=>"incorrect_email");
            }
        }

        $s = new selector('objects');
        $s->types('object-type')->name('users', 'user');
        $s->where('e-mail')->equals($email);
        //$s->where('id')->notequals(intval($_SESSION['user_id']));
        $result = $s->result();

        if ($ajax){
            if(is_array($result) && count($result)) {
                if ($new_user) {
                    $out = "true";
                } else {
                    $userId = permissionsCollection::getInstance() -> getUserId();
                    if ($userId == $s->first->id){
                        $out = "false";
                    } else
                        $out = "true";
                }
            } else $out = "false";

            if ($check){
                return ($out == "true") ? false: true;
            } else {
                $buffer = outputBuffer::current();
                $buffer->charset('utf-8');
                $buffer->contentType('text/plane');
                $buffer->clear();
                $buffer->push($out);
                $buffer->end();
            }
        }

        if(is_array($result) && count($result)) {
            if ($new_user) return array("result"=>"user_exist");
        } else if (!$new_user) return array("result"=>"user_not_exist");

        return array("result"=>"success", "set_inset"=>((is_array($result) && count($result)) ? "2" : "3"));
    }

    //Проверка пароля пользователя и авторизация
    public function authorization(){
        $email = getRequest('email');
        //Проверка валидности email
        if (!$email) return array("result"=>"empty_email");
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) return array("result"=>"incorrect_email");

        $password = getRequest('password');
        $s = new selector('objects');
        $s->types('object-type')->name('users', 'user');
        $s->where('e-mail')->equals($email);
        //$s->where('id')->notequals(intval($_SESSION['user_id']));
        $result = $s->result();
        $getUser = $s -> first;
        if(is_array($result) && count($result) && is_object($getUser)) {
            $getPassword = $getUser -> password;
            if (md5($password) != $getPassword) return array("result"=>"incorrect_password");
            $_REQUEST['u-login-store'] = "1";
            permissionsCollection::getInstance()->loginAsUser($getUser->getId());
            return array("result"=>"success", "set_inset"=>"location", "location"=>"reload");
        }
        return array("result"=>"incorrect_password");
    }

    //Регистрация пользователя
    public function registration(){
        $currentUser = permissionsCollection::getInstance() -> getUserId();
        if ($currentUser != 337) return array("result"=>"error");   //Если авторизован

        $email = getRequest('email_reg');
        //Проверка валидности email
        if (!$email) return array("result"=>"empty_email");
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) return array("result"=>"incorrect_email");

        $s = new selector('objects');
        $s->types('object-type')->name('users', 'user');
        $s->where('e-mail')->equals($email);
        //$s->where('id')->notequals(intval($_SESSION['user_id']));
        $result = $s->result();
        if(is_array($result) && count($result)) return array("result"=>"user_exist");

        //Проверка пароля
        $password = getRequest('password_reg');
        if (mb_strlen($password) < 6) return array("result"=>"incorrect_new_password");

        //Проверка ввода Имени
        $name = getRequest('name');
        if (!$name) return array("result"=>"incorrect_name");

        //Проверка даты рождения
        $day = (int) getRequest('day');
        $month = (int) getRequest('month');
        $year = (int) getRequest('year');
        $sex = getRequest('sex');
        //if (!$day or !$month or !$year) return array("result"=>"incorrect_birthday");
        if (!$sex) return array("result"=>"error");

        $birthday = false;
        if ($day && $month && $year) $birthday = strtotime($day.".".$month.".".$year);

        $oC = umiObjectsCollection::getInstance();
        $code = uniqid();

        $getNewUserId = $oC -> addObject($email, 53);
        $getUser = $oC -> getObject($getNewUserId);
        $getUser -> setValue("login", $email);
        $getUser -> setValue("e-mail", $email);
        $getUser -> setValue("password", md5($password));
        $getUser -> setValue("groups", 336);
        $getUser -> setValue("is_activated", true);
        $getUser -> setValue("register_date", time());
        $getUser -> setValue("activation_code", $code);
        $getUser -> setValue("fname", $name);
        if ($sex == "male") $getUser -> setValue("sex", true);
        if ($birthday) $getUser -> setValue("birthday", $birthday);
        $getUser->commit();

        //Отправка письма
        $oC = umiObjectsCollection::getInstance();
        $getSettings = $oC -> getObject(3934);
        $message = $getSettings -> getValue('letter_registration');

        sendMail($email, $message, array("%url%"=>"http://".$_SERVER['HTTP_HOST']."/users/activation/".dechex($getNewUserId).md5($code)));

        permissionsCollection::getInstance()->loginAsUser($getUser->getId());
        return array("result"=>"success", "set_inset"=>"location", "location"=>"/cabinet/profile/");
    }

    //Активация
    public function activation($code = ''){
        if (!$code) return;
        $s = new selector('objects');
        $s->types('object-type')->name('users', 'user');
        $result = $s->result();
        foreach($result as $user){
            $userCode = dechex($user->getId()).md5($user->activation_code);
            if ($userCode == $code) {
                $currentEmail = $user -> getValue('new_email') ? $user -> getValue('new_email') : $user -> getValue('e-mail');

                $user -> setValue("e-mail", $currentEmail);
                $user -> setValue("login", $currentEmail);
                $user -> setValue("activated", true);
                //$user -> setValue("recommend_change_password", false);
                $user -> commit();
                permissionsCollection::getInstance()->loginAsUser($user->getId());
                $this->redirect($this->pre_lang . "/cabinet/profile/");
            }
        }
        return;
    }

    //Восстановление пароля
    public function remindPassword(){
        $email = getRequest('email');
        if (!$email) return array("result"=>"empty_email");
        $s = new selector('objects');
        $s->types('object-type')->name('users', 'user');
        $s->where('e-mail')->equals($email);
        $s->where('activated')->equals(true);
        //$s->where('id')->notequals(intval($_SESSION['user_id']));
        $result = $s->result();
        $getUser = $s -> first;
        if(is_array($result) && count($result) && is_object($getUser)) {
            $code = uniqid();
            $getUser -> setValue("activation_code", $code);
            $getUser -> setValue("recommend_change_password", true);
            $getUser -> commit();

            //Отправка письма
            $oC = umiObjectsCollection::getInstance();
            $getSettings = $oC -> getObject(3934);
            $message = $getSettings -> getValue('letter_forget_password');

            sendMail($email, $message, array("%url%"=>"http://".$_SERVER['HTTP_HOST']."/users/activation/".dechex($getUser->getId()).md5($code)));

            return array("result"=>"success");
        } else return array("result"=>"user_not_exist");
    }

    //Список интересов пользователя
    public function getInterestsOfUser(){
        $oC = umiObjectsCollection::getInstance();
        $userId = permissionsCollection::getInstance() -> getUserId();
        $getUser = $oC -> getObject($userId);
        if (is_object($getUser)){
            $getInterests = $getUser -> interests;
            $result = array();
            $hierarchy = umiHierarchy::getInstance();
            foreach($getInterests as $interest){
                $pageId = $interest -> getId();
                $getAllParents = $hierarchy -> getAllParents($pageId,true);
                $parents = getAllParents($getAllParents, array(7));
                $result[] = array("@id"=>$pageId, "@link"=>$interest -> link, "parents"=>array("nodes:parent"=>$parents));
            }

            return array("nodes:item"=>$result);
        }
        return;
    }

    //Удалить элемент из списка интересов пользователя
    public  function removeInterestsOfUser(){
        $oC = umiObjectsCollection::getInstance();
        $userId = permissionsCollection::getInstance() -> getUserId();
        $getUser = $oC -> getObject($userId);
        if (is_object($getUser)){
            $id = getRequest('id');
            if (is_numeric($id)){
                $getInterests = $getUser -> interests;
                $search = array_search($id, $getInterests);
                if ($search !== false){
                    unset($getInterests[$search]);
                    $getUser -> setValue("interests", $getInterests);
                    $getUser -> commit();
                }
            }
        }
        return;
    }

    //Добавить элемент в список интересов пользователя
    public  function addInterestsOfUser(){
        $oC = umiObjectsCollection::getInstance();
        $userId = permissionsCollection::getInstance() -> getUserId();
        $getUser = $oC -> getObject($userId);
        if (is_object($getUser)){
            $id = getRequest('id');
            if (is_numeric($id)){
                $getInterests = $getUser -> interests;
                $search = array_search($id, $getInterests);
                if ($search === false){
                    $getInterests[] = $id;
                    //Проверка дублирования интересов и удаление лишних потомков
                    foreach($getInterests as $getInterest){
                        $q = "SELECT id FROM cms3_hierarchy WHERE rel=".$getInterest;
                        $r = mysql_query($q);
                        while($row = mysql_fetch_array($r)){
                            $s = array_search($row['id'], $getInterests);
                            if ($s !== false) unset($getInterests[$s]);
                        }
                    }

                    $getUser -> setValue("interests", $getInterests);
                    $getUser -> commit();
                }
            }
        }
        return;
    }

    //Сохранить данные пользователя
    public function saveSettings(){
        $oC = umiObjectsCollection::getInstance();
        $userId = permissionsCollection::getInstance() -> getUserId();
        $getUser = $oC -> getObject($userId);
        if (is_object($getUser)){
            $data = getRequest('data');
            $fname = string_cut($data['fname'], 100);
            $lname = string_cut($data['lname'], 100);
            $day = $data['day'];
            $month = $data['month'];
            $year = $data['year'];
            $old_password = getRequest('old_password');
            $password = getRequest('password');
            $password_confirm = getRequest('password_confirm');

            if (is_numeric($day) && is_numeric($month) && is_numeric($year)){
                $date = $day.".".$month.".".$year;
                $date = strtotime($date);
                if ($date) $getUser->setValue("birthday", $date);
            }
            if ($fname) $getUser->setValue("fname", $fname);
            $getUser->setValue("lname", $lname);

            //Сохранение email
            $email = getRequest('email');
            $currentEmail = $getUser -> getValue('new_email') ? $getUser -> getValue('new_email') : $getUser -> getValue('e-mail');

            if ($email && filter_var($email, FILTER_VALIDATE_EMAIL) && ($email != $currentEmail)){

                //Изменение email
                if ($this->checkEmail(true, true)){
                    $getUser->setValue("new_email", $email);
                    $getUser->setValue("activated", false);

                    //Отправка письма
                    $getSettings = $oC -> getObject(3934);
                    $message = $getSettings -> getValue('letters_change_mail');
                    $code = uniqid();
                    $getUser -> setValue("activation_code", $code);
                    sendMail($email, $message, array("%url%"=>"http://".$_SERVER['HTTP_HOST']."/users/activation/".dechex($userId).md5($code)));
                }
            }

            //Проверка изменения пароля
            if ($password && (strlen($password) >= 6)){
                if ($password == $password_confirm){
                    $currentPass = $getUser -> getValue('password');
                    if (md5($old_password) == $currentPass){
                        $getUser -> setValue("password", md5($password));
                        $getUser -> commit();
                        $_REQUEST['u-login-store'] = "1";
                        permissionsCollection::getInstance()->loginAsUser($getUser->getId());
                    }
                }
            }

            $getUser -> commit();
        }
        $this->redirect('/cabinet/profile/common/');
        return;
    }

    //Удаление фото профиля
    public function removePhoto(){
        $root = CURRENT_WORKING_DIR;
        $oC = umiObjectsCollection::getInstance();
        $userId = permissionsCollection::getInstance() -> getUserId();
        if ($userId == 337) return;
        $getUser = $oC -> getObject($userId);
        if (is_object($getUser)){
            $getPhoto = $getUser->getValue('photo');
            if ($getPhoto){
                $filePath = trim($getPhoto -> getFilePath(),".");
                unlink($root.$filePath);
            }
            $getPhoto = $getUser->getValue('photo_fragment');
            if ($getPhoto){
                $filePath = trim($getPhoto -> getFilePath(),".");
                unlink($root.$filePath);
            }
            $getUser -> commit();
        }
        return;
    }

    //Получить данные профиля пользователя
    public function getProfile(){
        $userId = permissionsCollection::getInstance() -> getUserId();
        $oC = umiObjectsCollection::getInstance();
        $getUser = $oC -> getObject($userId);
        $result = array();
        if (is_object($getUser)){
            $BD = $getUser -> getValue('birthday');
            $BD = $BD ? $BD->timestamp : "";

            $year = $BD ? date("Y", $BD) : "";
            $month = $BD ? date("n", $BD) : "";
            $day = $BD ? date("j", $BD) : "";

            $result['id'] = $getUser -> getId();
            $result['lname'] = $getUser -> getValue('lname');
            $result['fname'] = $getUser -> getValue('fname');
            $result['birthday'] = array("year"=>$year, "month"=>$month, "day"=>$day);
            $result['photo'] = $getUser -> getValue('photo');
            $result['photo_fragment'] = $getUser -> getValue('photo_fragment');
            $result['new_email'] = $getUser -> getValue('new_email') ? $getUser -> getValue('new_email') : $getUser -> getValue('e-mail');
            $result['recommend_change_password'] = $getUser -> getValue('recommend_change_password') ? "1" : "0";
        }

        return $result;
    }

    //Загрзка аватара
    public function upload_image_profile($from_url = false){
        $root = CURRENT_WORKING_DIR;
        $oC = umiObjectsCollection::getInstance();
        $crop = getRequest("crop") ? getRequest("crop") : false;
        if ($crop){
            $crop = explode("_",$crop);
            if (count($crop) == 4){
                $images = $_SESSION['upload_image_profile'];
                if ($images){
                    $images .= ".jpg";
                    $userId = permissionsCollection::getInstance() -> getUserId();
                    $getUser = $oC -> getObject($userId);
                    if (is_object($getUser)){
                        $uniqid = uniqid();

                        $getPhoto = $getUser->getValue('photo');
                        if ($getPhoto){
                            $filePath = trim($getPhoto -> getFilePath(),".");
                            unlink($root.$filePath);
                        }
                        $getPhoto = $getUser->getValue('photo_fragment');
                        if ($getPhoto){
                            $filePath = trim($getPhoto -> getFilePath(),".");
                            unlink($root.$filePath);
                        }

                        $newFileName = createImage($root.$images, $uniqid);
                        $getUser->setValue('photo', ".".$newFileName);

                        crop($root.$images,$crop[0],$crop[1],$crop[2],$crop[3]);
                        $newFileName = createImage($root.$images, $uniqid."f");
                        $getUser->setValue('photo_fragment', ".".$newFileName);

                        $getUser->commit();
                        unset($_SESSION['upload_image_profile']);
                    }
                }
            }
            return;
        } else {
            if ($from_url){
                //Проверка, действительно ли загруженный файл является изображением
                $url = getRequest('url');
                if (checkImageUrl($url)){
                    //Проверка, действительно ли загруженный файл является изображением
                    $size = getimagesize($url);
                    if($size["mime"] != "image/gif" && $size["mime"] != "image/jpeg" && $size["mime"] !="image/png") {
                        return;
                    }

                    if( 2048<$size[0] || 2048<$size[1] )
                        $ratio = min(2048/$size[0],2048/$size[1]);
                    else $ratio=1;
                    $width=floor($size[0]*$ratio);
                    $height=floor($size[1]*$ratio);

                    $newFileName = "/files/temp/".uniqid();
                    //Функция, перемещает файл из временной, в указанную вами папку
                    if (copy($url, $root.$newFileName)) {
                        resize($root.$newFileName,$width, $height,$root.$newFileName.".jpg");
                        if (file_exists($root.$newFileName.".jpg")){
                            $_SESSION['upload_image_profile'] = $newFileName;
                        }

                        unlink($root.$newFileName);
                    }
                }
                return;
            } else {
                $root = CURRENT_WORKING_DIR;

                //Проверка, действительно ли загруженный файл является изображением
                $size = getimagesize($_FILES["filename"]["tmp_name"]);
                if($size["mime"] != "image/gif" && $size["mime"] != "image/jpeg" && $size["mime"] !="image/png") {
                    return;
                }

                if( 2048<$size[0] || 2048<$size[1] )
                    $ratio = min(2048/$size[0],2048/$size[1]);
                else $ratio=1;
                $width=floor($size[0]*$ratio);
                $height=floor($size[1]*$ratio);

                $newFileName = "/files/temp/".uniqid();
                //Функция, перемещает файл из временной, в указанную вами папку
                if (move_uploaded_file($_FILES["filename"]["tmp_name"], $root.$newFileName)) {
                    resize($root.$newFileName,$width, $height,$root.$newFileName.".jpg");
                    if (file_exists($root.$newFileName.".jpg"))
                        $_SESSION['upload_image_profile'] = $newFileName;
                    unlink($root.$newFileName);
                }
                return;
            }
        }

    }

    //Уведомления пользователя
    public function getUserNotification()
    {
        $oC = umiObjectsCollection::getInstance();
        $userId = permissionsCollection::getInstance()->getUserId();
        if ($userId == 337) return;
        $getUser = $oC->getObject($userId);
        $notifications = array();

        if (is_object($getUser)) {
            //Проверка, подтвердил ли регистрацию пользователь посредством e-mail =================
            if (!$getUser->activated) {
                $notifications[] = array(
                    '@notification' => 'user_not_activated',
                    '@email' => $getUser -> getValue('new_email') ? $getUser -> getValue('new_email') : $getUser -> getValue('e-mail'),
                    '@menu_id' => 3259      // Мои настройки -> Общее
                );
            }
            //=====================================================================================
            //Рекомендация по смене пароля ========================================================
            if ($getUser->recommend_change_password) {
                $notifications[] = array(
                    '@notification' => 'user_recommend_change_password',
                    '@menu_id' => 3259      // Мои настройки -> Общее
                );
            }
            //=====================================================================================
        }

        return array("notifications" => array("nodes:item" => $notifications));
    }

    //Проверка пароля пользователя
    public function checkPassword(){
        $password = getRequest('password');
        $old_password = getRequest('old_password');
        $oC = umiObjectsCollection::getInstance();
        $userId = permissionsCollection::getInstance()->getUserId();
        $getUser = $oC->getObject($userId);
        $out = 'false';
        if (is_object($getUser)){
            if ((!$old_password && !$password) or ($old_password && !$password)) $out = "true";
            else {
                if ($old_password && $password && (md5($old_password) == $getUser -> getValue('password'))) $out = "true";
            }
        }

        $buffer = outputBuffer::current();
        $buffer->charset('utf-8');
        $buffer->contentType('text/plane');
        $buffer->clear();
        $buffer->push($out);
        $buffer->end();
    }

    public function identification(){
        identification();
    }


}

?>
