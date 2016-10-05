<?php

require_once CURRENT_WORKING_DIR."/files/scripts-parsing/default.php";

class content_custom extends content
{

    public function cron()
    {
        $root = CURRENT_WORKING_DIR;
        $storage_time = 3600 * 24 * 3;   //секунд
        $currentTime = time();

        //Обновление новостей
        $news = cmsController::getInstance()->getModule("news");
        $pages = new selector('pages');
        $pages->types('object-type')->name('news', 'rubric');
        $pages->where('hierarchy')->page(3160)->childs(1);
        if ($pages->length) {
            foreach ($pages->result() as $lent) {
                //Проверка периода обновления новостей
                $period = $lent->getValue('period');
                $dateG = (int)date("G", $currentTime);
                if (($period == 0) or !$period) {
                    if ($dateG != 0) continue; //1 раз в сутки в 0 часов
                } else
                    if (($dateG / $period) != round($dateG / $period)) continue;

                $func = $lent->getValue("func");
                $url = $lent->getValue("url");
                eval('$news->' . $func . '($lent->getObjectId(), "' . $url . '");');
            }
        }

        //Обновление рейтинга опросов и лент ======================================================
        /*
         *  Коэффициенты для расчета популярности ОПРОСОВ - общее
         *
         *  Период учета рейтинга / популярности, ч ....................... */
        $solveRatePeriod = 24*7; /*
         *  т.е. популярность рассчитывается за этот период
         *
         *  Критерии:
         *  1) Общее количество голосов опроса ............................ */
        $solveRateKoef1 = 0.25; /*
         *  2) Количество просмотров ...................................... */
        $solveRateKoef2 = 0.2;  /*
         *  3) Количество комментариев .................................... */
        $solveRateKoef3 = 0.35; /*
         *  4) Оставшееся время до того, как опрос станет неактуальным .... */
        $solveRateKoef4 = 0.2;  /*
         *
         *  Коэффициенты для расчета популярности ОПРОСОВ - для пользователя
         *  Критерии:
         *  1) Выбранные интересы в кабинете пользователя ................. 0.7
         *  2) Расчётные интересы (из cookies) ............................ 0.3
         */

        //Определение id объектов, которые подлежат обновлению
        $result = array();
        $dateInHour = ceil(time() / 3600);

        $q = "SELECT obj_id FROM polls WHERE date>=" . ($dateInHour - $solveRatePeriod) * 3600;
        $r = mysql_query($q);
        while ($row = mysql_fetch_array($r)) $result[$row['obj_id']] = '';

        $q = "SELECT obj_id FROM comments WHERE date>=" . ($dateInHour - $solveRatePeriod) * 3600;
        $r = mysql_query($q);
        while ($row = mysql_fetch_array($r)) $result[$row['obj_id']] = '';

        $q = "SELECT obj_id FROM counter_period_view_page WHERE date_in_hour>=" . ($dateInHour - $solveRatePeriod);
        $r = mysql_query($q);
        while ($row = mysql_fetch_array($r)) $result[$row['obj_id']] = '';

        $feeds = array();
        foreach ($result as $objId => $item) {
            // 1) Общее количество голосов опроса
            $q = "SELECT COUNT(*) as total FROM polls WHERE obj_id=" . $objId . " AND date>" . (($dateInHour - $solveRatePeriod) * 3600);
            $r = mysql_query($q);
            $data = mysql_fetch_assoc($r);
            $k1 = isset($data['total']) ? ($data['total'] * $solveRateKoef1) : 0;

            // 2) Количество просмотров
            $q = "SELECT SUM(views) as total FROM counter_period_view_page WHERE obj_id=" . $objId . " AND date_in_hour>=" . ($dateInHour - $solveRatePeriod);
            $r = mysql_query($q);
            $data = mysql_fetch_assoc($r);
            $k2 = isset($data['total']) ? ($data['total'] * $solveRateKoef2) : 0;

            // 3) Количество комментариев
            $q = "SELECT COUNT(*) as total FROM comments WHERE obj_id=" . $objId . " AND date>" . (($dateInHour - $solveRatePeriod) * 3600);
            $r = mysql_query($q);
            $data = mysql_fetch_assoc($r);
            $k3 = isset($data['total']) ? ($data['total'] * $solveRateKoef3) : 0;

            $popularity = round(10 * ($k1 + $k2 + $k3));

            mysql_query("UPDATE cms3_object_content SET int_val=" . $popularity . " WHERE obj_id=" . $objId . " AND field_id=569");
            $result[$objId] = $popularity;

            //Определение ленты, к которой относится опрос
            $q = "SELECT rel_val FROM cms3_object_content WHERE obj_id=" . $objId . " AND field_id=549";
            $r = mysql_query($q);
            while ($row = mysql_fetch_array($r)) $feeds[$row['rel_val']] = '';
        }

        //Обновление рейтинга лент
        foreach ($feeds as $objId => $item) {
            $q = "SELECT obj_id FROM cms3_object_content WHERE rel_val=" . $objId . " AND field_id=549";
            $r = mysql_query($q);
            if ($r) {
                $num = mysql_num_rows($r);
                if ($num) {
                    $feedRating = 0;
                    while ($row = mysql_fetch_array($r)) $feedRating += isset($result[$row['obj_id']]) ? ($result[$row['obj_id']] ? $result[$row['obj_id']] : 0) : 0;
                    $feedRating = round($feedRating / sqrt($num));
                    mysql_query("UPDATE cms3_object_content SET int_val=" . $feedRating . " WHERE obj_id=" . $objId . " AND field_id=567");
                }
            }
        }

        //Обновление рейтинга категорий
        $s = new selector('pages');
        $s->types('hierarchy-type')->name('content', 'page');
        $s->where('hierarchy')->page(7)->childs(3);
        $s->types('object-type')->id(133);
        foreach ($s->result() as $item){
            $popularity = 0;
            $s1 = new selector('pages');
            $s1->types('object-type')->name('vote', 'poll');
            $s1->where('for_lent')->notequals(true);
            $s1->where('hierarchy')->page($item->getId())->childs(3);
            foreach($s1 -> result() as $vote){
                $popularity += $vote -> getValue('popularity');
            }
            $item -> setValue('popularity', $popularity);
            $item -> commit();
        }
        unset($s); unset($s1);


        //1 раз в сутки ===========================================================================
        if ((int)date("G", $currentTime) == 0) {
            //Удаление старых файлов
            $dir = $root . "/files/temp/";
            if ($handle = opendir($dir)) {
                while (false !== ($file = readdir($handle))) {
                    if ($file != '..')
                        if ($currentTime > (filemtime($dir . $file) + $storage_time))
                            unlink($dir . $file);
                }
                closedir($handle);
            }

            //Удаление старых новостей из БД (для каждой ленты новостей остается по 100 новостей)
            $NewsLost = 100;
            $pages = new selector('pages');
            $pages->types('object-type')->name('news', 'rubric');
            $pages->where('hierarchy')->page(3160)->childs(1);
            if ($pages->length) {
                foreach ($pages->result() as $lent) {
                    $objId = $lent->getObjectId();
                    $q = "SELECT COUNT(*) as total FROM news WHERE lent_id=" . $objId;
                    $r = mysql_query($q);
                    $data = mysql_fetch_assoc($r);
                    $total = isset($data['total']) ? $data['total'] : 0;
                    $q = "SELECT image FROM news WHERE lent_id=" . $objId . " ORDER BY date ASC LIMIT " . ($total - $NewsLost);
                    $r = mysql_query($q);
                    while ($row = mysql_fetch_array($r)) {
                        if (isset($row['image'])) {
                            unlink($root . "/files/news_images/" . $row['image'] . ".jpg");
                            unlink($root . "/files/news_images/" . $row['image'] . "_120.jpg");
                        }
                    }
                    $q = "DELETE FROM news WHERE lent_id=" . $objId . " ORDER BY date ASC LIMIT " . ($total - $NewsLost);
                    $r = mysql_query($q);
                }
            }

            //Сохранение в файл (кэш) Id категорий с названиями
            $s = new selector('pages');
            $s->types('hierarchy-type')->name('content', 'page');
            $s->types('object-type')->id(133);
            $s->where('is_active')->equals(array(0, 1));
            $result = array();
            foreach ($s->result() as $item)
                $result[$item->getId()] = array("@id" => $item->getId(), "@link" => $item->link, "@type-id" => $item->getObjectTypeId(), "node:name" => $item->getName());
            file_put_contents(CURRENT_WORKING_DIR . "/files/cache/hierarchy/getAllCategories.arr", serialize($result));

            //Обновление изображений категорий на главной странице
            $this->getListPopularCategories(true);


            //Удаление из БД лишних ответов на опросы (если опрос был удален)
            //....
            //....

            //Удаление лишних фотографий на сервере, если статьи или опросы были удалены
            //....
            //....

            //Удаление из таблицы counter_period_view_page старых записей
            //....
            //....

        }
        //=========================================================================================

        return;
    }

    public function getDefaultPageId()
    {

        /** The ID of the current language version */
        $curentLangId = cmsController::getInstance()->getCurrentLang()->getId();

        /** Instance of umiHierarchy */
        $hierarchy = umiHierarchy::getInstance();
        /** ID the default page for the current language version */
        $defaultPageId = $hierarchy->getDefaultElementId($curentLangId);

        return $defaultPageId;
    }

    public function getCurrentUrl()
    {
        $id = cmsController::getInstance()->getCurrentElementId();
        if ($id > 0) {
            /** Prefix of the current language version */
            $langPrefix = '/' . cmsController::getInstance()->getCurrentLang()->getPrefix() . '/';
            $path = str_replace($langPrefix, '/', umiHierarchy::getInstance()->getPathById($id));
            if (intval(umiHierarchy::getInstance()->getIdByPath($path)) > 0) {
                return $path;
            }
        }
        return '/';
    }

    public function getDataDetail($unix = false)
    {
        $year = date("Y", $unix);
        $month = date("n", $unix);
        $day = date("d", $unix);

        return array("year" => $year, "month" => $month, "day" => $day);
    }

    public function xsltCache($expire = 3600, $stream)
    {
        $cacheFrontend = cacheFrontend::getInstance();

        $params_temp = array_slice(func_get_args(), 2);
        $params = array();
        foreach ($params_temp as $param) {
            $params[] = (strpos($param, '/') !== false) ? "(" . $param . ")" : $param;
        }

        $params_str = implode('/', $params);
        $url = $stream . "://" . $params_str;

        //Сохраняем данные в активный кешер, иначе кладем данные в файлы
        if ($cacheFrontend->getIsConnected() == true) {
            $result = json_decode($cacheFrontend->loadData($params_str));
            if (!$result) {
                $data = file_get_contents($url);
                $cacheFrontend->saveData($params_str, json_encode($data), $expire);
                return array('plain:result' => $data);
            } else {
                return array('plain:result' => $result);
            }
        }

        $folder = CURRENT_WORKING_DIR . '/files/cache/udata/';
        $path = $folder . md5($url) . '.xml';
        if (!is_dir($folder))
            mkdir($folder, 0777, true);
        if (is_file($path))
            $mtime = filemtime($path);

        if (!is_file($path) || time() > ($mtime + $expire)) {
            $data = file_get_contents($url);
            file_put_contents($path, $data);
            return array('plain:result' => $data);
        } else {
            $result = file_get_contents($path);
            return array('plain:result' => $result);
        }
    }

    public function getMainPageId()
    {
        $s = new selector('pages');
        $s->where('is_default')->equals(1);
        $page = $s->first;
        if (is_object($page)) {
            return $page->getId();
        }
        return 0;
    }

    public function getDomainName()
    {
        return $_SERVER['HTTP_HOST'];
    }

    public function currentUrl(){
        return isset($_SERVER['SCRIPT_URL']) ? $_SERVER['SCRIPT_URL'] : "";
    }

    //==================================================================================================================
    //==================================================================================================================
    //==================================================================================================================

    //Функция, которая выполняется при каждом открытии любой страницы
    //Проверка, завершены ли все предшествующие действия
    public function doAction()
    {
        if (isset($_SESSION['action'])) {
            $action = $_SESSION['action'];
            if (is_array($action))
                if (isset($action[0]))
                    switch ($action[0]) {
                        //Сохранение нового опроса после аворизации/регистрации, если опрос был создан до авторизации/регистр.
                        case "saveNewPoll":
                            $voteModule = cmsController::getInstance()->getModule("vote");
                            $voteModule->saveNewPoll();
                            break;
                        //Сохранение новой статьи после аворизации/регистрации, если статья была создана до авторизации/регистр.
                        case "saveNewArticle":
                            //$this->saveNewArticle();
                            break;

                    }
        }
        return;
    }

    //Проверка введенного адреса изображения
    public function checkImageUrl($url = ''){
        return checkImageUrl($url);
    }

    //Проверка наличия файла
    public function fileExists($fileName = '')
    {
        if ($fileName) {
            $root = CURRENT_WORKING_DIR;
            if (file_exists($root . trim($fileName))) return "1";
        }
        return "0";
    }

    //Список стран мира
    public function getListCountries()
    {
        $query = "SELECT iso,name_ru,name_en FROM sxgeo_country ORDER BY name_ru";
        $result = mysql_query($query);
        $countries = array();
        while ($item = mysql_fetch_array($result)) $countries[] = array('@iso' => $item['iso'], '@name_ru' => $item['name_ru'], '@name_en' => $item['name_en']);
        return array("nodes:item" => $countries);
    }

    //Список регионов стран
    public function getListRegions($isoCountry)
    {
        $query = "SELECT id,name_ru,name_en FROM sxgeo_regions WHERE country='" . $isoCountry . "' ORDER BY name_ru";
        $result = mysql_query($query);
        $regions = array();
        while ($item = mysql_fetch_array($result)) $regions[] = array('@id' => $item['id'], '@name_ru' => $item['name_ru'], '@name_en' => $item['name_en']);
        return array("nodes:item" => $regions);
    }

    //Список городов
    public function getListCities($idRegion)
    {
        if (!$idRegion) return;
        $query = "SELECT id,name_ru,name_en FROM sxgeo_cities WHERE region_id='" . $idRegion . "' ORDER BY name_ru";
        $result = mysql_query($query);
        $cities = array();
        while ($item = mysql_fetch_array($result)) $cities[] = array('@id' => $item['id'], '@name_ru' => $item['name_ru'], '@name_en' => $item['name_en']);
        return array("nodes:item" => $cities);
    }

    //Текущий язык сайта
    public function getLang()
    {
        $oCurrentLang = cmsController::getInstance()->getCurrentLang();
        if ($oCurrentLang instanceof lang) return $oCurrentLang->getPrefix();
        return "ru";
    }

    //Получение geo данных
    public function geo($ip='')
    {
        $root = CURRENT_WORKING_DIR;
        $_SESSION['geo'] = array("city" => 0, "region" => "", "country" => "", "country_iso" => "", "lat" => "", "lon" => "", "iso" => "");

        include_once "SxGeo.php";
        $ip = $ip ? $ip : $_SERVER["REMOTE_ADDR"];
        $SxGeo = new SxGeo($root . '/templates/iview/classes/modules/content/SxGeoCity.dat', SXGEO_BATCH | SXGEO_MEMORY);
        $city = $SxGeo->get($ip);

        if (is_array($city)) if (isset($city['city']['id'])) if (is_numeric($city['city']['id']))
            if (isset($city['country']['id'])) if (is_numeric($city['country']['id'])) {
                $query = "SELECT iso FROM sxgeo_country WHERE id='" . $city['country']['id'] . "'";
                $result = mysql_query($query);
                $row = mysql_fetch_array($result);
                $country_iso = isset($row['iso']) ? $row['iso'] : "";
                $query = "SELECT * FROM sxgeo_cities WHERE id='" . $city['city']['id'] . "'";
                $result = mysql_query($query);
                $getCity = mysql_fetch_array($result);
                $regionId = isset($getCity['region_id']) ? $getCity['region_id'] : false;
                $lat = isset($getCity['lat']) ? $getCity['lat'] : false;
                $lon = isset($getCity['lon']) ? $getCity['lon'] : false;
                if ($regionId && $lat && $lon) {
                    $query = "SELECT * FROM sxgeo_regions WHERE id='" . $regionId . "'";
                    $result = mysql_query($query);
                    $getRegion = mysql_fetch_array($result);
                    $iso = isset($getRegion['iso']) ? $getRegion['iso'] : false;
                    $_SESSION['geo'] = array("city" => $city['city']['id'], "region" => $regionId, "country" => $city['country']['id'], "country_iso" => $country_iso, "lat" => $lat, "lon" => $lon, "iso" => $iso);
                }
            }
        return $city;
    }


    //Счетчик для xsl
    public function counter($from = 0, $to = 0, $step = 1, $type = "number", $col = 0)
    {
        $result = array();
        $test = 0;
        $months = array(
            "1" => array("Январь", "Января", "Янв"), "2" => array("Февраль", "Февраля", "Фев"),
            "3" => array("Март", "Марта", "Мар"), "4" => array("Апрель", "Апреля", "Апр"),
            "5" => array("Май", "Мая", "Май"), "6" => array("Июнь", "Июня", "Июн"),
            "7" => array("Июль", "Июля", "Июл"), "8" => array("Август", "Августа", "Авг"),
            "9" => array("Сентябрь", "Сентября", "Сен"), "10" => array("Октябрь", "Октября", "Окт"),
            "11" => array("Ноябрь", "Ноября", "Ноя"), "12" => array("Декабрь", "Декабря", "Дек")
        );
        $z = array("cy" => date("Y", time()));
        for ($index = (int)strtr($from, $z); $index <= (int)strtr($to, $z); $index = $index + $step) {
            $name = ($type == "number") ? $index : ((($type == "months") && (isset($months[$index][$col]))) ? $months[$index][$col] : 0);
            $result[] = array("@id" => $index, "@name" => $name, "node:name" => $name);
            $test++;
            if ($test > 1000) return;
        }
        return array("nodes:item" => $result);
    }

    //В админке водсвечивание страниц в соответствии с их типом
    public function getTypeContentTreeItem()
    {
        $id = getRequest('id');
        $id = trim($id, ",");
        $ids = explode(",", $id);
        $hierarchy = umiHierarchy::getInstance();
        $result = array();
        foreach ($ids as $id) {
            $getElement = $hierarchy->getElement($id);
            if ($getElement instanceof umiHierarchyElement) {
                $result[] = array("id" => $id, "type" => $getElement->getObjectTypeId());
            }
        }
        return array("nodes:item" => $result);
    }

    //Проверка капчи
    public function checkCaptcha()
    {
        $captcha = getRequest("captcha");
        if (isset($captcha)) $_SESSION['user_captcha'] = md5((int)$captcha);
        if (!umiCaptcha::checkCaptcha()) return 0;
        return 1;
    }

    //Публикация комментария
    public function sendComment(){
        $objId = getRequest('objId');
        $parent_id = getRequest('parent_id') ? getRequest('parent_id') : 0;
        $name = getRequest('name');
        $content = getRequest('content');
        $per_page = getRequest('per_page');
        $anonymous = (getRequest('anonymous') == "1") ? "1" : "0";
        $per_page = $per_page ? $per_page : 20;

        $ip = $_SERVER["REMOTE_ADDR"];

        //Проверка данных комментария
        $h = umiHierarchy::getInstance();
        if (!umiCaptcha::checkCaptcha()) return $this->getListComments($objId, $per_page);
        $content = substr($content, 0, 2000);
        $content = strip_tags($content);
        $content = htmlentities($content, ENT_QUOTES);
        $content = trim($content);
        if (!$content) return $this->getListComments($objId, $per_page);
        $userId = permissionsCollection::getInstance()->getUserId();
        if ($userId == 337)
            if (!$name) return $this->getListComments($objId, $per_page);
        $name = $name ? $name : "";
        $q = "INSERT INTO comments (obj_id,date,parent,user_id,name,ip,content,anonymous) VALUES(" . $objId . ", " . time() . ", " . $parent_id . ", " . $userId . ",'" . $name . "','" . $ip . "','" . $content . "','".$anonymous."')";

        $h = umiHierarchy::getInstance();
        $highlight = false;
        $getPageId = $h -> getObjectInstances($objId);
        if (is_array($getPageId)){
            $getPageId = current($getPageId);
            if ($getPageId){
                $getPage = $h->getElement($getPageId);
                if ($getPage instanceof umiHierarchyElement){
                    cmsController::getInstance()->getModule("events")->registerEvent('new-comment', array('content'=>('<b>'.$getPage->getValue('h1').' <a href="'.$getPage->link.'">» Страица</a></b><br/><br/><i>'.htmlentities($content, ENT_QUOTES, "UTF-8").'</i>')), null, null);
                    l_mysql_query($q);
                    $highlight = mysql_insert_id();
                }
            }
        }
        return $this->getListComments($objId, $per_page+1, $highlight);
    }

    //Список комментариев для текущей страницы
    public function getListComments($pageId = false, $per_page = '', $highlight = false)
    {
        $pageId = (int) $pageId;
        $per_page = $per_page ? $per_page : 100;
        $oC = umiObjectsCollection::getInstance();
        $userId = permissionsCollection::getInstance()->getUserId();
        $getCurrentUser = $oC -> getObject($userId);

        $q = "SELECT * FROM comments WHERE obj_id='".$pageId."' ORDER BY id";
        $r = l_mysql_query($q);
        $result = array();
        $captcha = umiCaptcha::isNeedCaptha() ? "/captcha.php" : "";

        while($row = mysql_fetch_array($r)){
            $result[$row['parent']][$row['id']] = '';
        }
        if (isset($result[0])) {
            $childs = $result;
            unset($childs[0]);
            $result = $result[0];
            $result = $this->createListComment($result, $childs);
            $result = $this->listCommentsSort($result);
            $query = $this->listCommentsQuery($result);
            $query = trim($query, ",");
            $qArr = explode(",",$query);
            $total = count($qArr);
            if ($total){
                $qArr = array_slice($qArr, 0, $per_page);
                $query = " AND id IN (".implode(",", $qArr).")";
            }

            $q = "SELECT * FROM comments WHERE obj_id='" . $pageId ."'". $query." ORDER BY id";
            $r = l_mysql_query($q);
            $result = array();
            while ($item = mysql_fetch_array($r)) {
                $getUser = $oC->getObject($item['user_id']);
                if (!is_object($getUser)) continue;
                $userName = $getUser->getValue('fname');
                $userName = $userName ? $userName : $getUser->login;
                $userName = $item['name'] ? $item['name'] : $userName;
                $dateSimple = showDate($item['date']);

                //Преобразование содержимого комментария
                $content = $item['content'];
                $content = strip_tags($content);
                $content = strtr($content, array(PHP_EOL => "<br/>"));

                $result[$item['parent']][$item['id']] = array(
                    "@id" => $item['id'],
                    "@date" => $item['date'],
                    "@date_detail" => date("Y.m.d G:i:s", $item['date']),
                    "@date_simple" => $dateSimple,
                    "@parent" => $item['parent'],
                    "@user_id" => $item['user_id'],
                    "@anonymous" => isset($item['anonymous']) ? $item['anonymous'] : "1",
                    "user" => array("@id" => $getUser->getId()),
                    "name" => $userName,
                    "@ip" => $item['ip'],
                    "content" => $content,
                    "content_cut" => string_cut($content, 250),
                    "@moderate" => $item['moderate'],
                    "@visible" => $item['visible'],
                    "photo" => $getUser->getValue("photo_fragment"),
                    "@highlight" => ($highlight == $item['id']) ? "1" : ""
                );
            }
            if (isset($result[0])) {
                $childs = $result;
                unset($childs[0]);
                $result = $result[0];
                $result = $this->createTreeComment($result, $childs);
            }

            $result = $this->treeCommentSort($result);
            return array("items" => array("nodes:item" => $result, "@level" => 0, "@id" => $pageId, "@user" => $userId, "@user_photo_fragment"=>$getCurrentUser->getValue('photo_fragment'), "@captcha"=>$captcha), "obj_id"=>$pageId, "total"=>$total, "per_page"=>$per_page, "current_user"=>array("@id"=>$userId,"@user_photo_fragment"=>$getCurrentUser->getValue('photo_fragment'),"@captcha"=>$captcha));
        }
        return array("total"=>0, "per_page"=>$per_page, "obj_id"=>$pageId, "current_user"=>array("@id"=>$userId, "@user_photo_fragment"=>$getCurrentUser->getValue('photo_fragment'), "@captcha"=>$captcha));
    }

    //Создание дерева комментариев
    public function createTreeComment($result = array(), $childs = array(), $level = 0)
    {
        //Многоуровневое дерево ===================================================================
        $level++;
        if ($level > 100) return $result;
        foreach ($result as $id => $comment) {
            if (isset($childs[$id])) {
                foreach ($childs[$id] as $index => $child) $childs[$id][$index]['@level'] = $level;
                $result[$id]['items'] = array("nodes:item" => $childs[$id], "@level" => $level);
                if (count($result[$id]['items']['nodes:item']))
                    $result[$id]['items']['nodes:item'] = $this->createTreeComment($result[$id]['items']['nodes:item'], $childs, $level);
            }
        }
        return $result;
        // ========================================================================================
    }
    public function createListComment($result = array(), $childs = array(), $level = 0)
    {
        //Многоуровневое дерево ===================================================================
        $level++;
        if ($level > 100) return $result;
        foreach ($result as $id => $comment) {
            if (isset($childs[$id])) {
                $result[$id] = $childs[$id];
                if (count($result[$id]))
                    $result[$id] = $this->createListComment($result[$id], $childs, $level);
            }
        }
        return $result;
        // ========================================================================================
    }
    public function listCommentsQuery($arr = array(), $query = '', $level = 0){
        if ($level > 100) return;
        foreach($arr as $id=>$value){
            if (is_array($value) && count($value)){
                $query .= $this->listCommentsQuery($value, $id.",", $level + 1);
            } else $query .= $id.",";
        }
        return $query;
    }

    //Сортировка комментариев от новых к старым
    public function listCommentsSort($result, $level = 0){
        if ($level > 100) return;
        krsort($result);
        foreach($result as $id=>$value){
            if (is_array($value) && count($value)){
                $result[$id] = $this->listCommentsSort($result[$id], $level + 1);
            };
        }
        return $result;
    }
    public function treeCommentSort($result, $level = 0){
        if ($level > 100) return;
        krsort($result);
        foreach($result as $id=>$value){
            if (isset($value['items']['nodes:item']))
                if (is_array($value['items']['nodes:item']) && count($value['items']['nodes:item'])){
                    $result[$id]['items']['nodes:item'] = $this->treeCommentSort($result[$id]['items']['nodes:item'], $level + 1);
                };
        }
        return $result;
    }

    //Удаление комментария
    public function comment_remove($commentId = ''){
        $userId = permissionsCollection::getInstance()->getUserId();
        if ($userId == 2){
            $q = "DELETE FROM comments WHERE id='" . $commentId . "'";
            $r = mysql_query($q);
        }
        return;
    }


    //Проверка капчи
    public function check_captcha($user_code)
    {
        if ($user_code) {
            $_SESSION['user_captcha'] = md5((int)$user_code);
            // HINT: umiCaptcha::checkCaptcha() method gets the code from $_REQUEST[]
            $_REQUEST['captcha'] = $user_code;
        }

        $result = array();
        if (isset($user_code) && umiCaptcha::checkCaptcha()) {
            $result['error_code'] = 0; // captcha is okay
        } else {
            $result['error_code'] = 1; // invalid captcha code
        }
        return $this->parseTemplate('', $result);
    }

    public function getWikiContent()
    {
        $str = getRequest('query');
        $content = file_get_contents('https://ru.wikipedia.org/w/api.php?action=opensearch&search=' . urlencode($str) . '&format=json');
        if (!$content) return;

        $content = json_decode($content);
        $content = (array)$content;
        $url = isset($content[3][0]) ? $content[3][0] : false;
        $url = end(explode("/",$url));
        if ($url){
            $content = file_get_contents('https://ru.wikipedia.org/w/api.php?action=parse&prop=text&page=' . $url . '&format=json');

            //Если указана переадресация

            $redirect = strpos($content, '<ul class=\"redirectText\">');
            if ($redirect !== false) {
                $url = substr_replace($content, "", 0, strpos($content, "href=", $redirect) + 7);
                $url = substr($url, 0, strpos($url, "\"")-1);
                $url = strtr($url, array("/wiki/"=>""));
                $content = file_get_contents('https://ru.wikipedia.org/w/api.php?action=parse&page=' . $url . '&format=json');
                $content = json_decode($content);
                $content = (array)$content;

                if (isset($content['parse'])) {
                    $content = (array)$content['parse'];
                    if (isset($content['text'])) {
                        $content = (array)$content['text'];
                        if (isset($content['*'])) {
                            $content = (string)$content['*'];
                            $idToc = strpos($content, "<div id=\"toc\"");
                            if ($idToc !== false) {
                                $content = substr($content, 0, $idToc);
                                $image = false;
                                $table = substr($content, 0, strrpos($content, "</table>") + 8);
                                $imgPosition = strpos($table, "src=\"", strpos($table, "class=\"image\""));
                                if ($imgPosition !== false) {
                                    $image = substr($table, $imgPosition + 5, strpos($table, "\"", $imgPosition + 5) - ($imgPosition + 5));
                                    $image = "https:" . $image;
                                }
                                $content = substr_replace($content, "", 0, strrpos($content, "</table>") + 8);
                                $content = substr_replace($content, "", 0, strpos($content, "<p>"));
                                $content = strtr($content, array("<p></p>" => ""));
                                $content = trim($content);
                                $content = strip_tags($content, "<b></b><strong></strong><i></i><p></p><br></br>");
                                for ($index = 1; $index < 100; $index++) $content = strtr($content, array("[" . $index . "]" => ""));
                                return array("image" => ($image !== false) ? $image : "", "content" => $content);
                            }
                        }
                    }
                }
            }

        }

        return;
    }

    //Вывод формы для добавления новой статьи
    public function getNewArticleForm($change = false)
    {
        $url = getRequest('url');
        $url = substr_replace($url, "", 0, strpos($url, "?") + 1);
        parse_str($url, $url);

        $h = umiHierarchy::getInstance();
        $userId = permissionsCollection::getInstance()->getUserId();

        //Проверка, есть ли get параметр режима редактирования статьи =============================
        $editMode = false;
        if (isset($url['edit'])) {
            if ($url['edit']) {
                $editMode = $url['edit'];

                //Проверка пользователя
                $getArticle = $h->getElement($editMode);
                if (!$getArticle instanceof umiHierarchyElement) return;

                $getUserId = $getArticle->getValue('user') ? $getArticle->getValue('user') : false;
                if (($userId != 2) && (($getUserId === false) or ($userId != $getUserId))) return;
            }
        }
        //=========================================================================================

        //Если данные перезаписываются ============================================================
        if ($change == "1") {
            $data = getRequest('data');

            //foreach ($article as $index => $value) if (isset($data[$index])) $article[$index] = is_array($data[$index]) ? $data[$index] : trim($data[$index]);
            foreach ($data as $index => $value) if ($value) $article[$index] = is_array($data[$index]) ? $data[$index] : trim($data[$index]);

            $currentSession = !empty($_SESSION['article_new']) ? $_SESSION['article_new'] : array();


            //Если тип данных "Фильм" и в заголовке указано, например, "kinopoisk-12345"
            if (
                ($article['_type'] == '157')
                && isset($article['h1'])
            ){
                if ((
                    isset($currentSession['h1'])
                    && ($currentSession['h1'] != $article['h1'])
                ) or (
                    $article['h1'] && !isset($currentSession['h1'])
                ))
                    if (strpos($article['h1'],"kinopoisk-")!== false){

                        //Парсинг с kinopoisk
                        $kinopoiskId = strtr($article['h1'], array("kinopoisk-"=>""));
                        $data = $this -> parse("kinopoisk",$kinopoiskId);
                        /*  "h1"=>$h1,
                            "year"=>$year,
                            "country"=>$country,
                            "duration"=>$duration,
                            "description"=>$description,
                            "img"=>$img,
                            "actors" => $actors,
                            "genre" => $genre
                        */

                        $newFileName = "";
                        if (isset($data['img'])){
                            $newFileName = createImage($data['img'], uniqid());
                        }

                        $article['h1'] = isset($data['h1']) ? $data['h1'] : "";
                        $article['year'] = isset($data['year']) ? $data['year'] : "";
                        $article['country'] = isset($data['country']) ? $data['country'] : "";
                        $article['article'] = isset($data['description']) ? $data['description'] : "";
                        $article['genre'] = isset($data['genre']) ? $data['genre'] : "";
                        $article['poster'] = $newFileName ? $newFileName : "";
                        $article['_category'] = 8;
                        $article['_subcategory'] = 28;
                    }

            }


            $oTC = umiObjectTypesCollection::getInstance();
            $getType = $oTC -> getType($article['_type']);
            if (is_object($getType)){
                $getFieldsGroupsList = $getType -> getFieldsGroupsList();
                foreach($getFieldsGroupsList as $group){
                    if ($group -> getIsVisible()){
                        $getFields = $group -> getFields();
                        foreach($getFields as $field){
                            if ($field -> getIsVisible()){
                                if ($field -> getDataType() == "img_file"){
                                    $fieldName = $field -> getName();
                                    if (isset($_SESSION['article_new_image_'.$fieldName])) {
                                        if ($_SESSION['article_new_image_'.$fieldName]) {
                                            $article[$fieldName] = $_SESSION['article_new_image_'.$fieldName] . ".jpg";
                                        }
                                        unset($_SESSION['article_new_image_'.$fieldName]);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            $_SESSION['article_new'] = $article;
        } else {
            if (isset($_SESSION['article_new'])) $article = $_SESSION['article_new'];
        }

        if ($editMode !== false) {
            $article['_edit_mode'] = $editMode;
            $article['_edit_mode_cancel'] = $h -> getPathById($editMode);
        }

        $article['_current_user'] = umiObjectsCollection::getInstance()->getObject(permissionsCollection::getInstance()->getUserId());

        foreach($article as $field=>$value){
            $article[] = array("@name"=>$field, "value"=>$value);
            unset($article[$field]);
        }
        return array("nodes:field"=>$article);
    }

    //Создание статьи на основе wikipedia
    public function saveWikiContent($pageId = false)
    {
        if (!is_numeric($pageId)) return;
        $img = getRequest('img');
        $content = getRequest('content');
        if (!$img or !$content) return;
        $hierarchy = umiHierarchy::getInstance();
        $getPage = $hierarchy->getElement($pageId);
        if ($getPage instanceof umiHierarchyElement) {
            $old_mode = umiObjectProperty::$IGNORE_FILTER_INPUT_STRING;        //Откючение html сущн.
            umiObjectProperty::$IGNORE_FILTER_INPUT_STRING = true;
            $getPage->setValue("content", $content);
            $newFileName = createImage($img, $pageId);
            $getPage->setValue('type', "article");
            $getPage->setValue('date', time());
            $getPage->setValue('source_title', "Википедия");
            $getPage->setValue('source_url', "https://ru.wikipedia.org");
            $getPage->setValue('img', "." . $newFileName);
            $getPage->commit();
        }
        return;
    }

    //Поиск страницы для админки - autocomplete
    public function searchPage(){
        $search = cmsController::getInstance()->getModule("search");
        $search_string = getRequest('search_string');
        $result = $search->s('', $search_string, '','','', true);
        $hierarchy = umiHierarchy::getInstance();

        if (isset($result['items']['nodes:item']))
            if (is_array($result['items']['nodes:item']))
                if (count($result['items']['nodes:item']))
                    foreach ($result['items']['nodes:item'] as $id => $item) {
                        if (isset($item['@id']))
                            if ($item['@id']) {
                                $getPage = $hierarchy->getElement($item['@id']);
                                if ($getPage instanceof umiHierarchyElement) {
                                    $objId = $getPage->getObjectId();
                                    if ($objId) $result['items']['nodes:item'][$id]['attribute:obj_id'] = $objId;
                                    if ($objId) $result['items']['nodes:item'][$id]['attribute:name'] = $getPage -> getName();
                                }
                            }
                    }
        return $result;
    }

    //Получить данные статьи
    public function getArticle($pageId = false)
    {
        $identification = isset($_SESSION['identification']) ? $_SESSION['identification'] : identification();
        $user_auth = $identification[0];
        $userId = $identification[1];
        $needAuth = $identification[2];

        $hierarchy = umiHierarchy::getInstance();
        $oC = umiObjectsCollection::getInstance();
        $getPage = $hierarchy->getElement($pageId);
        $result = array();
        if ($getPage instanceof umiHierarchyElement) {
            $type = $getPage -> getObjectTypeId();

            $oTC = umiObjectTypesCollection::getInstance();
            $getType = $oTC -> getType($type);
            if (is_object($getType)){
                $getAllFields = $getType -> getAllFields();
                foreach($getAllFields as $field){
                    switch($field->getName()){

                        default:
                            $value = $getPage -> getValue($field->getName());
                            $result[] = array(
                                "@name" => $field->getName(),
                                "value" => is_array($value) ? array("nodes:item"=>$value) : $value
                            );

                            break;
                    }
                }
                $result[] = array("@name"=>"_id", "value"=>$pageId);
                $result[] = array("@name"=>"_obj_id", "value"=>$getPage->getObjectId());
                $result[] = array("@id"=>$userId, "@name"=>"_current_user", "@auth"=>($user_auth ? '1' : '0'));

                $getAllParents = $hierarchy->getAllParents($pageId);
                $parents = getAllParents($getAllParents, array(7));
                $result[] = array("@name"=>'_categories', "value" => array("nodes:item" => $parents));

                $result[] = array("@name"=>"_is_active", "value"=>$getPage->getIsActive() ? "1" : "0");

                $result[] = array("@name"=>"_article_user", "value" => $getPage -> getValue('user'));

                $result[] = array("@name"=>"_link", "value" => $getPage -> link);

                $trailer = $getPage -> getValue('trailer');
                if (strpos($trailer, "youtube") !== false){
                    parse_str($trailer, $uri);
                    $uri = current($uri);
                    if ($uri)
                        $result[] = array("@name"=>"_trailer", "value" => '<iframe class="article_film_trailer" src="https://www.youtube.com/embed/'.$uri.'" frameborder="0" allowfullscreen></iframe>');
                }

                //Связанные опросы
                $s = new selector('pages');
                $s->types('object-type')->name('vote', 'poll');
                $s->where('base')->equals($pageId);
                $s->order('ord');
                if ($s->length) {
                    $result[] = array("@name"=>'_polls', "value"=>array("nodes:item" => $s->result()));
                }

                //Расчет рейтинга
                $objId = $getPage->getObjectId();
                $s = new selector('pages');
                $s->types('object-type')->name('vote', 'poll');
                $s->where('variant_page')->equals(array('rel' => $objId));

                if ($s->length) {
                    $result[] = array("@name"=>'_ratings', "value"=>array("nodes:item" => $s->result()));
                }

                $typeArticle = $getPage->getValue('type');
                $typeArticle = $oC->getObject($typeArticle);
                $typeArticle = is_object($typeArticle) ? array("@id"=>$typeArticle -> getValue("type_id"),"@obj_id" => $typeArticle->getId(), "@name" => $typeArticle->getName(), "@class" => $typeArticle->getValue("class"), "@rp" => $typeArticle->getValue('rp')) : "";

                $result[] = array("@name"=>"_type", "value"=>$typeArticle);
            }
            return array("nodes:field"=>$result);

            /*$result['id'] = $pageId;
            $result['obj_id'] = $getPage->getObjectId();
            $result['link'] = $getPage->link;
            $result['h1'] = $getPage->getValue('h1');
            $result['content'] = $getPage->getValue('content');
            $result['source_url'] = $getPage->getValue('source_url');
            $result['source_title'] = $getPage->getValue('source_title');
            $result['date'] = $getPage->getValue('date');
            $result['img'] = $getPage->getValue('img');
            $result['article_user'] = $getPage -> getValue('user');
            $result['user'] = array("@id"=>$userId, "@auth"=>($user_auth ? '1' : '0'));
            $result['is_active'] = $getPage->getIsActive() ? "1" : "0";

            $getAllParents = $hierarchy->getAllParents($pageId);
            $parents = getAllParents($getAllParents, array(7));
            $result['categories'] = array("nodes:item" => $parents);

            $s = new selector('pages');
            $s->types('object-type')->name('vote', 'poll');
            $s->where('base')->equals($pageId);
            $s->order('ord');
            if ($s->length) {
                $result['polls'] = array("nodes:item" => $s->result());
            }

            //Расчет рейтинга
            $objId = $getPage->getObjectId();
            $s = new selector('pages');
            $s->types('object-type')->name('vote', 'poll');
            $s->where('variant_page')->equals(array('rel' => $objId));

            if ($s->length) {
                $result['ratings'] = array("nodes:item" => $s->result());
            }

            $typeArticle = $getPage->getValue('type');
            $typeArticle = $oC->getObject($typeArticle);
            $typeArticle = is_object($typeArticle) ? array("@id" => $typeArticle->getId(), "@name" => $typeArticle->getName(), "@class" => $typeArticle->getValue("class"), "@rp" => $typeArticle->getValue('rp')) : "";

            $result['type'] = $typeArticle;

            return $result;*/
        }
        return;
    }

    //Загрузка изображения для статьи
    public function upload_image_article($from_url = false)
    {
        $field_name = "";
        $parameters = getRequest('parameters');
        parse_str($parameters, $output);
        if (isset($output['field_name']))
            if ($output['field_name']) {
                $field_name = $output['field_name'];
            }

        if ($from_url) {
            $root = CURRENT_WORKING_DIR;

            //Проверка, действительно ли загруженный файл является изображением
            $url = getRequest('url');
            if ($this->checkImageUrl($url)) {
                //Проверка, действительно ли загруженный файл является изображением
                $size = getimagesize($url);
                if ($size["mime"] != "image/gif" && $size["mime"] != "image/jpeg" && $size["mime"] != "image/png") {
                    return;
                }

                if (2048 < $size[0] || 2048 < $size[1])
                    $ratio = min(2048 / $size[0], 2048 / $size[1]);
                else $ratio = 1;
                $width = floor($size[0] * $ratio);
                $height = floor($size[1] * $ratio);

                $newFileName = "/files/temp/" . uniqid();
                //Функция, перемещает файл из временной, в указанную вами папку
                if (copy($url, $root . $newFileName)) {
                    resize($root . $newFileName, $width, $height, $root . $newFileName . ".jpg");
                    if (file_exists($root . $newFileName . ".jpg")) {
                        $_SESSION['article_new_image_'.$field_name] = $newFileName;
                        $_SESSION['upload_image_article'] = $newFileName;
                    }

                    unlink($root . $newFileName);
                }
            }
            return;
        } else {
            $root = CURRENT_WORKING_DIR;

            //Проверка, действительно ли загруженный файл является изображением
            $size = getimagesize($_FILES["filename"]["tmp_name"]);
            if ($size["mime"] != "image/gif" && $size["mime"] != "image/jpeg" && $size["mime"] != "image/png") {
                return;
            }

            if (2048 < $size[0] || 2048 < $size[1])
                $ratio = min(2048 / $size[0], 2048 / $size[1]);
            else $ratio = 1;
            $width = floor($size[0] * $ratio);
            $height = floor($size[1] * $ratio);

            $newFileName = "/files/temp/" . uniqid();
            //Функция, перемещает файл из временной, в указанную вами папку
            if (move_uploaded_file($_FILES["filename"]["tmp_name"], $root . $newFileName)) {
                resize($root . $newFileName, $width, $height, $root . $newFileName . ".jpg");
                if (file_exists($root . $newFileName . ".jpg")) {
                    $_SESSION['article_new_image_'.$field_name] = $newFileName;
                    $_SESSION['upload_image_article'] = $newFileName;
                }
                unlink($root . $newFileName);
            }
            return;
        }
    }

    //Сохранение новой статьи
    public function saveNewArticle()
    {
        $root = CURRENT_WORKING_DIR;
        $h = umiHierarchy::getInstance();
        $userId = permissionsCollection::getInstance()->getUserId();
        $getPostData = getRequest('data');

        $this->getNewArticleForm(true);    //На случай, если какие-то данные в сессии не были сохранены + прописание в сессию article_new данных

        //Проверка, выполняется редактирование статьи или создание новой ==========================
        $editMode = isset($getPostData['edit']) ? $getPostData['edit'] : false;
        $editMode = $editMode ? $editMode : false;
        if ($editMode !== false) {
            //Проверка пользователя
            $getArticle = $h->getElement($editMode);
            if (!$getArticle instanceof umiHierarchyElement) return array("error" => "homepage");

            $getUserId = $getArticle->getValue('user') ? $getArticle->getValue('user') : false;
            if (($userId != 2) && (($getUserId === false) or ($userId != $getUserId))) return array("error" => "homepage");

            $s = new selector('pages');
            $s->types('object-type')->name('vote', 'poll');
            $s->where('is_active')->equals(array(0, 1));
            $s->where('base')->equals($editMode);
            $result = $s->result();

            foreach ($result as $getPoll) clearCachePoll($getPoll->getId());
        }
        //=========================================================================================

        $_SESSION['action'] = array("saveNewArticle");

        $data = isset($_SESSION['article_new']) ? $_SESSION['article_new'] : false;
        if ($data === false) return array("error" => "not_enough_data");


        //Проверка достаточночти данных для создания статьи =============================
        //Если неавторизован
        if ($userId == 337) return array("error" => "not_auth");   //Если неавторизован

        $required = array("h1");
        $oTC = umiObjectTypesCollection::getInstance();
        $getTypeId = $data['_type'];
        $getType = $oTC -> getType($getTypeId);
        if (is_object($getType)){
            $getFieldsGroupsList = $getType -> getFieldsGroupsList();
            foreach($getFieldsGroupsList as $group){
                if ($group -> getIsVisible()){
                    $getFields = $group -> getFields();
                    foreach($getFields as $field){
                        if ($field -> getIsVisible() && $field -> getIsRequired()){
                            $required[] = $field->getName();
                        }
                    }
                }
            }

            $stat = count($required);
            foreach($required as $field){
                if (isset($data[$field]))
                    if ($data[$field]) $stat--;
            }
            if ($stat) return array("error" => "not_enough_data");
            //===============================================================================

            //Определение категории
            $parent = isset($data['_category']) ? (($data['_category'] && is_numeric($data['_category'])) ? $data['_category'] : false) : false;
            if (isset($data['_subcategory']))
                if ($data['_subcategory'] && is_numeric($data['_subcategory'])) $parent = (int)$data['_subcategory'];
            if (!$parent) return array("error" => "not_enough_data");


            if (isset($_SESSION['action'])) {
                $action = $_SESSION['action'];
                if (isset($action[0]))
                    if ($action[0] == "saveNewArticle") unset($_SESSION['action']);
            }

            if ($editMode !== false) {
                $articleId = $editMode;
            } else {
                $theme = $data['h1'];
                $articleId = $h->addElement($parent, 30, $theme, '', $getTypeId);
            }

            $getarticle = $h->getElement($articleId, true);
            if (!$getarticle instanceof umiHierarchyElement) return;
            $old_mode = umiObjectProperty::$IGNORE_FILTER_INPUT_STRING;        //Откючение html сущн.
            umiObjectProperty::$IGNORE_FILTER_INPUT_STRING = true;

            foreach($getFieldsGroupsList as $group){
                if ($group -> getIsVisible()){
                    $getFields = $group -> getFields();
                    foreach($getFields as $field){
                        if ($field -> getIsVisible()){
                            $fieldName = $field -> getName();
                            $value = $data[$fieldName];
                            if ($field -> getDataType() == "string"){
                                if ($fieldName == "h1"){
                                    $getarticle->setName(string_cut($value, 250));
                                    $getarticle->setValue('title', string_cut($value, 250));
                                    $getarticle->setValue('h1', string_cut($value, 250));
                                } else {
                                    $getarticle->setValue($fieldName, string_cut($value, 250));
                                }
                            }
                            if ($field -> getDataType() == "img_file"){
                                $images = $value ? $value : false;
                                if ($images !== false) {
                                    $newFileName = createImage($root . $images, uniqid());
                                    unlink($root . $images);
                                    $getarticle->setValue($fieldName, "." . $newFileName);
                                } else {
                                    $getPhoto = $getarticle->getValue($fieldName);
                                    if ($getPhoto) {
                                        $filePath = trim($getPhoto->getFilePath(), ".");
                                        unlink($root . $filePath);
                                    }
                                }
                            }
                            if ($field -> getDataType() == "boolean"){
                                $getarticle->setValue($fieldName, $value ? true : false);
                            }
                            if ($field -> getDataType() == "wysiwyg"){
                                $getarticle -> setValue($fieldName, $value);
                            }
                        }
                    }
                }
            }

            $getarticle->setIsActive(false);
            $getarticle->setAltName($articleId);


            $s = new selector('objects');
            $s->types('object-type')->id(145);
            $s->where('type_id')->equals($getTypeId);
            if ($s->length)
                $getarticle->setValue('type', $s->first->id);

            if (!$editMode) {
                $getarticle->setValue('date', time());
                $getarticle->setValue("user", $userId);
            }
            permissionsCollection::getInstance()->setDefaultPermissions($articleId);

            $getParentId = $getarticle->getParentId();
            if ($getParentId != $parent) {
                $getarticle->setRel($parent);
            }

            $getarticle->commit();

            if ($getParentId != $parent) {
                $h->rebuildRelationNodes($getarticle->getId());
            }

            unset($_SESSION['article_new']);
            unset($_SESSION['upload_image_article']);
            return array("url" => "/content/preview/" . $articleId . "/");
        }
        return;

    }

    //Если возникла ошибка при отображении содержимого статьи
    public function articleError(){
        $REQUEST_URI = $_SERVER['REQUEST_URI'];
        if ($REQUEST_URI){
            if (strpos($REQUEST_URI, "/content/preview/") !== false){
                $articleId = strtr($REQUEST_URI, array("/content/preview/"=>""));
                $articleId = trim($articleId, "/");
                if (is_numeric($articleId)){
                    $hierarchy = umiHierarchy::getInstance();
                    $getArticle = $hierarchy -> getElement($articleId);
                    if ($getArticle instanceof umiHierarchyElement){
                        $userId = permissionsCollection::getInstance()->getUserId();
                        $getUserId = $getArticle->getValue('user') ? $getArticle->getValue('user') : false;
                        if (($getUserId !== false) && ($userId == $getUserId)) {
                            $getArticle -> setValue("content", "");
                            $getArticle -> commit();
                            $this->redirect($REQUEST_URI);
                        }
                    }
                }
            }
        }
        return;
    }

    //Список статей пользователя
    public function getListArticlesOfUser()
    {
        $oC = umiObjectsCollection::getInstance();
        $hierarchy = umiHierarchy::getInstance();
        $userId = permissionsCollection::getInstance()->getUserId();
        $getUser = $oC->getObject($userId);
        $result = array();
        if (is_object($getUser)) {
            $getSettings = $oC->getObject(3934);
            $p = getRequest('p') ? getRequest('p') : 0;
            $sort = getRequest('sort') ? getRequest('sort') : 'new';
            $per_page = 20;
            if (is_object($getSettings)) {
                $per_page = $getSettings->getValue('cabinet_my_articles_per_page');
            }

            $s = new selector('pages');
            $s->types('hierarchy-type')->name('content', 'page');
            $s->types('object-type')->id(141);
            $s->where('is_active')->equals(array(0, 1));
            $s->where('user')->equals($userId);
            switch ($sort) {
                case 'new':
                    $s->order('date')->desc();
                    break;
                case 'old':
                    $s->order('date')->asc();
                    break;
                case 'popularity':
                    $s->order('popularity')->desc();
                    break;
                default:
                    $s->order('date')->desc();
                    break;
            }
            $s->limit($p * $per_page, $per_page);
            $total = $s->length;
            $result = array();
            foreach ($s->result() as $item) {
                $getAllParents = $hierarchy->getAllParents($item->getId());
                $date = is_object($item->getValue('date')) ? $item->getValue('date') : "";
                $date = $date ? date("Y.m.d H:i", $date->timestamp) : "";
                $result[] = array(
                    "@id" => $item->getId(), "@date" => $date, "@is-active" => $item->getIsActive() ? "1" : "0",
                    "@link" => $item->link, "@link_preview" => "/content/preview/" . $item->getId() . "/", "items" => array("nodes:item" => getAllParents($getAllParents, array(0, 7))),
                    "name" => $item->getName()
                );
            }

            return array("items" => array("nodes:article" => $result), "total" => $total, "per_page" => $per_page, "current_page" => $p);
        }
        return;
    }

    //Изменение данных статей в кабинете пользователя
    public function changeUserArticles()
    {
        $data = getRequest('data');
        if (is_array($data)) {
            $hierarchy = umiHierarchy::getInstance();
            $userId = permissionsCollection::getInstance()->getUserId();
            foreach ($data as $id => $item) {
                $getElement = $hierarchy->getElement($id);
                if ($getElement instanceof umiHierarchyElement) {
                    $getUserId = $getElement->getValue('user') ? $getElement->getValue('user') : false;
                    if (($userId == 2) or (($userId !== false) && ($userId == $getUserId))) {
                        if (isset($item['is_active'])) {
                            $getElement->setIsActive(($item['is_active'] == "1") ? true : false);
                            $getElement->commit();

                            //Вызов системного события "Изменение страницы в админке"
                            $oEventPoint = new umiEventPoint("systemModifyElement");
                            $oEventPoint->setMode("before");
                            $oEventPoint->addRef("element", $getElement);
                            $this->setEventPoint($oEventPoint);

                            $s = new selector('pages');
                            $s->types('object-type')->name('vote', 'poll');
                            $s->where('base')->equals($id);
                            foreach ($s->result() as $poll) clearCachePoll($poll->getId());

                            $this->redirect('/content/preview/'.$id);
                        }
                    }
                }
            }
        }
        return;
    }

    //Выводит название временного файла изображения из сессии
    public function getImageName()
    {
        $session_name = getRequest('session_name');
        return array("image" => isset($_SESSION[$session_name]) ? $_SESSION[$session_name] : "");
    }

    //Редактирование статьи
    public function edit_article($articleId)
    {
        if (!is_numeric($articleId)) $this->redirect('/');

        $h = umiHierarchy::getInstance();
        $getArticle = $h->getElement($articleId);
        $root = CURRENT_WORKING_DIR;
        if ($getArticle instanceof umiHierarchyElement) {

            //Если есть хоть один голос, редактирование запрещено
            /*$s = new selector('pages');
            $s->types('object-type')->name('vote', 'poll');
            $s->where('is_active')->equals(array(0, 1));
            $s->where('base')->equals($articleId);

            foreach ($s->result() as $getPoll) {
                $votes = $getPoll->getValue('votes');
                $votes = $votes ? unserialize($votes) : "";
                $votes = is_array($votes) ? $votes : "";
                $numVotes = 0;
                if (is_array($votes) && count($votes))
                    foreach ($votes as $num) $numVotes += $num;
                if ($numVotes) $this->redirect('/');
            }*/

            //Проверка пользователя
            $userId = permissionsCollection::getInstance()->getUserId();
            $getUserId = $getArticle->getValue('user') ? $getArticle->getValue('user') : false;
            if (($userId == 2) or (($getUserId !== false) && ($userId == $getUserId))) {

                if (isset($_SESSION['article_new'])) unset($_SESSION['article_new']);

                $getAllParents = $h->getAllParents($articleId);

                $getObjectTypeId = $getArticle -> getObjectTypeId();

                $article = array(
                    '_type'=>$getArticle -> getObjectTypeId(),
                    '_category' => isset($getAllParents[2]) ? $getAllParents[2] : "",
                    '_subcategory' => isset($getAllParents[3]) ? $getAllParents[3] : ""
                );

                $oTC = umiObjectTypesCollection::getInstance();
                $getType = $oTC -> getType($getObjectTypeId);
                if (is_object($getType)){
                    $getFieldsGroupsList = $getType -> getFieldsGroupsList();
                    foreach($getFieldsGroupsList as $group){
                        if ($group -> getIsVisible()){
                            $getFields = $group -> getFields();
                            foreach($getFields as $field){
                                if ($field -> getIsVisible()){
                                    $fieldName = $field -> getName();
                                    if ($field -> getDataType() == "img_file"){
                                        $getImage = $getArticle->getValue($fieldName);
                                        if (is_object($getImage))
                                            $article[$fieldName] = trim($getArticle->getValue($fieldName) -> getFilePath(),".");
                                    } else
                                        $article[$fieldName] = $getArticle->getValue($fieldName);
                                }
                            }
                        }
                    }
                }

                $_SESSION['article_new'] = $article;
                $this->redirect('/articles/new_article/?edit=' . $articleId);
            }
        }
        return;
    }

    //Предватрительный просмотр статьи
    public function preview($id = false)
    {
        $h = umiHierarchy::getInstance();
        $userId = permissionsCollection::getInstance()->getUserId();
        $getArticle = $h->getElement($id);
        if ($getArticle instanceof umiHierarchyElement) {
            $getUserId = $getArticle->getValue('user');
            if (($userId == 2) or ($getUserId == $userId)) {
                $oC = umiObjectsCollection::getInstance();
                $typeArticle = $getArticle->getValue('type');
                $typeArticle = $oC->getObject($typeArticle);
                $typeArticle = is_object($typeArticle) ? array("@id"=>$typeArticle -> getValue("type_id"),"@obj_id" => $typeArticle->getId(), "@name" => $typeArticle->getName(), "@class" => $typeArticle->getValue("class"), "@rp" => $typeArticle->getValue('rp')) : "";

                $result = array(
                    "_id" => $id,
                    '_is_active' => $getArticle->getIsActive() ? "1" : "0",
                    '_type' => $typeArticle
                );
                return $result;
            }
        }
        $this->redirect('/');
        return;
    }

    //Активация статьи
    public function activate($articleId = false){
        //Проверка пользователя
        $hierarchy = umiHierarchy::getInstance();
        $getArticle = $hierarchy -> getElement($articleId);

        if ($getArticle instanceof umiHierarchyElement){
            $oTC = umiObjectTypesCollection::getInstance();
            $getTypesList = $oTC -> getSubTypesList(141);
            if (is_array($getTypesList)){
                if (!in_array($getArticle -> getObjectTypeId(),$getTypesList)) $this->redirect('/');
                $userId = permissionsCollection::getInstance()->getUserId();
                $getUserId = $getArticle->getValue('user') ? $getArticle->getValue('user') : false;
                if (($userId == 2) or (($getUserId !== false) && ($userId == $getUserId))) {
                    $getArticle -> setIsActive(true);
                    $getArticle -> commit();

                    $s = new selector('pages');
                    $s->types('object-type')->name('vote', 'poll');
                    $s->where('base')->equals($articleId);
                    foreach ($s->result() as $poll) clearCachePoll($poll->getId());

                    $this->redirect($hierarchy -> getPathById($articleId));
                }
            }
        }
        return;
    }


    //Новый опрос
    public function create_article()
    {
        if (isset($_SESSION['article_new'])) unset($_SESSION['article_new']);
        $uri = "";
        $uri .= isset($_GET['edit']) ? "&edit=" . $_GET['edit'] : "";
        $uri = trim($uri, "&");
        $this->redirect('/articles/new_article/' . ($uri ? "?" : "") . $uri);
        return;
    }

    //Событие на удаление объекта в админке
    public function onDeleteObject(iUmiEventPoint $oEventPoint)
    {
        if ($oEventPoint->getMode() === "before") {
            $object = $oEventPoint->getRef("object");

            //Обработка лент
            if ($object->getTypeId() == 146) {

                //Удаление фотографий
                $getPhoto = $object->getValue('photo_cover');
                if ($getPhoto) {
                    $filePath = trim($getPhoto->getFilePath(), ".");
                    unlink(CURRENT_WORKING_DIR . $filePath);
                }

                $getPhoto = $object->getValue('photo_profile');
                if ($getPhoto) {
                    $filePath = trim($getPhoto->getFilePath(), ".");
                    unlink(CURRENT_WORKING_DIR . $filePath);
                }

                //Удаление из индекса поиска
                searchModel::unindex_items_object($object->getId());
            }

            //Обработка опросов
            if ($object->getTypeId() == 71) {
                //Удаление фотографий
                for ($index = 0; $index < 4; $index++) {
                    $getPhoto = $object->getValue('img_' . $index);
                    if ($getPhoto) {
                        $filePath = trim($getPhoto->getFilePath(), ".");
                        unlink(CURRENT_WORKING_DIR . $filePath);
                    }
                }

                //Удаление ответов в опросе
                $q = "DELETE FROM polls WHERE obj_id='" . $object->getId() . "'";
                $r = mysql_query($q);

                //Удаление данных счетчика количества просмотров
                $q = "DELETE FROM counter_view_page WHERE obj_id='" . $object->getId() . "'";
                $r = mysql_query($q);

                //Удаление комментариев
                $q = "DELETE FROM comments WHERE obj_id='" . $object->getId() . "'";
                $r = mysql_query($q);
            }

            //Обработка публикаций - статей
            $oTC = umiObjectTypesCollection::getInstance();
            $getTypesList = $oTC -> getSubTypesList(141);
            if (is_array($getTypesList)){
                if (in_array($object->getTypeId(),$getTypesList)){

                    //Удаление фотографий
                    $getType = $oTC -> getType($object->getTypeId());
                    if (is_object($getType)){
                        $getFieldsGroupsList = $getType -> getFieldsGroupsList();
                        foreach($getFieldsGroupsList as $group){
                            if ($group -> getIsVisible()){
                                $getFields = $group -> getFields();
                                foreach($getFields as $field){
                                    if ($field -> getIsVisible()){
                                        if ($field -> getDataType() == "img_file"){
                                            $fieldName = $field -> getName();
                                            $getPhoto = $object->getValue($fieldName);
                                            if ($getPhoto) {
                                                $filePath = trim($getPhoto->getFilePath(), ".");
                                                unlink(CURRENT_WORKING_DIR . $filePath);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            return true;
        };
    }

    //Событие на удаление страницы в админке
    public function onDeleteElement(iUmiEventPoint $oEventPoint)
    {
        if ($oEventPoint->getMode() === "before") {
            $elementId = $oEventPoint->getParam("element_id");
            $hierarchy = umiHierarchy::getInstance();
            $element = $hierarchy->getElement($elementId);

            $typeId = $element->getObjectTypeId();
            $obj_id = $element->getObjectId();
            //Обработка опросов
            if ($typeId == 71) {
                //Удаление фотографий
                for ($index = 0; $index < 4; $index++) {
                    $getPhoto = $element->getValue('img_' . $index);
                    if ($getPhoto) {
                        $filePath = trim($getPhoto->getFilePath(), ".");
                        unlink(CURRENT_WORKING_DIR . $filePath);
                    }
                }

                //Удаление ответов в опросе
                $q = "DELETE FROM polls WHERE obj_id='" . $obj_id . "'";
                $r = mysql_query($q);

                //Удаление данных счетчика количества просмотров
                $q = "DELETE FROM counter_view_page WHERE obj_id='" . $obj_id . "'";
                $r = mysql_query($q);

                //Удаление комментариев
                $q = "DELETE FROM comments WHERE obj_id='" . $obj_id . "'";
                $r = mysql_query($q);
            }

            //Обработка публикаций - статей
            $oTC = umiObjectTypesCollection::getInstance();
            $getTypesList = $oTC -> getSubTypesList(141);
            if (is_array($getTypesList)){
                if (in_array($element->getObjectTypeId(),$getTypesList)){

                    //Удаление фотографий
                    $getType = $oTC -> getType($element->getObjectTypeId());
                    if (is_object($getType)){
                        $getFieldsGroupsList = $getType -> getFieldsGroupsList();
                        foreach($getFieldsGroupsList as $group){
                            if ($group -> getIsVisible()){
                                $getFields = $group -> getFields();
                                foreach($getFields as $field){
                                    if ($field -> getIsVisible()){
                                        if ($field -> getDataType() == "img_file"){
                                            $fieldName = $field -> getName();
                                            $getPhoto = $element->getValue($fieldName);
                                            if ($getPhoto) {
                                                $filePath = trim($getPhoto->getFilePath(), ".");
                                                unlink(CURRENT_WORKING_DIR . $filePath);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }



            return true;
        };
    }

    //Событие на изменение страницы в админке
    public function onChangeElement(iUmiEventPoint $oEventPoint)
    {
        if ($oEventPoint->getMode() === "before") {
            $element = $oEventPoint->getRef("element");
            $typeId = $element->getObjectTypeId();

            //Обработка опросов
            if ($typeId == 71) {

                //Обновление итогового количества голосов
                $votes = array();
                $getVariants = unserialize(html_entity_decode($element -> getValue('variants'),ENT_COMPAT | ENT_HTML401, 'UTF-8'));
                if (is_array($getVariants)) {
                    foreach ($getVariants as $index => $variant) {
                        $q = "SELECT COUNT(*) as total FROM polls WHERE obj_id='" . $element->getObjectId() . "' AND variant=" . $index;
                        $r = mysql_query($q);
                        $data = mysql_fetch_assoc($r);
                        $votes[$index] = isset($data['total']) ? $data['total'] : 0;
                    }
                    $element->setValue("votes", serialize($votes));
                    $element->commit();
                }

                //Обновление кэша
                clearCachePoll($element->getId());
            }

            //Обработка статей
            if ($typeId == 141) {

            }
            return true;
        };
    }

    //Парсинг сайтов
    public function parse($site = "", $data = ""){
        $obj_id = getRequest('obj_id');
        $variant = getRequest('variant');
        $url = getRequest('url');

        //Определение сайта (prom.ua, ...)
        /*$site = '';
        if (strpos($url, "http://prom.ua/") !== false) $site = "prom.ua";
        if (strpos($url, "kinopoisk.ru/film") !== false) $site = "kinopoisk.ru/film";   //Фильмы из kinopoisk*/

        switch($site){
            case "prom.ua":
                $get = file_get_contents($url);
                //$get = file_get_contents(CURRENT_WORKING_DIR."/test.txt");

                $goods = array();
                $get = substr_replace($get,"",0, strpos($get,"b-breadcrumb__current")+21);
                $get = substr_replace($get,"",0, strpos($get,">")+1);
                //$offers = substr($get,0,strpos($get,"</span>"));
                //$offers = preg_replace("/[^0-9]/", '', $offers);

                $get = substr_replace($get,"",0, strpos($get,"b-product-line b-product-line_size_wide js-gallery-container")+62);

                $blocks = explode("qa-product-block", $get);

                if (count($blocks)>1){
                    unset($blocks[0]);
                    foreach($blocks as $block){
                        $block = substr_replace($block, "",0, strpos($block,"<span itemprop=\"price\">"));
                        $price = strtr(trim(strip_tags(substr($block, 0, strpos($block,"</span>")))),array(","=>".", " "=>""));
                        $price = (float) preg_replace("/[^0-9\.]/", '', $price);
                        $block = substr_replace($block, "",0, strpos($block,"b-company-info__opinions-link"));
                        $block = substr_replace($block, "",0, strpos($block,">")+1);
                        $reviews = substr($block,0,strpos($block,"</a>"));
                        $reviews = preg_replace("/[^0-9]/", '', $reviews);
                        $block = substr_replace($block, "",0, strpos($block,"</a>")+4);
                        $likes = substr($block,0,strpos($block,"</span>"));
                        $likes = preg_replace("/[^0-9]/", '', $likes);
                        $goods[] = array(
                            "price"=>$price,
                            "reviews"=>$reviews,
                            "likes"=>$likes
                        );
                    }

                    $minPrice = 10000000;
                    $maxPrice = 0;
                    $tReviews = 0; $tLikes = 0;
                    $numGoods = count($goods);
                    if ($numGoods){
                        foreach($goods as $good){
                            if ($good['price']){
                                if ($good['price']>$maxPrice) $maxPrice = $good['price'];
                                if ($good['price']<$minPrice) $minPrice = $good['price'];
                            }
                            $tReviews += $good['reviews'];
                            $tLikes += $good['likes'];
                        }

                        $oC = umiObjectsCollection::getInstance();
                        $rates = $oC -> getObject(4110);    //Гривна
                        $rateUSD = $oC -> getObject(334);    //USD
                        if (is_object($rates) && is_object($rateUSD)){
                            $rate = $rates -> getValue('rate');
                            $rateUSD = $rateUSD -> getValue('rate');
                            if ($rate && $rateUSD){
                                $q = "SELECT * FROM goods_for_compare WHERE obj_id=".$obj_id." AND variant=".$variant;
                                $r = mysql_query($q);
                                if ($r) {
                                    $num = mysql_num_rows($r);
                                    if ($num) {
                                        $q = "UPDATE goods_for_compare SET date='".time()."',price_min='".round(100 * $minPrice * $rate / $rateUSD)."',price_max='".round(100 * $maxPrice * $rate / $rateUSD)."',reviews_num='".round($tReviews/$numGoods)."',likes='".round($tLikes/$numGoods)."' WHERE obj_id=".$obj_id." AND variant=".$variant;
                                        mysql_query($q);
                                    } else {
                                        $q = "INSERT INTO goods_for_compare (obj_id,url,variant,date,price_min,price_max,reviews_num,likes) VALUES('".$obj_id."','".$url."','".$variant."','".time()."','".round(100 * $minPrice * $rate / $rateUSD)."','".round(100 * $maxPrice * $rate / $rateUSD)."','".round($tReviews/$numGoods)."','".round($tLikes/$numGoods)."')";
                                        mysql_query($q);
                                    }
                                }

                                return;
                            }
                        }
                    }
                }
                break;

            case "kinopoisk":
                if (is_numeric($data)){
                    $url = "http://glas.media/web_proxy/index.php?q=".rawurlencode(base64_encode("kinopoisk.ru/film/".$data."/"));
                    $content = file_get_contents($url);
                    $content = iconv("windows-1251", "utf-8", $content);
                    $content = substr_replace($content, "", 0, strpos($content, "<h1"));
                    $content = substr_replace($content, "", 0, strpos($content, ">")+1);
                    $h1 = substr($content, 0, strpos($content,"</h1"));

                    $content = substr_replace($content, "", 0, strpos($content, "id=\"infoTable\""));
                    $content = substr_replace($content, "", 0, strpos($content, "<table"));
                    $content_list = substr($content, 0, strpos($content, "</table>")+8);
                    $content_list_arr = explode("</tr>", $content_list);
                    $result = array();

                    foreach($content_list_arr as $item){
                        $td = explode("</td>",$item);
                        $result[] = array(trim(strip_tags(isset($td[0]) ? $td[0] : '')), trim(strip_tags(isset($td[1]) ? $td[1] : '')));
                    }

                    $year = ''; $country = ''; $genre = ''; $duration = ''; $description = '';

                    foreach($result as $item){
                        if ($item[0] == 'год') $year = $item[1];
                        if ($item[0] == 'страна') $country = $item[1];
                        if ($item[0] == 'жанр') {
                            $genre = $item[1];
                            $genre = (strpos($genre,"...") !== false) ? substr($genre, 0, strpos($genre,"...")) : $genre;
                            $genre = trim($genre);
                            $genre = trim($genre, ",");
                        }
                        if ($item[0] == 'время') {
                            $duration = $item[1];
                            $duration = substr($duration, 0, strpos($duration,"мин."));
                            $duration = trim($duration);
                        }
                    }
                    $description = substr_replace($content, "", 0, strpos($content, "itemprop=\"description\"")+23);
                    $description = substr($description, 0, strpos($description, "</div>"));
                    $description = trim(strtr($description, array("&nbsp;"=>" ")));

                    $actors = substr_replace($content, "", 0, strpos($content, "itemprop=\"actors\"")+18);
                    $actors = substr($actors, 0, strpos($actors, "..."));
                    $actors = explode("</li>", $actors);
                    foreach($actors as $i=>$actor){
                        $q = substr_replace($actor, "", 0, strpos($actor, "q=")+2);
                        $q = substr($q,0,strpos($q,"\""));
                        $getA = base64_decode(rawurldecode($q));
                        $id = substr_replace($getA, "", 0, strpos($getA, "/name/")+6);
                        $id = trim(substr($id, 0, strpos($id, "/")));
                        $item = trim(strip_tags($actor));
                        if ($item) $actors[$i] = array($id,$item); else unset($actors[$i]);
                    }
                    $img = "http://www.kinopoisk.ru/images/film_big/".$data.".jpg";

                    return array(
                        "h1"=>$h1,
                        "year"=>$year,
                        "country"=>$country,
                        "duration"=>$duration,
                        "description"=>$description,
                        "img"=>$img,
                        "actors" => $actors,
                        "genre" => $genre
                    );
                }
                break;
        }
        return;
    }

    //Удаление строки из таблицы БД (для таблиц с данными парсинга)
    public function delParseFromMysql(){
        $obj_id = getRequest('obj_id');
        $variant = getRequest('variant');
        $table_name = getRequest('table_name');
        $q = "DELETE FROM ".$table_name." WHERE obj_id='".$obj_id."' AND variant='".$variant."'";
        $r = mysql_query($q);
        return;
    }

    //Автозаполнение инфоблока для опроса с заданным типом в админке
    public function autocomplete_block(){
        $page_id = (int) getRequest('page_id');
        $block_id = getRequest('block_id');
        $type_id = (int) getRequest('type_id');
        $block_id = strtr($block_id, array("block_"=>"", "_type"=>""));

        $h = umiHierarchy::getInstance();
        $old_mode = umiObjectProperty::$IGNORE_FILTER_INPUT_STRING;		//Откючение html сущн.
        umiObjectProperty::$IGNORE_FILTER_INPUT_STRING = true;

        $getPage = $h -> getElement($page_id);
        if($getPage instanceof umiHierarchyElement){
            $varinats = unserialize(html_entity_decode($getPage -> getValue('variants'),ENT_COMPAT | ENT_HTML401, 'UTF-8'));

            $varinatsLabels = $varinats;
            if ($varinats){
                $obj_id = $getPage -> getObjectId();
                switch($type_id){
                    //Сравнительный анализ товаров - ассортимент
                    //Сравнительный анализ товаров - обсуждения
                    //Сравнительный анализ товаров - лайки
                    case "4111":
                    case "4112":
                    case "4113":
                        $q = "SELECT * FROM goods_for_compare WHERE obj_id=".$obj_id;
                        $r = mysql_query($q);
                        $exist = array();
                        while ($row = mysql_fetch_array($r)) {
                            switch($type_id){
                                case "4111":
                                    $varinats[$row['variant']] = round(($row['price_min'] + $row['price_max']) / 2);
                                    break;
                                case "4112":
                                    $varinats[$row['variant']] = $row['reviews_num'];
                                    break;
                                case "4113":
                                    //Исключение для диаграммы рекомендаций (лайков), если кол. комментариев (отзывов) меньше 10
                                    if ($row['reviews_num'] >= 10)
                                        $varinats[$row['variant']] = $row['likes'];
                                    else continue(2);
                                    break;
                            }
                            $exist[$row['variant']] = '';
                        }
                        $total = 0;
                        foreach ($varinats as $id=>$varinat){
                            if (!isset($exist[$id])) {
                                unset($varinats[$id]);
                                unset($varinatsLabels[$id]);
                            }
                            $total += $varinat;
                        }

                        $totalResult = 0;
                        foreach ($varinats as $id=>$varinat){
                            //Исключение из списка элементов с маленьким коэффициентом (< 0.5 %), при округл. которого выведится "0"
                            if (($varinat / $total) < 0.005){
                                unset($varinats[$id]);
                                unset($varinatsLabels[$id]);
                                continue;
                            }
                            $totalResult += $varinat;
                        }
                        foreach ($varinats as $id=>$varinat){
                            $varinats[$id] = round(100*$varinat / $totalResult);
                        }

                        $content = '<ul>';
                        foreach($varinatsLabels as $id => $label){
                            $content .= '<li class="mark_color mark_color_'.$id.'">'.$label.'</li>';
                        }
                        $content .= '</ul>';

                        $getPage -> setValue("block_".$block_id."_content", $content);

                        $vote = cmsController::getInstance()->getModule("vote");

                        $imageName = $vote->pieChart($varinats);
                        $img = createImage(CURRENT_WORKING_DIR.$imageName, $page_id."_block_".$block_id, 560,false,95);

                        if ($img){
                            $getCurrentImg = $getPage -> getValue("block_".$block_id."_img");
                            $getCurrentImg = is_object($getCurrentImg) ? trim($getCurrentImg -> getFilePath(),".") : false;
                            if ($getCurrentImg !== $img) unlink(CURRENT_WORKING_DIR.$getCurrentImg);

                            $getPage -> setValue("block_".$block_id."_img", ".".$img);
                        }
                        $getPage -> commit();
                        break;
                }
            }
        }
        return;
    }

    //Предпросмотр изображения в админке
    public function admin_preview_image($pageId='', $fieldName=''){
        $h = umiHierarchy::getInstance();
        $getPage = $h -> getElement($pageId);
        if ($getPage instanceof umiHierarchyElement){
            $img = trim($getPage -> getValue($fieldName), ".");
            return $img."?".time();
        }
        return;
    }

    //Вывод баннера
    public function banner($bannerId = ''){
        $oC = umiObjectsCollection::getInstance();
        $getObject = $oC -> getObject($bannerId);
        $banners = cookies('banners','');
        $banners = $banners ? unserialize($banners) : false;

        if (is_object($getObject)){
            $content = $getObject -> getValue('content');
            $contentAdd = $getObject -> getValue('content_add');
            $result = $content ? $content : $contentAdd;
            $max_views = $getObject -> getValue('max_views');
            $enabled = true;
            if (is_array($banners))
                if (isset($banners[$bannerId]))
                    if (is_numeric($banners[$bannerId]))
                        if ($max_views)
                            if ($banners[$bannerId] >= $max_views) $enabled = false;
            if ($enabled) {
                $banners[$bannerId] = isset($banners[$bannerId]) ? ($banners[$bannerId] + 1) : 1;
                cookies('banners',serialize($banners));
                return $result;
            }
        }
        return;
    }

    //Вывод полулярных категорий в виде коллажа изображений
    public function getListPopularCategories($saveCache = false){
        if (!$saveCache && file_exists(CURRENT_WORKING_DIR . "/files/cache/hierarchy/getListPopularCategories.arr")){
            $getFile = file_get_contents(CURRENT_WORKING_DIR . "/files/cache/hierarchy/getListPopularCategories.arr");
            if ($getFile){
                $result = unserialize($getFile);
                if (is_array($result))
                    return $result;
            }
        }
        $result = array();
        $s = new selector('pages');
        $s->types('object-type')->id(133);
        $s->where('hierarchy')->page(7)->childs(1);
        $s->order('popularity')->desc();
        foreach ($s->result() as $item) {
            $result[] = array(
                "@name" => $item ->getName(),
                "@link" => $item -> link,
                "img" => $item -> getValue('header_pic')
            );
        }
        file_put_contents(CURRENT_WORKING_DIR . "/files/cache/hierarchy/getListPopularCategories.arr", serialize(array("nodes:catalog"=>$result)));
        return array("nodes:catalog"=>$result);
    }

    //Сортировака в cookie
    public function sort_cookie(){
        $sort = isset($_POST['sort']) ? $_POST['sort'] : false;
        if ($sort) {
            setcookie('sort', $sort, strtotime('+365 days'));
        }
        else {
            $sort = isset($_COOKIE['sort']) ? $_COOKIE['sort'] : "";
            $sort = $sort ? $sort : "";
        }
        $_REQUEST['sort'] = $sort;
        return $sort;
    }

    //Сбросить кэш js и css у клиентов
    public function clearUserCache(){
        $regedit = regedit::getInstance();
        $regedit->setVar("//modules/autoupdate/system_build", time());
        $this -> redirect('/admin/events/');
        return;
    }

    //Пошаговое руководство
    public function tooltips(){
        $info = cookies('info','');
        $info = $info ? unserialize($info) : array();
        $tooltips = isset($info['tooltips']) ? $info['tooltips'] : array();

        $result = array();

        $oC = umiObjectsCollection::getInstance();
        $getSettings = $oC->getObject(3934);
        if (is_object($getSettings)) {
            for($i=1; $i<100; $i++){
                $tooltip = $getSettings -> getValue("tooltip_".$i."_content");
                if ($tooltip){
                    $pos = $getSettings -> getValue("tooltip_".$i."_position");
                    if (!isset($tooltips[$i])) $result[] = array("@id"=>$i, "@content"=>$tooltip, "@pos"=>$pos);
                }
            }
        }
        $ids = getRequest('ids');
        if ($ids) {
            $ids = trim($ids, ",");
            $ids = explode(",", $ids);

            foreach ($ids as $id){
                $tooltips[$id] = true;
            }

            $info['tooltips'] = $tooltips;
            cookies('info',serialize($info));
        }
        return array("items"=>array("nodes:item"=>$result));
    }

    
}
?>