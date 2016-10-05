<?php

require_once CURRENT_WORKING_DIR."/files/scripts-parsing/default.php";

class vote_custom extends def_module {

    //Ленты =======================================================================================
    //Индексация всех лент для поиска
    public function indexAllFeeds(){
        $s = new selector('objects');
        $s->types('object-type')->name('feeds', 'feed');
        foreach($s->result() as $feed){
            searchModel::getInstance()->index_object_item($feed->getId());
        }
        $this->redirect('/admin/search/index_control/');
    }


    //Список лент
    public function getListFeeds($mode = 'all', $sort = 'new'){
        /*
         *  $mode - режим вывода лент:
         *  'user' - ленты текущего пользователя;
         *  'descr' - подписки на ленты текущего пользователя;
         *  'all' - все ленты;
         */

        $userId = permissionsCollection::getInstance() -> getUserId();

        $oC = umiObjectsCollection::getInstance();
        $getSettings = $oC -> getObject(3934);
        $getUser = $oC -> getObject($userId);

        $p = getRequest('p') ? getRequest('p') : 0;

        $per_page = 20;
        if(is_object($getSettings)){
            switch($mode){
                case "all":
                    $per_page = $getSettings -> getValue('feed_all_per_page');
                    break;
                case "user":
                    $per_page = $getSettings -> getValue('cabinet_feeds_per_page');
                    break;
                case "subscribe":
                    $per_page = $getSettings -> getValue('cabinet_feeds_per_page');
                    break;
                default:
                    $per_page = $getSettings -> getValue('cabinet_feeds_per_page');
                    break;
            }
        }

        $getSort = getRequest('sort');
        $getSort = $getSort ? $getSort : $sort;
        switch($getSort){
            case "new":
                $sort = "date";
                $desc = true;
                break;
            case "old":
                $sort = "date";
                $desc = false;
                break;
            case "popularity":
                $sort = "popularity";
                $desc = true;
                break;
            case "fit":
                return $this->getListFitFeeds($per_page);
                break;
        }

        $s = new selector('objects');
        $s->types('object-type')->name('feeds', 'feed');

        switch($mode){
            case "all":
                $s->where('is_active')->equals(true);
                break;
            case "user":
                $s->where('user')->equals($userId);
                break;
            case "subscribe":
                $feeds = $getUser -> getValue('subscribe');
                if (!$feeds) $feeds = array();
                $s->where('id')->equals($feeds);
                $s->where('is_active')->equals(true);
                break;
            default:
                return;
                break;
        }

        $s->option('return')->value('id');
        if ($desc) $s->order($sort)->desc();
        else $s->order($sort);
        $s->limit($p*$per_page, $per_page);

        $total = $s->length;
        $result = array();
        foreach($s->result() as $feed){
            $result[] = array("@id" => $feed['id']);
        }

        /*return array("feeds"=>array("nodes:feed"=>$result), "total"=>$total, "per_page"=>$per_page, "current_page"=>$p,
            "url_sort_new"=>insertUrlParam("sort","","new"), "url_sort_old"=>insertUrlParam("sort","","old"),
            "url_sort_popularity"=>insertUrlParam("sort","","popularity")
        );*/
        return array("feeds"=>array("nodes:feed"=>$result), "total"=>$total, "per_page"=>$per_page, "current_page"=>$p);
    }

    //Список наиболее подходящих лент для пользователя
    public function getListFitFeeds($per_page = 20){
        $oC = umiObjectsCollection::getInstance();
        $userId = permissionsCollection::getInstance() -> getUserId();
        $getUser = $oC -> getObject($userId);
        $subsribe = $getUser -> getValue('subscribe');

        $interests = $getUser -> getValue('interests');
        foreach($interests as $index=>$interest) $interests[$index] = $interest -> getId();

        $identification = isset($_SESSION['identification']) ? $_SESSION['identification'] : identification();
        if ($userId == 337){
            if (isset($identification['info']['interests']))
                if (count($identification['info']['interests']))
                    $interests = $identification['info']['interests'];
        }

        //Географический таргетинг
        $geo = $_SESSION['geo'];
        $country_iso = $geo['country_iso'];
        $region = $geo['region'];
        $qTC = " AND o.obj_id NOT IN (SELECT obj_id FROM cms3_object_content WHERE field_id=513 AND varchar_val!='".$country_iso."' AND varchar_val IS NOT NULL)";
        $qTR = " AND o.obj_id NOT IN (SELECT obj_id FROM cms3_object_content WHERE field_id=514 AND int_val!='".$region."' AND int_val IS NOT NULL)";

        //Если опросы не входят в возрастное ограничение
        $age = $getUser -> getValue('birthday');
        $age = is_object($age) ? $age -> getDateTimeStamp() : false;
        $age = $age ? (((time() - $age) > 567648000) ? true : false) : false;
        $qEP = '';
        if (!$age) $qEP = " AND o.obj_id NOT IN (SELECT obj_id FROM cms3_object_content WHERE field_id=516 AND int_val=1)";

        //Если лента неактивна
        $qNA = " AND B.obj_id IN (SELECT obj_id FROM cms3_object_content WHERE field_id=550 AND int_val='1')";

        $q = "SELECT A.id, B.int_val, B.tree_val, B.field_id FROM cms3_objects A JOIN cms3_object_content B ON A.id = B.obj_id WHERE A.type_id=146 AND (B.field_id=567 OR B.field_id=554)".$qNA;
        $r = mysql_query($q);

        $result3 = array();
        while($row = mysql_fetch_array($r)){
            //Если нет опросов (учитывается геотаргетинг и возрастное ограничение)
            //$qn = "SELECT o.obj_id FROM cms3_object_content o JOIN cms3_hierarchy h ON o.obj_id=h.obj_id WHERE o.rel_val=".$row['id']." AND o.field_id=549 AND h.is_active=1".$qEP.$qTC.$qTR;
            //$rn = mysql_query($qn);
            //if (!mysql_num_rows($rn)) continue;

            switch($row['field_id']){
                case 554:
                    if (!isset($result3[$row['id']]['c'])) $result3[$row['id']]['c'] = array();
                    if ($row['tree_val']) $result3[$row['id']]['c'][] = $row['tree_val'];
                    break;
                case 567:
                    $result3[$row['id']]['p'] = $row['int_val'] ? $row['int_val'] : 0;
                    break;
            }
        }

        //Первые ленты - подписки пользователя
        $result1 = array();
        /*foreach($subsribe as $s)
            if (isset($result3[$s])) {
                $result1[$s] = $result3[$s];
                unset($result3[$s]);
            }*/

        //Следующие ленты - по интересам пользователя
        $result2 = array();
        foreach($interests as $index1=>$interest){
            foreach($result3 as $index2=>$item){
                if (isset($item['c'])){
                    if (is_array($item['c'])){
                        $search = array_search($interest, $item['c']);
                        if ($search !== false){
                            $result2[$index2] = (1/($index1 + 1)) * (1/($index2 + 1));  //В зависимости от позиций в массиве
                        }
                    }
                }
            }
        }
        arsort($result2, true);

        foreach($result2 as $index => $item){
            $result2[$index] = $result3[$index];
            unset($result3[$index]);
        }

        //Оставшиеся ленты в $result3

        //Сортировка по популярности
        /*uasort($result1, function($left, $right) {
            return -strnatcmp($left['p'], $right['p']);
        });*/
        /*uasort($result2, function($left, $right) {
            return -strnatcmp($left['p'], $right['p']);
        });*/
        uasort($result3, function($left, $right) {
            return -strnatcmp($left['p'], $right['p']);
        });
        $result = $result1 + $result2 + $result3;

        unset($result1);
        unset($result2);
        unset($result3);

        $p = getRequest('p') ? getRequest('p') : 0;

        $total = count($result);
        $result = array_slice($result,$p*$per_page, $per_page, true);
        $out = array();
        foreach($result as $id=>$vote){
            $out[] = array(
                "@id" => $id,
            );
        }
        return array("feeds"=>array("nodes:feed"=>$out), "total"=>$total, "per_page"=>$per_page, "current_page"=>$p);
    }

    //Список лент "Все ленты" (для страницы)
    public function getlist(){
        return;
    }

    //Список опросов ленты
    public function listPollsOfFeeds($feedId = false, $setPerPage = false, $setSort = false, $excludeVotes = ''){
        if (!is_numeric($feedId)) return;

        /*  Возможные варианты сортировок
            fit - наиболее подходящий для текущего пользователя;
            new - сначала новы;
            old - сначала старые;
            popularity - популярные;
            auto - то, что указано в get параметре 'sort';
        */
        if ($setSort == "auto") $setSort = getRequest('sort');

        switch($setSort){
            case "fit":
                $sort = 569;
                $desc = true;
                break;
            case "new":
                $sort = 525;
                $desc = true;
                break;
            case "old":
                $sort = 525;
                $desc = false;
                break;
            case "popularity":
                $sort = 569;
                $desc = true;
                break;

            default:
                $sort = 525;
                $desc = true;
                break;
        }

        $search_string = trim(getRequest('search_string')) ? trim(getRequest('search_string')) : "";

        $oC = umiObjectsCollection::getInstance();
        $h = umiHierarchy::getInstance();
        $userId = permissionsCollection::getInstance() -> getUserId();
        $getUser = $oC -> getObject($userId);

        $identification = isset($_SESSION['identification']) ? $_SESSION['identification'] : identification();

        $unactive = (getRequest("unactive") !== null) ? true : false;

        if ($setSort == 'fit'){
            $interests = $getUser -> getValue('interests');
            foreach($interests as $index=>$interest) $interests[$index] = $interest -> getId();

            if ($userId == 337){
                if (isset($identification['info']['interests']))
                    if (count($identification['info']['interests']))
                        $interests = $identification['info']['interests'];
            }
        }

        //Определение владельца ленты
        $q = "SELECT rel_val FROM cms3_object_content WHERE obj_id=".$feedId." AND field_id=545";
        $r = mysql_query($q);
        $owner = false;
        if (mysql_num_rows($r)){
            $owner = mysql_fetch_array($r);
            $owner = $owner['rel_val'];
            $owner = ($owner == $userId) ? true : false;
        }

        //Определение типа ленты - обычная или тест
        /*$q = "SELECT int_val FROM cms3_object_content WHERE obj_id=".$feedId." AND field_id=624";
        $r = mysql_query($q);
        $typeTest = false;
        if (mysql_num_rows($r)){
            $typeTest = mysql_fetch_array($r);
            $typeTest = (($typeTest['int_val'] == "1") or ($typeTest['int_val'] == 1)) ? true : false;
        }*/

        //Возрастное ограничение
        $age = $getUser -> getValue('birthday');
        $age = is_object($age) ? $age -> getDateTimeStamp() : false;
        $age = $age ? (((time() - $age) > 567648000) ? true : false) : false;
        $qEP = '';
        if (!$age && !$owner) $qEP = " AND A.obj_id NOT IN (SELECT obj_id FROM cms3_object_content WHERE field_id=516 AND int_val=1)";

        //Географический таргетинг
        $geo = $_SESSION['geo'];

        $country_iso = $geo['country_iso'];
        $region = $geo['region'];
        $qTC = ''; $qTR = '';
        if (!$owner){
            $qTC = " AND A.obj_id NOT IN (SELECT obj_id FROM cms3_object_content WHERE field_id=513 AND varchar_val!='".$country_iso."' AND varchar_val IS NOT NULL)";
            $qTR = " AND A.obj_id NOT IN (SELECT obj_id FROM cms3_object_content WHERE field_id=514 AND int_val!='".$region."' AND int_val IS NOT NULL)";
        }
        $qE = '';
        if ($excludeVotes != ''){
            $qE = explode(",",$excludeVotes);
            $qE = implode(" AND A.obj_id<>",$qE);
            $qE = " AND A.obj_id<>".$qE;
        }
        $qTest = "";
        //$qTest = " AND A.obj_id NOT IN (SELECT obj_id FROM cms3_object_content WHERE field_id=625 AND int_val=1)";
        //if ($typeTest) $qTest = "";

        $p = getRequest('p') ? getRequest('p') : 0;
        $per_page = 20;
        if (($setPerPage !== false) && $setPerPage) $per_page = $setPerPage;

        $q = "SELECT B.id, A.int_val, A.field_id, B.rel FROM cms3_object_content A JOIN cms3_hierarchy B ON A.obj_id=B.obj_id  WHERE A.obj_id IN (SELECT C.obj_id FROM cms3_object_content C INNER JOIN cms3_hierarchy D ON C.obj_id=D.obj_id WHERE C.rel_val=".$feedId.(($owner && $unactive) ? " AND D.is_active=0 " : " AND D.is_active=1 ")." AND D.is_deleted=0) AND (A.field_id=569 OR A.field_id=525)".$qEP.$qTC.$qTR.$qE.$qTest;
        $r = mysql_query($q);

        $result1 = array();
        $result2 = array();
        while($row = mysql_fetch_array($r)) {

            //Определение родителей
            $parent = $row['rel'];
            $parent_query = "   SELECT t1.rel AS lev1, t2.rel as lev2
                                FROM cms3_hierarchy AS t1
                                LEFT JOIN cms3_hierarchy AS t2 ON t2.id = t1.rel
                                WHERE t1.id = ".$parent;
            $parent_result = mysql_query($parent_query);
            $parent_array = mysql_fetch_array($parent_result);

            $inInterests = false;
            if ($setSort == 'fit'){
                if ($parent)
                    if (in_array($parent, $interests)) $inInterests = true;
                if (!$inInterests) if (isset($parent_array[0])) if ($parent_array[0])
                    if (in_array($parent_array[0], $interests)) $inInterests = true;
                if (!$inInterests) if (isset($parent_array[1])) if ($parent_array[1])
                    if (in_array($parent_array[1], $interests)) $inInterests = true;
                if (!$inInterests) if (isset($parent_array[2])) if ($parent_array[2])
                    if (in_array($parent_array[2], $interests)) $inInterests = true;
            }

            if ($inInterests){
                $result1[$row['id']][$row['field_id']] = $row['int_val'];
                if ($sort == $row['field_id']) $result1[$row['id']]['sort'] = $row['int_val'];
            } else {
                $result2[$row['id']][$row['field_id']] = $row['int_val'];
                if ($sort == $row['field_id']) $result2[$row['id']]['sort'] = $row['int_val'];
            }
        }

        if ($sort !== false){
            if ($desc){
                uasort($result1, function($left, $right) {
                    return -strnatcmp($left['sort'], $right['sort']);
                });
                uasort($result2, function($left, $right) {
                    return -strnatcmp($left['sort'], $right['sort']);
                });
            } else {
                uasort($result1, function($left, $right) {
                    return strnatcmp($left['sort'], $right['sort']);
                });
                uasort($result2, function($left, $right) {
                    return strnatcmp($left['sort'], $right['sort']);
                });
            }
        }
        $result = $result1 + $result2;

        //Если строка поиска  ==========================================================================================
        if ($search_string){
            $search = cmsController::getInstance()->getModule("search");
            $resultSearch = $search->s('', $search_string, '','','', true);
            $searchArr = array();
            if (isset($resultSearch['items']['nodes:item']))
                if (is_array($resultSearch['items']['nodes:item']))
                    if (count($resultSearch['items']['nodes:item']))
                        foreach ($resultSearch['items']['nodes:item'] as $id => $item) {
                            if (isset($item['@id']))
                                if ($item['@id']) {
                                    $searchArr[] = $item['@id'];
                                }
                        }
            if (count($searchArr)){
                foreach ($result as $id => $vote){
                    if (!in_array($id, $searchArr)) unset($result[$id]);
                }
            } else $result = array();
        }
        //==============================================================================================================

        $total = count($result);
        $result = array_slice($result,$p*$per_page, $per_page, true);

        $getNames = array();
        foreach($result as $id=>$vote) $getNames[] = $id;
        $getNames = implode(",",$getNames);
        $q = "SELECT h.id, o.name FROM cms3_objects o JOIN cms3_hierarchy h ON o.id=h.obj_id WHERE h.id IN ({$getNames}) ORDER BY FIELD(h.id, {$getNames})";
        $r = mysql_query($q);
        if ($r)
            while($row = mysql_fetch_array($r)){
                $result[$row['id']]['name'] = $row['name'];
                $result[$row['id']]['link'] = $h -> getPathById($row['id']);
            }

        $out = array();
        foreach($result as $id=>$vote){
            $out[] = array(
                "@id" => $id,
                "@link" => $vote['link'],
                "name" => $vote['name']
            );
        }
        return array("items"=>array("nodes:item"=>$out), "unactive"=>($unactive ? "1" : "0"), "total"=>$total, "per_page"=>$per_page, "current_page"=>$p, "last_page" => ((ceil($total / $per_page) == ($p+1)) or !$total) ? "1" : "0");
    }
    
    //Добавление тега в ленту
    public function feed_add_tag(){
        $feedId = getRequest("feed_id") ? getRequest("feed_id") : "";
        $search_string = trim(getRequest("last_search_string")) ? trim(getRequest("last_search_string")) : "";
        if ($feedId && $search_string){
            $oC = umiObjectsCollection::getInstance();

            $userId = permissionsCollection::getInstance() -> getUserId();
            $getFeed = $oC -> getObject($feedId);
            if (is_object($getFeed)){
                $userFeed = $getFeed -> getValue('user');
                if ($userFeed == $userId){
                    $searchList = unserialize($getFeed -> getValue("search_list"));
                    $searchList = is_array($searchList) ? $searchList : array("list"=>array(),"amount"=>array());
                    $searchList = isset($searchList['list']) ? $searchList : array("list"=>array(),"amount"=>array());

                    $wordId = array_search($search_string, $searchList['list']);
                    if ($wordId !== false){
                        $searchList['amount'][$wordId] = isset($searchList['amount'][$wordId]) ? ($searchList['amount'][$wordId] + 1) : 1;
                    } else {
                        $searchList['list'][] = $search_string;
                        $searchList['amount'][count($searchList['list'])-1] = 1;
                    }
                    $getFeed -> setValue("search_list", serialize($searchList));
                    $getFeed -> commit();
                    $this -> redirect(($getFeed -> getValue('url') ? ("/".$getFeed -> getValue('url')."/") : ("/vote/get/".$getFeed->getId()."/"))."?search_string=".$search_string);
                }
            }
        }
        $this -> redirect("/");
    }
    
    //Удаление тега из ленты
    //Добавление тега в ленту
    public function feed_del_tag($feedId = '', $id = ''){
        if (is_numeric($feedId) && is_numeric($id)){
            $oC = umiObjectsCollection::getInstance();

            $userId = permissionsCollection::getInstance() -> getUserId();
            $getFeed = $oC -> getObject($feedId);
            if (is_object($getFeed)){
                $userFeed = $getFeed -> getValue('user');
                if ($userFeed == $userId){
                    $searchList = unserialize($getFeed -> getValue("search_list"));
                    if (isset($searchList['list'][$id]) && isset($searchList['amount'][$id])) {
                        unset($searchList['list'][$id]);
                        unset($searchList['amount'][$id]);
                        $searchList['list'] = array_values($searchList['list']);
                        $searchList['amount'] = array_values($searchList['amount']);
                    }
                    $getFeed -> setValue("search_list", serialize($searchList));
                    $getFeed -> commit();
                    $this -> redirect(($getFeed -> getValue('url') ? ("/".$getFeed -> getValue('url')."/") : ("/vote/get/".$getFeed->getId()."/")));
                }
            }
        }
        $this -> redirect("/");
    }

    //Создание новой ленты
    public function new_feed($test = ''){
        $feed_name = getRequest('feed_name');
        $feed_name = trim(strip_tags($feed_name));
        $feed_name = string_cut($feed_name,255);
        if (!strlen($feed_name)) $this->redirect('/cabinet/feeds/');

        $userId = permissionsCollection::getInstance() -> getUserId();
        if ($userId == 337) $this->redirect('/');

        $oC = umiObjectsCollection::getInstance();
        $newFeedId = $oC -> addObject($feed_name, 146);
        $newFeed = $oC -> getObject($newFeedId);
        if (is_object($newFeed)){
            $newFeed -> setValue('user', $userId);
            $newFeed -> setValue('date', time());
            if ($test) $newFeed -> setValue('test', true);

            $newFeed -> commit();
            $this->redirect('/vote/get/'.$newFeedId);
        }

        $this->redirect('/cabinet/feeds/');

        return;
    }

    //Получить данные ленты
    public function get($feedId = false, $onlyId = true){

        $getFeed = false;
        if (!is_numeric($feedId)){
            $s = new selector('objects');
            $s->types('object-type')->name('feeds', 'feed');
            $s->where('url')->equals($feedId);
            if ($s->length) $getFeed = $s->first;
            else {
                $buffer = outputBuffer::current();
                $buffer->status('404 Not Found');
                return "not_found";
            }
        }

        $search_string = trim(getRequest('search_string')) ? trim(getRequest('search_string')) : "";

        $result = array();
        $oC = umiObjectsCollection::getInstance();

        if (!is_object($getFeed)) $getFeed = $oC -> getObject($feedId);
        if (is_object($getFeed)){
            if ($onlyId) return array("id"=>$getFeed->getId(), "name"=>$getFeed->getName(), "user"=>$getFeed -> getValue('user'));
            $userId = $getFeed -> getValue('user');
            $getUser = $oC -> getObject($userId);
            $user = array();
            if (is_object($getUser)){
                $user = array(
                    "id" => $userId,
                    "photo" => $getUser -> getValue('photo'),
                    "photo_fragment" => $getUser -> getValue('photo_fragment')
                );
            }

            //Получение поисковых запросов ========================================================
            $sortTags = $getFeed -> getValue("sort_tags");
            $sortTags = $sortTags ? $sortTags : 18266; //В алфавтином порядке

            $searchList = unserialize($getFeed -> getValue("search_list"));
            $searchList = isset($searchList['list']) ? $searchList : array("list"=>array(),"amount"=>array());
            $searchListResult = array();

            switch ($sortTags) {
                case 18266:
                    //По алфавиту
                    $searchListResultArr = $searchList['list'];
                    asort($searchListResultArr);
                    foreach($searchListResultArr as $id => $value)
                        $searchListResult[] = array("@id" => $id, "@search"=>$value, "@uri"=>urlencode($value), "@selected"=>(($search_string == $value) ? "1" : "0"));
                    break;

                case 18268:
                    //По порядку добавления
                    $searchListResultArr = $searchList['list'];
                    foreach($searchListResultArr as $id => $value)
                        $searchListResult[] = array("@id" => $id, "@search"=>$value, "@uri"=>urlencode($value), "@selected"=>(($search_string == $value) ? "1" : "0"));
                    break;
            }
            //=====================================================================================

            $result['id'] = $getFeed->getId();
            $result['is_active'] = $getFeed -> getValue('is_active');
            $result['name'] = $getFeed -> getName();
            $result['date'] = $getFeed -> getValue('date');
            $result['photo_cover'] = $getFeed -> getValue('photo_cover');
            $result['photo_profile'] = $getFeed -> getValue('photo_profile');
            $result['description'] = $getFeed -> getValue('description');
            $result['theme'] = $getFeed -> getValue('theme');
            $result['num_subscribers'] = $getFeed -> getValue('num_subscribers') ? $getFeed -> getValue('num_subscribers') : 0;
            $result['user'] = $user;
            $result['category'] = array("nodes:item"=>$getFeed -> getValue('category'));
            $result['is_active'] = $getFeed -> getValue('is_active');
            $result['url'] = $getFeed -> getValue('url');
            $result['link'] = $getFeed -> getValue('url') ? ("/".$getFeed -> getValue('url')."/") : ("/vote/get/".$getFeed->getId()."/");
            $result['test'] = $getFeed -> getValue('test') ? "1" : "0";
            $result['last_search_string'] = $search_string;
            $result['search_list'] = array("nodes:search"=>$searchListResult);
            $result['sort_tags'] = $getFeed -> getValue('sort_tags');
        }

        return $result;
    }

    //Загрузка изображения для ленты
    public function upload_photo_cover_feed($from_url = false){
        $root = CURRENT_WORKING_DIR;
        $oC = umiObjectsCollection::getInstance();
        $crop = getRequest("crop") ? getRequest("crop") : false;
        if ($crop){
            $parameters = getRequest('parameters');
            parse_str($parameters, $output);
            if (isset($output['id']))
                if ($output['id']){
                    $id = $output['id'];
                    $crop = explode("_",$crop);
                    if (count($crop) == 4){
                        $images = $_SESSION['upload_image_feed'];
                        if ($images){
                            $images .= ".jpg";
                            $getFeed = $oC -> getObject($id);
                            if (is_object($getFeed)){
                                $userId = permissionsCollection::getInstance() -> getUserId();
                                $userFeed = $getFeed -> getValue('user');
                                if (($userFeed == $userId) or ($userId == 2)){
                                    $uniqid = uniqid();

                                    $getPhoto = $getFeed->getValue('photo_cover');
                                    if ($getPhoto){
                                        $filePath = trim($getPhoto -> getFilePath(),".");
                                        unlink($root.$filePath);
                                    }

                                    crop($root.$images,$crop[0],$crop[1],$crop[2],$crop[3]);
                                    $newFileName = createImage($root.$images, $uniqid,1450,1450);
                                    $getFeed->setValue('photo_cover', ".".$newFileName);
                                    $getFeed->commit();
                                }
                                unset($_SESSION['upload_image_feed']);
                            }
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
                            $_SESSION['upload_image_feed'] = $newFileName;
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
                        $_SESSION['upload_image_feed'] = $newFileName;
                    unlink($root.$newFileName);
                }
                return;
            }
        }
    }

    //Загрузка изображения для ленты
    public function upload_photo_profile_feed($from_url = false){
        $root = CURRENT_WORKING_DIR;
        $oC = umiObjectsCollection::getInstance();
        $crop = getRequest("crop") ? getRequest("crop") : false;
        if ($crop){
            $parameters = getRequest('parameters');
            parse_str($parameters, $output);
            if (isset($output['id']))
                if ($output['id']){
                    $id = $output['id'];
                    $crop = explode("_",$crop);
                    if (count($crop) == 4){
                        $images = $_SESSION['upload_image_feed'];
                        if ($images){
                            $images .= ".jpg";
                            $getFeed = $oC -> getObject($id);
                            if (is_object($getFeed)){

                                $userId = permissionsCollection::getInstance() -> getUserId();
                                $userFeed = $getFeed -> getValue('user');
                                if (($userFeed == $userId) or ($userId == 2)){
                                    $uniqid = uniqid();

                                    $getPhoto = $getFeed->getValue('photo_profile');
                                    if ($getPhoto){
                                        $filePath = trim($getPhoto -> getFilePath(),".");
                                        unlink($root.$filePath);
                                    }

                                    crop($root.$images,$crop[0],$crop[1],$crop[2],$crop[3]);
                                    $newFileName = createImage($root.$images, $uniqid);
                                    $getFeed->setValue('photo_profile', ".".$newFileName);

                                    $getFeed->commit();
                                }
                                unset($_SESSION['upload_image_feed']);
                            }
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
                            $_SESSION['upload_image_feed'] = $newFileName;
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
                        $_SESSION['upload_image_feed'] = $newFileName;
                    unlink($root.$newFileName);
                }
                return;
            }
        }
    }

    //Удаление фото профиля ленты
    public function remove_photo_profile_feed($id = ''){
        $oC = umiObjectsCollection::getInstance();
        $root = CURRENT_WORKING_DIR;
        $getFeed = $oC -> getObject($id);
        if (is_object($getFeed)){
            $userId = permissionsCollection::getInstance() -> getUserId();
            $userFeed = $getFeed -> getValue('user');
            if (($userFeed == $userId) or ($userId == 2)){
                $getPhoto = $getFeed->getValue('photo_profile');
                if ($getPhoto){
                    $filePath = trim($getPhoto -> getFilePath(),".");
                    unlink($root.$filePath);
                }
                $getFeed->setValue('photo_profile', "");
                $getFeed->commit();
            }
            $url = $getFeed -> getValue('url') ? ("/".$getFeed -> getValue('url')."/") : ("/vote/get/".$getFeed->getId()."/");
            $this->redirect($url);
        }
        $this->redirect("/");
    }

    //Сохранение настроек ленты
    public function settings(){
        $id = getRequest('id');

        $oC = umiObjectsCollection::getInstance();
        $hierarchy = umiHierarchy::getInstance();

        $userId = permissionsCollection::getInstance() -> getUserId();
        $getFeed = $oC -> getObject($id);
        if (is_object($getFeed)){
            $userFeed = $getFeed -> getValue('user');
            $url = getRequest('url');
            $name = getRequest('name');
            if ($this->checkUrlLent($id, true) == "true")
                if (strlen($name)>=5)
                    if ($userFeed == $userId){
                        $name = getRequest('name');
                        $category = getRequest('category');
                        $is_active = getRequest('is_active');
                        $sort_tags = getRequest('sort_tags');

                        $description = getRequest('description');

                        $feed_name = trim(strip_tags($name));
                        $feed_name = string_cut($feed_name,255);
                        if (!strlen($feed_name)) $this->redirect('/cabinet/feeds/');

                        $description = strip_tags($description, "<b></b><strong></strong><i></i><p></p><br></br><div></div>");

                        $old_mode = umiObjectProperty::$IGNORE_FILTER_INPUT_STRING;		//Откючение html сущн.
                        umiObjectProperty::$IGNORE_FILTER_INPUT_STRING = true;

                        if ($feed_name) $getFeed -> setName($feed_name);
                        if ($description) $getFeed -> setValue('description', $description); else $getFeed -> setValue('description', "");
                        if ($category) $getFeed -> setValue('category', array($category)); else $getFeed -> setValue('category', array());
                        if ($is_active == "on") $getFeed -> setValue('is_active', true); else $getFeed -> setValue('is_active', false);
                        $getFeed -> setValue('url', mb_strtolower($url));
                        $getFeed -> setValue('sort_tags', $sort_tags);
                        $getFeed -> commit();

                        //Переиндексация страницы (для поиска)
                        searchModel::getInstance()->index_object_item($id);

                        $this->redirect('/vote/get/'.$id.'/');
                    }
        }

        $this->redirect('/cabinet/feeds/');
    }

    //Подписка на ленту
    public function subscribe($feedId = false){
        $userId = permissionsCollection::getInstance() -> getUserId();
        if ($userId == 337) return;
        $oC = umiObjectsCollection::getInstance();
        $getUser = $oC -> getObject($userId);
        $subscribe =$getUser -> getValue('subscribe');
        $stat = 0;
        if (in_array($feedId, $subscribe)){
            //Отписаться
            $index = array_search($feedId, $subscribe);
            if ($index !== false){
                unset($subscribe[$index]);
                $subscribe = array_values($subscribe);
                $getUser -> setValue("subscribe", $subscribe);
                $getUser -> commit();
            }

        } else {
            //Подписаться (проверка, есть ли такая лента)
            $s = new selector('objects');
            $s->types('object-type')->name('feeds', 'feed');
            $s->where('id')->equals($feedId);
            if ($s->length){
                $subscribe[]=$feedId;
                $getUser -> setValue("subscribe", $subscribe);
                $getUser -> commit();
                $stat = 1;
            }
        }
        //Пересчет количества подписчиков
        $s = new selector('objects');
        $s->types('object-type')->name('users', 'user');
        $s->where('subscribe')->equals($feedId);
        $num_subscribers = $s->length;

        $getFeed = $oC -> getObject($feedId);
        if (is_object($getFeed)){
            $getFeed -> setValue("num_subscribers", $num_subscribers);
            $getFeed -> commit();
        }
        return array("id"=>$feedId, "user-id"=>$userId, "subscribe"=>$stat, "num_subscribers"=>$num_subscribers);
    }

    //Проверка возможности установить короткий адрес ленты
    public function checkUrlLent($feedId = false, $console = false){
        $url = getRequest('url') ? getRequest('url') : "";
        if ($url) $url = mb_substr($url,0,32);

        $result = "true";
        if ($feedId == false) $result = "error";
        if ($url && !preg_match('|^[A-Z0-9_]+$|i',$url)) $result = 'error';
        if ($url && strlen($url)<5) $result = "url_short";
        if (is_numeric($url)) $result = 'error';

        //Проверка на уникальность адреса
        if (($result == 'true') && $url){
            $url = mb_strtolower($url);
            $s = new selector('objects');
            $s->types('object-type')->name('feeds', 'feed');
            $s->where('url')->equals($url);
            if ($s->length){
                $result = "exist";
                $first = $s->first;
                if (is_object($first))
                    if ($first -> getId() == $feedId) $result = "true";
            }
        }

        if ($console) return $result;
        $buffer = outputBuffer::current();
        $buffer->charset('utf-8');
        $buffer->contentType('text/plane');
        $buffer->clear();
        $buffer->push($result);
        $buffer->end();
    }
    //Ленты =======================================================================================





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

    //Получение geo данных
    public function geo($ip=''){
        $root = CURRENT_WORKING_DIR;
        $_SESSION['geo'] = array("city" => 0, "region" => "", "country" => "", "country_iso" => "", "lat" => "", "lon" => "", "iso" => "");

        include_once CURRENT_WORKING_DIR."/templates/iview/classes/modules/content/SxGeo.php";
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

    //Загрузка изображения для опроса
    public function upload_image_poll($from_url = false){
        $root = CURRENT_WORKING_DIR;
        $crop = getRequest("crop") ? getRequest("crop") : false;
        if ($crop){
            $crop = explode("_",$crop);
            if (count($crop) == 4){
                $images = $_SESSION['poll_new_image'];
                if ($images){
                    $images .= ".jpg";
                    crop($root.$images,$crop[0],$crop[1],$crop[2],$crop[3]);
                }
            }
            return;
        } else {
            if ($from_url) {
                //Проверка, действительно ли загруженный файл является изображением
                $url = getRequest('url');

                if ($getImage = checkImageUrl($url)) {
                    $type = '';
                    if (is_array($getImage)) {
                        $url = $getImage[0];
                        $type = $getImage[1];
                        $type = ($type != 'image') ? $type : "";
                    }

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

                    $newFileName = "/files/temp/" . $type . uniqid();

                    //Функция, перемещает файл из временной, в указанную вами папку
                    if (copy($url, $root . $newFileName)) {
                        resize($root . $newFileName, $width, $height, $root . $newFileName . ".jpg");
                        if (file_exists($root . $newFileName . ".jpg")) {
                            $_SESSION['poll_new_image'] = $newFileName;
                        }

                        unlink($root . $newFileName);
                    }
                }
                return;
            } else {
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
                        $_SESSION['poll_new_image'] = $newFileName;
                    }
                    unlink($root . $newFileName);
                }
                return;
            }
        }
    }

    //Вывод опроса по его id
    public function getPoll($id = false, $params = array(), $cache_save=false){
        $hierarchy = umiHierarchy::getInstance();
        $oC = umiObjectsCollection::getInstance();
        $typesCollection = umiObjectTypesCollection::getInstance();

        $identification = isset($_SESSION['identification']) ? $_SESSION['identification'] : identification();
        $user_auth = $identification[0];
        $userId = $identification[1];
        $needAuth = $identification[2];

        $result = false;
        if (file_exists(CURRENT_WORKING_DIR."/files/cache/polls/".$id.".arr"))
            $result = unserialize(file_get_contents(CURRENT_WORKING_DIR."/files/cache/polls/".$id.".arr"));
        $obj_id = isset($result['obj_id']) ? ($result['obj_id'] ? $result['obj_id'] : false) : false;
        if (!$result or $cache_save){
            $getPoll = $hierarchy -> getElement($id);
            $result = array();
            if ($getPoll instanceof umiHierarchyElement){
                if ($getPoll -> getObjectTypeId() != 71) return;
                $obj_id = $getPoll -> getObjectId();
                $result['id'] = $id;
                $result['obj_id'] = $obj_id;
                $result['link'] = $getPoll -> link;
                $result['h1'] = $getPoll -> getValue('h1');
                $result['poll_user'] = $getPoll -> getValue('user');
                $result['is_active'] = $getPoll -> getIsActive() ? "1" : "0";

                $variants = unserialize(html_entity_decode($getPoll -> getValue('variants'),ENT_COMPAT | ENT_HTML401, 'UTF-8'));
                $variants = $variants ? $variants : array();

                $variant_pages = $getPoll -> getValue('variant_page');
                $variant_pages_arr = array();
                foreach($variant_pages as $variant_page){
                    $getPageIdFromObj = current($hierarchy -> getObjectInstances($variant_page['rel']));
                    if ($getPageIdFromObj) {
                        $getPage = $hierarchy -> getElement($getPageIdFromObj);
                        if ($getPage instanceof umiHierarchyElement){
                            $content = $getPage -> getValue('content');
                            $content = strip_tags($content);
                            $contentCut = string_cut($content, 150);
                            $variant_pages_arr[$getPageIdFromObj] = array(
                                "@id" => $getPage -> getId(),
                                "@link" => $getPage -> link,
                                "name" => $getPage -> getName(),
                                "@img" => $getPage -> getValue("img"),
                                "content_cut" => $contentCut
                            );
                        }
                    }
                }

                //Опредеяем максимальное количество голосов опроса ====================================
                $getVotes = unserialize($getPoll -> getValue('votes'));
                $summVote = 0;
                $maxVote = 0;
                if (is_array($getVotes))
                    foreach($getVotes as $vote) {
                        $maxVote = $vote > $maxVote ? $vote : $maxVote;
                        $summVote += $vote;
                    }
                //=====================================================================================

                $totalVotes = 0;
                $maxLength = 1;
                foreach($variants as $index=>$variant){
                    $votes = isset($getVotes[$index]) ? $getVotes[$index] : 0;
                    $totalVotes += $votes;
                    $maxLength = ($votes > $maxLength) ? $votes : $maxLength;
                    $perc_number = round(($summVote > 0) ? (100 * $votes / $summVote) : 0,1);
                    $perc_scale = round(($maxVote > 0) ? (100 * $votes / $maxVote) : 0,1);
                    $variants[$index] = array("@id"=>$index,"@votes"=>$votes, "@perc_number" => $perc_number, "@perc_scale" => $perc_scale, "variant"=>$variant);
                }
                $maxLength = (string) $maxLength;
                $maxLength = strlen($maxLength);

                $result['anons'] = $getPoll -> getValue('anons');
                $result['variants'] = array("@total_votes"=>$totalVotes,"nodes:item"=>$variants, "@max_length"=>$maxLength);
                $result['rating_pages'] = array("nodes:rating"=>$variant_pages_arr);
                $result['multiple'] = array("@morph"=>morphWords($getPoll -> multiple, 'variant'), "node:name"=>$getPoll -> multiple);
                $result['preview'] = $getPoll -> getValue('preview') ? 1 : 0;
                $result['user_reg'] = $getPoll -> getValue('user_reg') ? 1 : 0;
                $result['date'] = $getPoll -> getValue('date');
                $result['content'] = $getPoll -> getValue('content');
                $img_position = unserialize($getPoll -> getValue('img_position'));
                if ($img_position){
                    $images = array();
                    foreach($img_position as $tr){
                        $td_arr = array();
                        foreach($tr as $td){
                            $img = $getPoll -> getValue('img_'.$td['id']);
                            $idVideo = ''; $type = '';
                            if (is_object($img)){
                                $fileNameCheck = end(explode("/", trim($img->getFilePath(),".")));
                                if (strpos($fileNameCheck,"-") == 1){
                                    $type = substr($fileNameCheck, 0, strpos($fileNameCheck,"-"));
                                    switch ($type){
                                        case "y":
                                            $idVideo = substr($fileNameCheck,2,strrpos($fileNameCheck,"-")-2);
                                            break;
                                    }
                                }
                            }
                            $td_arr[] = array("@id"=>$td['id'], "@src"=>$img, '@colspan'=>$td['sizex'], '@rowspan'=>$td['sizey'],"@video_id"=>$idVideo, "@video_type"=>$type);
                        }
                        $images[] = array("nodes:td"=>$td_arr);
                    }
                    $result['images'] = array("nodes:tr"=>$images);
                }

                $getAllParents = $hierarchy -> getAllParents($id);
                $parents = getAllParents($getAllParents, array(7));

                //Определение основания опроса
                $getBase = $getPoll -> getValue('base');
                $getBase = is_array($getBase) ? current($getBase) : false;
                $baseInfo = false;
                if ($getBase instanceof umiHierarchyElement){
                    $getListArticlesTypes = $typesCollection -> getChildClasses(141);

                    if (in_array($getBase -> getObjectTypeId(),$getListArticlesTypes)){

                        $source = array("name"=>$getBase->getValue('source_title'), "url"=>$getBase->getValue('source_url'));
                        $typeArticle = $getBase->getValue('type');
                        $typeArticle = $oC -> getObject($typeArticle);
                        $typeArticle = is_object($typeArticle) ? array("@id"=>$typeArticle -> getId(),"@name"=>$typeArticle -> getName(),"@class"=>$typeArticle -> getValue("class"), "@rp"=>$typeArticle->getValue('rp')) : "";
                        $baseInfo = array("@id"=> $getBase -> getId(),
                            "@id" => $getBase -> getId(),
                            "type" => $typeArticle,
                            "link" => $getBase -> link,
                            "title" => $getBase -> getName(),
                            "content" => $getBase -> getValue('content'),
                            "content_cut" => string_cut(strip_tags($getBase -> getValue('content')), 250),
                            "img" => $getBase -> getValue('img'),
                            "date" => $getBase -> getValue('date'),
                            "source"=>$source,
                            "article_user" => $getBase -> getValue('user')
                        );
                    }
                }
                $result['categories'] = array("nodes:item"=>$parents);

                $feeds = $getPoll -> getValue('feed');
                foreach($feeds as $index=>$feedId){
                    $getFeed = $oC -> getObject($feedId);
                    if (is_object($getFeed)) {
                        $feeds[$index] = array(
                            "@id"=>$feedId,
                            "@link" => $getFeed -> getValue('url') ? ("/".$getFeed -> getValue('url')."/") : ("/vote/get/".$getFeed->getId()."/"),
                            "node:name" => $getFeed -> getName()
                        );
                    }

                }
                $result['feeds'] = array("nodes:item"=>$feeds);
                if ($baseInfo !== false) $result['for_article'] = $baseInfo;

                //Вывод диаграмм и дополнительных данных из инфоблоков
                $infoblocks = array();
                $colorsId = array(); //Для того, чтобы прописать стили маркеров для диаграмм

                for($infoBlockId=1; $infoBlockId<10; $infoBlockId++){
                    $blockType = $getPoll->getValue('block_'.$infoBlockId.'_type');

                    //Получение дополнительных сведений из БД для подстановки в текст
                    $replace = array();
                    switch($blockType){
                        case "4111":    //Сравнительный анализ товаров - ассортимент
                        case "4112":    //Сравнительный анализ товаров - обсуждения
                        case "4113":    //Сравнительный анализ товаров - лайки
                            $q = "SELECT * FROM goods_for_compare WHERE obj_id=".$obj_id;
                            $r = mysql_query($q);
                            $mean_value_date = 0;
                            $num_rows = mysql_num_rows($r);
                            if ($num_rows){
                                while($row = mysql_fetch_array($r)){
                                    $mean_value_date += $row['date'];
                                    $colorsId[$row['variant']] = '';
                                }
                                $mean_value_date = round($mean_value_date / $num_rows);
                                if ($mean_value_date) $replace['%date%'] = date("d.m.Y",$mean_value_date);
                            }


                            break;
                    }

                    $getBlockType = $oC -> getObject($blockType);
                    if ($blockType && is_object($getBlockType)){
                        $content = $getPoll -> getValue('block_'.$infoBlockId.'_content');
                        $content = strtr($content, $replace);
                        $descr = $getBlockType -> getValue('descr');
                        $descr = strtr($descr, $replace);
                        $infoblocks[] = array(
                            '@type' => $blockType,
                            'title' => $getBlockType -> getValue('title'),
                            'description' => $descr,
                            'description_cut' => string_cut(strip_tags($descr),120),
                            'image' => $getPoll -> getValue('block_'.$infoBlockId.'_img'),
                            'content' => $content
                        );
                    }
                }
                if (count($infoblocks)){
                    if (count($colorsId)){
                        $colors = array();
                        foreach($colorsId as $index=>$value){
                            $getColor = getColor($index);
                            $colors[] = array('@id'=>$index, "@color"=>$getColor[0]);
                        }
                    }
                    $result['infoblocks'] = array("nodes:item"=>$infoblocks);
                    if (count($colors)) $result['infoblocks_colors'] = array("nodes:item"=>$colors);
                }
                //Период времени для разрешения повторного голосования
                $time_vote = $getPoll -> getValue('time_vote');
                if ($time_vote) $result['time_vote'] = $time_vote;

                file_put_contents(CURRENT_WORKING_DIR."/files/cache/polls/".$id.".arr",serialize($result));
            } else return;
        }

        $totalVotes = $result['variants']['@total_votes'];
        $result['edit_access'] = ($userId == 2) ? "1" : ((($result['poll_user'] == $userId) && !$totalVotes) ? "1" : "0");

        //Если SV - показывает все голоса
        if ($userId == 2) $result['preview'] = 1;

        $result['user'] = array("@id"=>$userId, "@auth"=>($user_auth ? '1' : '0'));

        $result['user_reg'] = $needAuth ? 1 : (isset($result['user_reg']) ? $result['user_reg'] : 1);

        $time_vote = isset($result['time_vote']) ? ($result['time_vote'] ? $result['time_vote'] : false) : false;

        //Определяем, какие варианты ответов отметил текущий пользователь =====================
        $num_rows = 0;
        if (is_numeric($obj_id)){
            $q = "SELECT * FROM polls WHERE obj_id='".$obj_id."' AND user='".$userId."' AND user_reg='".($user_auth ? '1' : '0')."'";
            $r = mysql_query($q);
            $num_rows = mysql_num_rows($r);
        }
        $votesOfCurrentUser = array();
        $lastDate = 0;
        if ($num_rows)
            while($item = mysql_fetch_array($r)){
                $votesOfCurrentUser[$item['variant']] = '';
                if (isset($item['date'])) if ($item['date']) if ($item['date'] > $lastDate) $lastDate = $item['date'];
            }

        //=====================================================================================
        foreach($result['variants']['nodes:item'] as $index=>$item){
            if (isset($votesOfCurrentUser[$index])) $result['variants']['nodes:item'][$index]['@selected'] = '1';
        }
        $result['params']['type'] = isset($params['type']) ? $params['type'] : "standart";
        $result['params']['view_url'] = isset($params['view_url']) ? $params['view_url'] : "false";

        if ($lastDate && $time_vote){
            $repeat_vote = $lastDate + $time_vote*60*60 - time();
            $repeat_vote = $repeat_vote < 0 ? false : $repeat_vote;
            $result['repeat_vote'] = $repeat_vote ? (trim(showDate(time() - $repeat_vote, ''))) : "0";
        }
        return $result;
    }

    //Голосование
    public function votePoll($data = false){
        $h = umiHierarchy::getInstance();
        $ip = $_SERVER["REMOTE_ADDR"];

        $data = ($data !== false) ? $data : getRequest('data');

        $id = isset($data['id']) ? $data['id'] : "";
        if (!$id) return;
        $variants = isset($data['variant']) ? $data['variant'] : array();
        $params = isset($data['params']) ? $data['params'] : array();

        $getPoll = $h -> getElement($id);
        if ($getPoll instanceof umiHierarchyElement){
            $geo = $_SESSION['geo'];
            $cityId = isset($geo['city']) ? $geo['city'] : null;
            if ($getPoll -> getObjectTypeId() == 71){  //Если тип данных - Опрос

                $identification = isset($_SESSION['identification']) ? $_SESSION['identification'] : identification();
                $user_auth = $identification[0];
                $userId = $identification[1];
                $needAuth = $identification[2];

                $cityId = ($userId == 2) ? 702563 : $cityId;    //Администратор - Лутугино

                //Проверка, кто может голосовать - Любой пользователь или только зарегистрированный
                $user_reg = $getPoll -> getValue('user_reg');
                if ($user_reg or $needAuth) if (!$user_auth) {//Если неавторизован
                    return array("error"=>"not_auth");
                }

                //Проверка, голосовал ли уже пользователь в этом опросе
                $obj_id = $getPoll -> getObjectId();
                if ($obj_id){
                    $q = "SELECT * FROM polls WHERE obj_id='".$obj_id."' AND user='".$userId."' AND user_reg=".($user_auth ? 'true' : 'false');
                    $r = mysql_query($q);

                    //Проверка возможности проголосовать повторно
                    $repeatCheck = false;
                    $time_vote = $getPoll -> getValue('time_vote') ? $getPoll -> getValue('time_vote') : false;
                    if ($time_vote){
                        $lastDate = 0;
                        while($item = mysql_fetch_array($r)){
                            if (isset($item['date'])) if ($item['date']) if ($item['date'] > $lastDate) $lastDate = $item['date'];
                        }
                        if ($lastDate){
                            $repeat_vote = $lastDate + $time_vote*60*60 - time();
                            if ($repeat_vote < 0) $repeatCheck = true;

                        }
                    }

                    $num_rows = mysql_num_rows($r);
                    if (!$num_rows or $repeatCheck){
                        //Сохранение результата опроса
                        $multiple = $getPoll -> getValue('multiple') ? $getPoll -> getValue('multiple') : 1;
                        if ($variants)
                            if (is_array($variants))
                                if (count($variants) <= $multiple){
                                    foreach($variants as $index=>$variant){
                                        $q = "INSERT INTO polls (obj_id,user,user_reg,variant,date,ip,city_id) VALUES('".$obj_id."', '".$userId."', ".($user_auth ? 'true' : 'false').", '".$index."', '".time()."', '".$ip."',".$cityId.")";
                                        mysql_query($q);
                                    }

                                    //Обновление итогового количества голосов
                                    $votes = array();
                                    $getVariants = unserialize(html_entity_decode($getPoll -> getValue('variants'),ENT_COMPAT | ENT_HTML401, 'UTF-8'));
                                    if (is_array($getVariants)){
                                        foreach($getVariants as $index=>$variant){
                                            $q = "SELECT COUNT(*) as total FROM polls WHERE obj_id='".$obj_id."' AND variant=".$index;
                                            $r = mysql_query($q);
                                            $data=mysql_fetch_assoc($r);
                                            $votes[$index] = isset($data['total']) ? $data['total'] : 0;
                                        }
                                        $getPoll -> setValue("votes", serialize($votes));
                                        $getPoll -> commit();
                                    }
                                }
                    }
                }
            }
        }
        return $this->getPoll($id, $params, 1);
    }

    //Предватрительный просмотр опроса
    public function preview($id = false){
        $h = umiHierarchy::getInstance();
        $userId = permissionsCollection::getInstance() -> getUserId();
        $getPoll = $h -> getElement($id);
        if ($getPoll instanceof umiHierarchyElement){
            $getUserId = $getPoll -> getValue('user');
            if (($getUserId == $userId) or ($userId == 2)){
                $result = $this->getPoll($id, array(), false);
                $result['is_active'] = $getPoll -> getIsActive() ? "1" : "0";
                return $result;
            }
        }
        $this->redirect('/');
        return;
    }

    //Новый опрос
    public function create_poll($clearSession = false){
        if (isset($_SESSION['poll_new'])) unset($_SESSION['poll_new']);
        $uri = "";
        $uri .= isset($_GET['fnm']) ? "&fnm=".$_GET['fnm'] : "";
        $uri .= isset($_GET['fn']) ? "&fn=".$_GET['fn'] : "";
        $uri .= isset($_GET['feed']) ? "&feed=".$_GET['feed'] : "";
        $uri .= isset($_GET['edit']) ? "&edit=".$_GET['edit'] : "";
        $uri = trim($uri,"&");
        if (!$clearSession) $this->redirect('/polls/new_poll/'.($uri ? "?" : "").$uri);
        return;
    }

    //Вывод формы для добавления нового опроса
    public function getNewPollForm($change = false, $fastPoll = ''){
        $maxImages = 4; //Максимальное количество изображений
        $poll = array(
            'theme' => '',
            'variants' => array('', ''),
            'images' => '',
            'anons' => '',
            'feeds' => array(),
            'category' => '',
            'subcategory' => '',
            'eighteen_plus' => '',
            'for_lent' => '',
            'user_reg' => '',
            'targeting_regional' => array('enabled'=>'','country'=>'','region'=>'','city'=>''),
            'multiple' => '',
            'preview' => '',
            'time_vote' => '',
            'autocomplete_permisson' => ''
        );

        $h = umiHierarchy::getInstance();
        $oC = umiObjectsCollection::getInstance();
        $userId = permissionsCollection::getInstance() -> getUserId();

        $url = getRequest('url');
        $url = substr_replace($url,"",0,strpos($url,"?")+1);
        parse_str($url, $url);

        $data = getRequest('data');

        $pollForArticle = false;

        //Если установлен get параметр fn - опрос на основе существующей новости/статьи ===========
        if (isset($url['fn']))
            if ($url['fn']){
                $fn = $url['fn'];
                $getArticle = $h->getElement($fn);
                if ($getArticle instanceof umiHierarchyElement){
                    $source = array("name"=>$getArticle->getValue('source_title'), "url"=>$getArticle->getValue('source_url'));

                    $typeArticle = $getArticle->getValue('type');
                    $typeArticle = $oC -> getObject($typeArticle);
                    $typeArticle = is_object($typeArticle) ? array("@id"=>$typeArticle -> getId(),"@name"=>$typeArticle -> getName(),"@class"=>$typeArticle -> getValue("class"), "@rp"=>$typeArticle->getValue('rp')) : "";
                    $date = $getArticle -> getValue('date');
                    $date = is_object($date) ? date("d.m.Y G:i",$date -> timestamp) : "";
                    $pollForArticle = array(
                        "@id" => $getArticle -> getId(),
                        "type" => $typeArticle,
                        "link" => $getArticle -> link,
                        "title" => $getArticle -> getName(),
                        "content" => $getArticle -> getValue('content'),
                        "img" => $getArticle -> getValue('img'),
                        "date" => $date,
                        "source"=>$source,
                        "get"=>"fn"
                    );
                }
            }
        //=========================================================================================

        //Если установлен get параметр fnm - опрос на основе новости из БД ========================
        if (isset($url['fnm']))
            if ($url['fnm']){
                $fnm = $url['fnm'];
                $getArticle = getNewsFromMysql($fnm);
                if (count($getArticle)){
                    $source = $oC -> getObject($getArticle['lent_id']);
                    $source = is_object($source) ? array("name"=>$source->getValue('title'), "url"=>$source->getValue('source_url')) : array();

                    $typeArticle = $getArticle['type'];
                    $typeArticle = $oC -> getObject($typeArticle);
                    $typeArticle = is_object($typeArticle) ? array("@id"=>$typeArticle -> getId(),"@name"=>$typeArticle -> getName(),"@class"=>$typeArticle -> getValue("class"), "@rp"=>$typeArticle->getValue('rp')) : "";
                    $pollForArticle = array(
                        "@id"=> $getArticle['id'],
                        "type" => $typeArticle,
                        "link" => $getArticle['link'],
                        "title" => $getArticle['title'],
                        "content" => $getArticle['content'],
                        "img" => "/files/news_images/".$getArticle['image'].".jpg",
                        "date" => $getArticle['date'],
                        "source"=>$source,
                        "get"=>"fnm"
                    );
                }
            }
        //=========================================================================================

        //Проверка, есть ли get параметр режима редактирования опроса =============================
        $editMode = false;
        $limitedAccess = false;
        if (isset($url['edit'])){
            if ($url['edit']){
                $editMode = $url['edit'];

                //Проверка пользователя
                $getPoll = $h -> getElement($editMode);
                if (!$getPoll instanceof umiHierarchyElement) return;

                $getUserId = $getPoll -> getValue('user') ? $getPoll -> getValue('user') : false;
                if ((($getUserId === false) or ($userId != $getUserId)) && ($userId != 2)) return;

                //Если есть хоть один голос, редактирование ограничено
                $votes = $getPoll -> getValue('votes');
                $votes = $votes ? unserialize($votes) : "";
                $votes = is_array($votes) ? $votes : "";
                $numVotes = 0;
                if (is_array($votes) && count($votes))
                    foreach($votes as $num) $numVotes += $num;
                if ($numVotes && ($userId != 2)) $limitedAccess = true;

            }
        }
        //=========================================================================================

        //Если есть get параметр для предустановленных feed =======================================
        if (($change != "1"))
            if (isset($url['feed'])){
                $getCurrentSession = $_SESSION['poll_new'];
                $getCurrentSession['feeds'] = array($url['feed']);
                $_SESSION['poll_new'] = $getCurrentSession;
            }
        //=========================================================================================

        //Если данные перезаписываются ============================================================
        if ($change == "1"){
            foreach($poll as $index => $value) if (isset($data[$index])) $poll[$index] = is_array($data[$index]) ? $data[$index] : trim($data[$index]);

            //Количество вариантов ответов должно быть не меньше 2-х
            if (!isset($poll['variants'])) $poll['variants'] = array('','');
            if (count($poll['variants']) < 2) $poll['variants'] = array('','');

            //Добавление варианта ответа
            if (isset($data['add_answer'])){
                $id = (int) $data['add_answer'];
                if (is_numeric($id)) $poll['variants'] = array_addItem($poll['variants'], $id);
                unset($data['add_answer']);
            }

            //Сдвиг варианта ответа вверх
            if (isset($data['shift_up'])){
                $id = (int) $data['shift_up'];
                if (is_numeric($id)) $poll['variants'] = array_swap($poll['variants'], $id, 1);
            }

            //Сдвиг варианта ответа вниз
            if (isset($data['shift_down'])){
                $id = (int) $data['shift_down'];
                if (is_numeric($id)) $poll['variants'] = array_swap($poll['variants'], $id);
            }

            //Удаление варианта ответа
            if (isset($data['delete'])){
                $id = (int) $data['delete'];
                if (is_numeric($id)) if (isset($poll['variants'][$id])) unset($poll['variants'][$id]);
                unset($data['delete']);
            }

            //Автозаполнение нового опроса для ленты
            if (isset($data['auto_complete'])){
                $id = (int) $data['auto_complete'];
                if (is_numeric($id)) $poll['variants'] = $this->newPollAutocomplete($id);
                if (count($poll['variants']) < 2) $poll['variants'] = array('','');
                unset($data['auto_complete']);
            }

            //Если установлен параметр "максимальное количество голосов"
            if (isset($data['multiple']))
                if ($data['multiple'] == "on"){
                    $poll['multiple'] = 2;
                    if (isset($data['multiple_max']))
                        if ($data['multiple_max'] >=2)
                            $poll['multiple'] = $data['multiple_max'];
                }

            //Пересохранение данных в сессию, которых нет в форме (например изображение)
            $session = $_SESSION['poll_new'];
            if (isset($session['images'])) $poll['images'] = $session['images'];

            //Изменение параметров изображения
            if (isset($data['images']))
                if (is_array($data['images'])){
                    $deleted = false;
                    foreach($data['images'] as $index=>$image){
                        //Удаление изображения
                        if (isset($image['delete'])) if ($image['delete'] == "on"){
                            if (isset($poll['images'][$index])) unset($poll['images'][$index]);
                            $deleted = true;
                            continue;
                        }

                        $poll['images'][$index]['top'] = isset($image['top']) ? round($image['top']) : 0;
                        $poll['images'][$index]['left'] = isset($image['left']) ? round($image['left']) : 0;
                        $poll['images'][$index]['width'] = isset($image['width']) ? (round($image['width'])) ? round($image['width']) : 100 : 100;
                        $poll['images'][$index]['row'] = isset($image['row']) ? (round($image['row'])) ? round($image['row']) : 1 : 1;
                        $poll['images'][$index]['col'] = isset($image['col']) ? (round($image['col'])) ? round($image['col']) : 1 : 1;
                        $poll['images'][$index]['sizex'] = isset($image['sizex']) ? (round($image['sizex'])) ? round($image['sizex']) : 1 : 1;
                        $poll['images'][$index]['sizey'] = isset($image['sizey']) ? (round($image['sizey'])) ? round($image['sizey']) : 1 : 1;
                    }
                    if ($deleted) {
                        $poll['images'] = array_values($poll['images']);
                        $poll['images'] = $this->optimal_layout($poll['images']);
                    }
                }

            //Если загружено новое изображение
            if (isset($_SESSION['poll_new_image'])){
                if ($_SESSION['poll_new_image']){
                    $images = is_array($poll['images']) ? $poll['images'] : array();
                    if (count($images) < $maxImages){
                        $images[] = array("name"=>$_SESSION['poll_new_image'], "top"=>0,"left"=>0, "width"=>100, "row"=>1, "col"=>1,"sizex"=>1,"sizey"=>1);
                        $poll['images'] = $images;
                    }
                }
                //Когда загружено новое изображение, определяем наиболее подходящую компоновку всех изображений
                $poll['images'] = $this->optimal_layout($poll['images']);

                //Если изображение загружено в форме "Быстрый опрос" -> определяем наиболее подходящую компановку по размеру
                if ($fastPoll)
                    if (count($poll['images']) == 1){
                        $getImage = current($poll['images']);
                        list($fastPollImageW, $fastPollImageH, $fastPollImageT) = getimagesize(CURRENT_WORKING_DIR.$getImage['name'].".jpg");
                        if ($fastPollImageW && $fastPollImageW){
                            $aspectImage = $fastPollImageW/$fastPollImageH;
                            $availAspects = array("0.967"=>6, "1.16"=>5, "1.45"=>4, "1.933" => 3, "2.9"=>2);
                            $result = array();
                            foreach ($availAspects as $aspect => $sizey){
                                $result[] = array(abs($aspectImage - ((float) $aspect)), $sizey);
                            }
                            sort($result);
                            file_put_contents(CURRENT_WORKING_DIR."/test.txt", print_r($poll, true));
                            if (isset($result[0][1]))
                                if ($result[0][1]){
                                    $resultAspect = $result[0][1];
                                    $getImage['sizey'] = $resultAspect;
                                    $poll['images'][0] = $getImage;
                                }
                        }
                    }

                unset($_SESSION['poll_new_image']);
            }

            //Проверка значения в поле "Повторное голосование"
            if (isset($data['time_vote'])){
                $poll['time_vote'] = (int) $data['time_vote'];
                $poll['time_vote'] = ($poll['time_vote'] < 0) ? 0 : ($poll['time_vote'] > 9999 ? 9999 : $poll['time_vote']);
            }

            $_SESSION['poll_new'] = $poll;

        } else {
            if (isset($_SESSION['poll_new'])) $poll = $_SESSION['poll_new'];

            //Количество вариантов ответов должно быть не меньше 2-х
            if (!isset($poll['variants'])) $poll['variants'] = array('','');
            if (count($poll['variants']) < 2) $poll['variants'] = array('','');

            $_SESSION['poll_new'] = $poll;
        }

        //Проверка достаточности данных, чтобы вывести опрос ======================================
        $active = false;
        $variants = $poll['variants'];
        if (is_array($variants)){
            $num = 0;
            foreach($variants as $value) if ($value) $num++;
            if ($num >= 2) {
                if ($poll['theme']) $active = true;
            }
        }
        $poll['active'] = $active;
        //=========================================================================================

        //Фильтр для текста "Анонс" ===============================================================
        $poll['anons'] = string_cut(strip_tags($poll['anons']),4096); 
        //=========================================================================================

        //Преобразование массива $poll в массив для вывода xml ====================================
        $variants = $poll['variants'];
        $variantsXML = array();
        unset($poll['variants']);

        //Случайное количество голосов для нового опроса ============
        $rand = array(); $max = 0;
        foreach($variants as $index=>$value) {
            $rand[$index] = rand(10,10000); if ($rand[$index] > $max) $max = $rand[$index];
        }

        foreach($variants as $index=>$value){
            $variantsXML[] = array(
                '@id' => $index,
                '@voices' => $rand[$index],
                "@percent"=>round(100 * $rand[$index] / $max),
                'node:name' => $value,
            );
        }
        $poll['variants'] = array("nodes:item"=>$variantsXML);
        //=========================================================================================


        //Изображения =============================================================================
        $images = $poll['images'];
        if ($images){
            foreach($images as $index=>$image){
                //Определение типа изображения
                $fileNameCheck = end(explode("/", $image['name']));
                $idVideo = ''; $type = '';
                if (strpos($fileNameCheck,"-") == 1){
                    $type = substr($fileNameCheck, 0, 1);
                    switch ($type){
                        case "y":
                            $idVideo = substr($fileNameCheck,2,strrpos($fileNameCheck,"-")-2);
                            break;
                    }
                }

                $fileTime = filemtime(CURRENT_WORKING_DIR.$image['name'].".jpg");
                $images[$index] = array(
                    '@id'=>$index,
                    '@video_id' => $idVideo,
                    '@video_type' => $type,
                    '@link'=>$image['name'].".jpg?".($fileTime ? $fileTime : uniqid()),
                    '@top'=>$image['top'],
                    '@left'=>$image['left'],
                    '@width'=>$image['width'],
                    '@row'=>$image['row'],
                    '@col'=>$image['col'],
                    '@sizex'=>$image['sizex'],
                    '@sizey'=>$image['sizey'],
                );
            }
            $poll['images'] = array("nodes:item"=>$images);
        }
        //=========================================================================================

        //Если есть get параметр data_id и data-for="feed" в быстром опросе для ленты =============
        if ($fastPoll && (getRequest('data_for') == "feed") && is_numeric(getRequest('data_id'))){
            $poll['feeds'] = array(getRequest('data_id'));
        }
        //=========================================================================================

        //Ленты ==================================================================================
        $feeds = $poll['feeds'];
        $poll['variants_autocomplete_exists'] = "0";
        if ($feeds) {
            if (count($feeds) == 1){
                $newPollAutocomplete = $this->newPollAutocomplete(current($feeds));
                if (count($newPollAutocomplete))
                    $poll['variants_autocomplete_exists'] = "1";
            }
            $poll['feeds'] = array("nodes:item"=>$feeds);
        }
        //=========================================================================================

        if ($pollForArticle !== false) $poll['for_article'] = $pollForArticle;

        if ($editMode !== false) {
            $poll['edit_mode'] = $editMode;
            if ($getPoll instanceof umiHierarchyElement) {
                if (!$getPoll -> getIsActive())
                    $poll['edit_mode_cancel'] = "/vote/preview/".$getPoll -> getId()."/";
                else
                    $poll['edit_mode_cancel'] = $h -> getPathById($editMode);

            }
        }

        $poll['current_user']=umiObjectsCollection::getInstance() -> getObject(permissionsCollection::getInstance() -> getUserId());
        $poll['fast_poll'] = $fastPoll ? "1" : "0";
        $poll['limited_access'] = $limitedAccess ? "1" : "0";
        return $poll;
    }

    //Изменение опроса
    public function editPoll($pollId, $redirect = true, $pattern = false){
        if (!is_numeric($pollId)) $this->redirect('/');
        /*      Array
                (
                    [theme] => Тема опроса
                    [variants] => Array(
                            [0] => Первый вариант
                            [2] => Третий вариант
                            [1] => Второй вариант
                        )
                    [images] => Array(
                            [0] => Array(
                                    [name] => /files/temp/56618b4d6b732
                                    [top] => 0
                                    [left] => -295
                                    [width] => 263
                                    [row] => 1
                                    [col] => 1
                                    [sizex] => 2
                                    [sizey] => 4
                                )
                            [1] => Array(
                                    [name] => /files/temp/56618b5a84e2f
                                    [top] => -95
                                    [left] => -157
                                    [width] => 205
                                    [row] => 1
                                    [col] => 3
                                    [sizex] => 2
                                    [sizey] => 3
                                )

                            [2] => Array(
                                    [name] => /files/temp/56618b61d73cb
                                    [top] => -80
                                    [left] => -100
                                    [width] => 140
                                    [row] => 4
                                    [col] => 3
                                    [sizex] => 2
                                    [sizey] => 1
                                )
                        )
                    [feeds] => Array(
                            [0] => 3931
                        )
                    [category] => 14
                    [subcategory] => 3187
                    [eighteen_plus] => on
                    [user_reg] => 1
                    [targeting_regional] => Array(
                            [enabled] => on
                            [country] => UA
                            [region] => 702657
                        )
                    [multiple] => 4
                    [preview] => on
                )
        */

        $poll = array(
            'theme' => '',
            'variants' => array('', ''),
            'images' => '',
            'anons' => '',
            'feeds' => array(),
            'category' => '',
            'subcategory' => '',
            'eighteen_plus' => '',
            'for_lent' => '',
            'user_reg' => '',
            'targeting_regional' => array('enabled'=>'','country'=>'','region'=>'','city'=>''),
            'multiple' => '',
            'preview' => '',
            'time_vote' => ''
        );

        $h = umiHierarchy::getInstance();
        $getPoll = $h -> getElement($pollId);
        $root = CURRENT_WORKING_DIR;
        if ($getPoll instanceof umiHierarchyElement){
            $userId = permissionsCollection::getInstance() -> getUserId();

            //Проверка пользователя
            $getUserId = $getPoll -> getValue('user') ? $getPoll -> getValue('user') : false;
            if ((($getUserId !== false) && ($userId == $getUserId)) or ($userId == 2) or $pattern){

                if (isset($_SESSION['poll_new'])) unset($_SESSION['poll_new']);

                $variants = unserialize(html_entity_decode($getPoll -> getValue('variants'),ENT_COMPAT | ENT_HTML401, 'UTF-8'));
                $variants = is_array($variants) ? $variants : array('', '');

                $feeds = $getPoll->getValue('feed');
                $feeds = is_array($feeds) ? $feeds : array();
                $targetC = $getPoll -> getValue('target_geographical_country');
                $targetR = $getPoll -> getValue('target_geographical_region');

                $getAllParents = $h -> getAllParents($pollId);

                $images = array();
                $img_position = unserialize($getPoll -> getValue("img_position"));
                if (is_array($img_position)){
                    foreach($img_position as $rowId=>$row){
                        foreach ($row as $colId=>$col) {
                            if (!isset($col['id']) or !isset($col['sizex']) or !isset($col['sizey'])) continue;
                            $getCurrentImage = $getPoll -> getValue('img_'.$col['id']);
                            $getCurrentImage = is_object($getCurrentImage) ? $getCurrentImage->getFilePath() : "";
                            if($getCurrentImage) $images[] = array(
                                "name" => trim(trim($getCurrentImage, "."),".jpg"),
                                "top" => 0,
                                "left" => 0,
                                "width" => 100,
                                "row" => $rowId+1,
                                "col" => $colId +1,
                                "sizex" => $col['sizex'],
                                "sizey" => $col['sizey']

                            );
                        }
                    }
                }

                $poll = array(
                    'theme' => $getPoll -> getName(),
                    'anons' => $getPoll -> getValue('anons'),
                    'variants' => $variants,
                    'images' => $images,
                    'feeds' => $feeds,
                    'category' => isset($getAllParents[2]) ? $getAllParents[2] : "",
                    'subcategory' => isset($getAllParents[3]) ? $getAllParents[3] : "",
                    'eighteen_plus' => $getPoll -> getValue('eighteen_plus') ? "on" : "",
                    'for_lent' => $getPoll -> getValue('for_lent') ? "on" : "",
                    'user_reg' => $getPoll -> getValue('user_reg') ? 1 : 0,
                    'targeting_regional' => array('enabled'=>($targetC or $targetR) ? "on" : "",'country'=>$targetC,'region'=>$targetR,'city'=>''),
                    'multiple' => (($getPoll -> getValue('multiple') == 1) or !$getPoll -> getValue('multiple')) ? "" : $getPoll -> getValue('multiple'),
                    'preview' => $getPoll -> getValue('preview') ? "on" : "",
                    'time_vote' => $getPoll -> getValue('time_vote') ? $getPoll -> getValue('time_vote') : ""
                );

                $_SESSION['poll_new'] = $poll;
                if ($redirect && !$pattern) $this->redirect('/polls/new_poll/?edit='.$pollId);
                if ($redirect && $pattern) $this->redirect('/polls/new_poll/');
                return;
            }
        }
        $this->redirect('/');
        return;
    }


    //Сохранение нового опроса
    public function saveNewPoll($fastPoll = ''){
        $root = CURRENT_WORKING_DIR;
        $oC = umiObjectsCollection::getInstance();
        $h = umiHierarchy::getInstance();
        $userId = permissionsCollection::getInstance() -> getUserId();

        $getPostData = getRequest('data');

        $for_article = $getPostData['for_article'];
        $get = $getPostData['get']; //Параметр, определяющий источник статьи/новости
            /*
             * fn - Существующая новость в админке
             * fnm - Новость из БД (еще не создана страница новости в админке)
             */

        if (isset($getPostData['theme']))
            if ($getPostData['theme'])
                $this->getNewPollForm(true);    //На случай, если какие-то данные в сессии не были сохранены

        //Проверка, выполняется редактирование опроса или создание нового =========================
        $editMode = isset($getPostData['edit']) ? $getPostData['edit'] : false;
        $editMode = $editMode ? $editMode : false;
        $limitedAccess = false;
        if ($editMode !== false){
            //Проверка пользователя
            $getPoll = $h -> getElement($editMode);
            if (!$getPoll instanceof umiHierarchyElement) return array("error"=>"homepage");

            $getUserId = $getPoll -> getValue('user') ? $getPoll -> getValue('user') : false;
            if ((($getUserId === false) or ($userId != $getUserId)) && ($userId != 2)) return array("error"=>"homepage");;

            //Если есть хоть один голос, редактирование ограничено
            $votes = $getPoll -> getValue('votes');
            $votes = $votes ? unserialize($votes) : "";
            $votes = is_array($votes) ? $votes : "";
            $numVotes = 0;
            if (is_array($votes) && count($votes))
                foreach($votes as $num) $numVotes += $num;
            if ($numVotes && ($userId != 2)) $limitedAccess = true;

            clearCachePoll($editMode);
        }
        //=========================================================================================

        $_SESSION['action'] = array("saveNewPoll");
        $data = isset($_SESSION['poll_new']) ? $_SESSION['poll_new'] : false;
        if ($data === false) return array("error"=>"not_enough_data");

        //Проверка достаточночти данных для создания опроса =============================
        //Проверка темы опроса
        $theme = isset($data['theme']) ? ($data['theme'] ? $data['theme'] : false) : false;
        $theme = string_cut($theme,255);
        if (!$theme) return array("error"=>"not_enough_data");

        //Варианты ответов
        $variants = isset($data['variants']) ? $data['variants'] : false;
        foreach($variants as $index => $variant) {
            $variants[$index] = trim($variant);
            if (!$variants[$index]) unset($variants[$index]);
        }

        //Поиск страниц для поля "Влияние опроса на рейтинг следующих страниц" по h1
        $variant_pages = array();
        foreach($variants as $index => $variant) {
            $s = new selector('pages');
            $s->types('hierarchy-type')->name('content', 'page');
            $s->types('object-type')->id(141);
            $s->where('h1')->equals($variant);
            foreach($s-> result() as $item){
                $variant_pages[] = array("int"=>$index, "float"=>1, "rel"=>$item->getObjectId());
                break;
            }
        }

        if (!is_array($variants)) return array("error"=>"not_enough_data"); if (count($variants) < 2) return array("error"=>"not_enough_data");
        if (count($variants) > 100) $variants = array_slice($variants, 0, 100);

        //Если суммарная высота изображений больше 4 блоков
        $images = isset($data['images']) ? $data['images'] : false;
        $images = is_array($images) ? count($images) ? $images : false : false;
        $total_height = 0;
        if ($images !== false){
            foreach($images as $image){
                $itemHeight = (isset($image['row']) ? $image['row'] : 1) + (isset($image['sizey']) ? $image['sizey'] : 1) - 1;
                $total_height = $itemHeight > $total_height ? $itemHeight : $total_height;
            }
        }
        if ($total_height > 6) return array("error"=>"images_incorrect");

        //Если неавторизован
        if (!$fastPoll) if ($userId == 337) return array("error"=>"not_auth");   //Если неавторизован
        //===============================================================================

        if (isset($_SESSION['action'])) {
            $action = $_SESSION['action'];
            if (isset($action[0]))
                if ($action[0] == "saveNewPoll") unset($_SESSION['action']);
        }


        //Фильтр для текста "Анонс" ===============================================================
        $anons = string_cut(strip_tags($data['anons']),4096);
        //=========================================================================================

        //Определение категории
        $parent = isset($data['category']) ? (($data['category'] && is_numeric($data['category'])) ? $data['category'] : false) : false;
        if (isset($data['subcategory']))
            if ($data['subcategory'] && is_numeric($data['subcategory'])) $parent = (int) $data['subcategory'];
        $parent = ($fastPoll && !$parent) ? 3401 : $parent;

        if (!$parent) return array("error"=>"homepage");;

        //Основание опроса
        $base = false;
        if ($for_article && is_numeric($for_article) && ($get == "fn")) $base = $for_article;
        if ($for_article && is_numeric($for_article) && ($get == "fnm")) {
            //Если опрос создается на основе новости из БД (страницы новости еще нет в админке), создается страница новости
            $base = $this->addArticleFromNews($for_article, $parent);
        }

        //Определение принадлежности к лентам
        $feeds = array();
        if (isset($data['feeds']))
            if (is_array($data['feeds']))
                foreach($data['feeds'] as $feedId){
                    $getFeed = $oC -> getObject($feedId);
                    if (is_object($getFeed)){
                        //$getUserFeed = $getFeed -> getValue('user');
                        //if ($getUserFeed == $userId) {
                            $feeds[] = $feedId;

                            //Определение тематики ленты (если опрос добавляется в ленту, то автоматически определяется)
                            //ее тематика в соответствии с тематиками опросов этой ленты ===============================
                            $s = new selector('pages');
                            $s->types('object-type')->name('vote', 'poll');
                            $s->where('feed')->equals($feedId);
                            $getParents = array();
                            foreach($s->result() as $vote){
                                $getAllParents = $h -> getAllParents($vote->getId());
                                if (is_array($getAllParents))
                                    if (count($getAllParents)){
                                        foreach($getAllParents as $parentVote){
                                            if (($parentVote == 0) or ($parentVote == 7)) continue;
                                            if (isset($getParents[$parentVote])) $getParents[$parentVote]++; else $getParents[$parentVote] = 1;
                                        }
                                    }
                            }
                            arsort($getParents, true);
                            $getParents = array_keys($getParents);
                            if (is_array($getParents)) if (count($getParents)) $getFeed -> setValue("category",$getParents);
                            //==========================================================================================
                        //}
                    }
                }

        //Возрастное ограничение
        $eighteen_plus = isset($data['eighteen_plus']) ? (($data['eighteen_plus'] == "on") ? true : false) : false;

        //Отображать только в ленте
        $for_lent = isset($data['for_lent']) ? (($data['for_lent'] == "on") ? true : false) : false;


        //Тип опроса - открытый, анонимный
        //$type_poll = isset($data['type']) ? (($data['type'] == "hidden") ? true : false) : false;

        //Кто может голосовать - false - все пользователи, true - только зарегистрированные
        $user_reg = isset($data['user_reg']) ? (($data['user_reg'] == "1") ? true : false) : false;

        //Показывать результат до голосования или нет
        $preview = isset($data['preview']) ? (($data['preview'] == "on") ? true : false) : false;

        //Множественный выбор
        $multiple = isset($data['multiple']) ? $data['multiple'] : false;
        if (!$multiple) $multiple = 1; else {
            $multiple = (is_numeric($data['multiple']) && ((int) $data['multiple'] >= 2)) ? (int) $data['multiple'] : 1;
        }
        if (!$multiple) $multiple = 1;

        //Повторное голосование
        $time_vote = isset($data['time_vote']) ? $data['time_vote'] : false;
        if (!$time_vote) $time_vote = 0; else {
            $time_vote = (is_numeric($data['time_vote']) && ((int) $data['time_vote'] >= 0) && ((int) $data['time_vote'] <= 9999)) ? (int) $data['time_vote'] : 0;
        }
        if (!$time_vote) $time_vote = 0;

        //Региональный таргетинг
        $country = false; $region = false; $city = false;
        if (isset($data['targeting_regional']['enabled']))
            if ($data['targeting_regional']['enabled'] == "on"){
                $country = isset($data['targeting_regional']['country']) ? $data['targeting_regional']['country'] : false;
                $region = isset($data['targeting_regional']['region']) ? $data['targeting_regional']['region'] : false;
            }

        if ($editMode !== false){
            $pollId = $editMode;
        }   else {
            $pollId = $h -> addElement($parent, 30, $theme, '', 71);
        }

        $getPoll = $h -> getElement($pollId, true);
        if (!$getPoll instanceof umiHierarchyElement) return array("error"=>"homepage");;
        $getPoll -> setIsActive(false);
        $getPoll -> setAltName($pollId);
        $getPoll -> setValue('eighteen_plus', $eighteen_plus);
        $getPoll -> setValue('for_lent', $for_lent);
        $getPoll -> setValue('user_reg', $user_reg);
        $getPoll -> setValue('preview', $preview);
        $getPoll -> setValue('multiple', $multiple);
        $getPoll -> setValue('feed', $feeds);
        $getPoll -> setValue('time_vote', $time_vote);
        $getPoll -> setValue('variant_page', $variant_pages);
        if (!$limitedAccess){
            $getPoll -> setName($theme);
            $getPoll -> setValue('title', $theme);
            $getPoll -> setValue('h1', $theme);
            $getPoll -> setValue('anons', $anons);
            $getPoll -> setValue('variants', serialize($variants));
        }
        if ($editMode !== false) {} else {
            $getPoll -> setValue('date', time());
        }

        if (is_numeric($base)) $getPoll -> setValue('base', array($base));

        permissionsCollection::getInstance()->setDefaultPermissions($pollId);

        //Обработка и сохранение изображения
        if (!$limitedAccess){
            //Если в опросе уже есть фото, то они удаляются (если выполняется редактирование опроса)
            $imagesExists = array();
            for($index=0; $index<4; $index++){
                $getPhoto = $getPoll->getValue('img_'.$index);
                if ($getPhoto){
                    $filePath = trim($getPhoto -> getFilePath(),".");
                    $imagesExists[] = $filePath;
                }
            }
            if ($images !== false){
                $t = md5(date('Ymd',time()))."/";
                $old_umask = umask(0);
                if (!file_exists($root."/images/data/".$t)) mkdir($root."/images/data/".$t, 0777);
                umask($old_umask);

                $positions = array();
                for($index = 0; $index<$total_height; $index++) $positions[] =array('','','','');

                foreach($images as $index=>$image){
                    $filename = $image['name'].".jpg";

                    $typeImg = '';

                    //Если ссылка на изображение является видео, т.е. есть префикс 'y' или ... (1-й символ == '-')
                    $fileNameCheck = end(explode("/", $filename));
                    if (strpos($fileNameCheck,"-") == 1){
                        $typeImg = substr($fileNameCheck,0,strrpos($fileNameCheck,"-"))."-";
                    }

                    $imageUrl = "/images/data/".$t.$typeImg.$pollId."_".$index;
                    if(copy($root.$filename, $root.$imageUrl."_.jpg")){
                        unlink($root.$filename);

                        list($w_i, $h_i, $type) = getimagesize($root.$imageUrl."_.jpg");

                        $width = 100 * $w_i / (isset($image['width']) ? $image['width'] : 1);
                        $scale = (isset($image['sizex']) ? $image['sizex'] : 1) * 145 / $width;
                        $height = 100 * $width * $image['sizey'] / (145 * $image['sizex']);
                        $left = abs(isset($image['left']) ? $image['left'] : 0) / $scale;
                        $top = abs(isset($image['top']) ? $image['top'] : 0) / $scale;
                        $positions[$image['row']-1][$image['col']-1] = array("id"=>$index, "sizex"=>$image['sizex'],"sizey"=>$image['sizey']);

                        crop($root.$imageUrl."_.jpg",$left,$top,$width,$height);

                        if( 1024<$width || 1024<$height ){
                            $ratio = min(1024/$width,1024/$height);
                            $width=floor($width*$ratio);
                            $height=floor($height*$ratio);
                            resize($root.$imageUrl."_.jpg",$width, $height,$root.$imageUrl."_.jpg");
                        }
                        copy($root.$imageUrl."_.jpg", $root.$imageUrl.".jpg");
                        unlink($root.$imageUrl."_.jpg");
                        $getPoll -> setValue("img_".$index, ".".$imageUrl.".jpg");

                        if (in_array($imageUrl.".jpg",$imagesExists)) unset($imagesExists[array_search($imageUrl.".jpg",$imagesExists)]);
                    }
                }
                foreach($positions as $y=>$tr) foreach($tr as $x=>$td) if (!$td) unset($positions[$y][$x]);
                $getPoll -> setValue("img_position", serialize($positions));
            }
            foreach($imagesExists as $imageForDel){
                if (file_exists($root.$imageForDel))
                    unlink($root.$imageForDel);
            }
        }

        if ($country !== false) $getPoll -> target_geographical_country = $country;
        if ($region !== false) $getPoll -> target_geographical_region = $region;

        if (($editMode !== false) && ($getUserId !== false)){
            $getPoll -> setValue("user", $getUserId);
        } else {
            $getPoll -> setValue("user", $userId);
        }


        $getParentId = $getPoll -> getParentId();
        if ($getParentId != $parent){
            $getPoll->setRel($parent);
        }
        $getPoll -> commit();
        if ($getParentId != $parent){
            $h->rebuildRelationNodes($getPoll->getId());
        }

        unset($_SESSION['poll_new']);

        if (!$editMode) cmsController::getInstance()->getModule("events")->registerEvent('new-poll', array('content'=>('<b>'.$theme.' <a href="/admin/vote/edit/'.$getPoll->getId().'/">» Страица</a></b>')), null, null);

        if ($fastPoll) return array("fast"=>"1");
        return array("url"=>"/vote/preview/".$pollId."/");
    }

    //Оптимальная компоновка изображений
    public function optimal_layout($images){
        //array("name"=>$_SESSION['poll_new_image'], "top"=>0,"left"=>0, "width"=>100, "row"=>1, "col"=>1,"sizex"=>1,"sizey"=>1);
        if (!is_array($images)) return $images;
        $count = count($images);

        $layout = array();
        switch ($count){
            case 1:
                $layout[] = array("row"=>1,"col"=>1,"sizex"=>4, "sizey"=>3);
                break;
            case 2:
                $layout[] = array("row"=>1,"col"=>1,"sizex"=>2, "sizey"=>3);
                $layout[] = array("row"=>1,"col"=>3,"sizex"=>2, "sizey"=>3);
                break;
            case 3:
                $layout[] = array("row"=>1,"col"=>1,"sizex"=>2, "sizey"=>4);
                $layout[] = array("row"=>1,"col"=>3,"sizex"=>2, "sizey"=>2);
                $layout[] = array("row"=>3,"col"=>3,"sizex"=>2, "sizey"=>2);
                break;
            case 4:
                $layout[] = array("row"=>1,"col"=>1,"sizex"=>2, "sizey"=>2);
                $layout[] = array("row"=>1,"col"=>3,"sizex"=>2, "sizey"=>2);
                $layout[] = array("row"=>3,"col"=>1,"sizex"=>2, "sizey"=>2);
                $layout[] = array("row"=>3,"col"=>3,"sizex"=>2, "sizey"=>2);
                break;
        }

        foreach($images as $index=>$image){
            $images[$index]['row'] = $layout[$index]['row'];
            $images[$index]['col'] = $layout[$index]['col'];
            $images[$index]['sizex'] = $layout[$index]['sizex'];
            $images[$index]['sizey'] = $layout[$index]['sizey'];
        }
        return $images;
    }

    //Список опросов пользователя
    public function getListVotesOfUser($per_page = '', $sort = ''){
        $oC = umiObjectsCollection::getInstance();
        $userId = permissionsCollection::getInstance() -> getUserId();
        $getUser = $oC -> getObject($userId);
        $hierarchy = umiHierarchy::getInstance();
        if (is_object($getUser)){
            $getSettings = $oC -> getObject(3934);
            $p = getRequest('p') ? getRequest('p') : 0;
            $sort = $sort ? $sort : (getRequest('sort') ? getRequest('sort') : 'new');

            if (!$per_page)
                if(is_object($getSettings)){
                    $per_page = $getSettings -> getValue('cabinet_my_polls_per_page');
                }
            $per_page = $per_page ? $per_page : 20;

            $s = new selector('pages');
            $s->types('object-type')->name('vote', 'poll');
            $s->where('is_active')->equals(array(0,1));
            $s->where('user')->equals($userId);
            switch ($sort){
                case 'new':
                    $s->order('date')->desc();
                    break;
                case 'old':
                    $s->order('date')->asc();
                    break;
                case 'popularity':
                    $s->order('popularity')->desc();
                    break;
                case 'name':
                    $s->order('name')->asc();
                    break;
                default:
                    $s->order('date')->desc();
                    break;
            }
            //$s->where('for_lent')->notequals(true);
            $s->limit($p*$per_page, $per_page);
            $total  = $s -> length;
            $result = array();
            foreach($s->result() as $item){
                $date = is_object($item->getValue('date')) ? $item->getValue('date') : "";
                $date = $date ? date("Y.m.d H:i", $date->timestamp) : "";
                $votes = $item -> getValue('votes');
                $votes = $votes ? unserialize($votes) : "";
                $votes = is_array($votes) ? $votes : "";
                $numVotes = 0;
                if (is_array($votes) && count($votes))
                    foreach($votes as $num) $numVotes += $num;
                $feed = $item -> getValue("feed");
                $getAllParents = $hierarchy -> getAllParents($item->getId());
                $result[] = array("@id"=>$item->getId(), "@date"=>$date, "@is-active"=>$item->getIsActive() ? "1" : "0",
                    "@votes"=>$numVotes, /*"items"=>array("nodes:item"=>getAllParents($getAllParents, array(0,7))),*/
                    "feeds"=>$feed ? array("nodes:feed"=>$feed) : "","theme"=>$item->getName(),"@link_preview"=>"/vote/preview/".$item->getId()."/", "@link"=>$item->link);
            }
            return array("items"=>array("nodes:item"=>$result), "total"=>$total, "per_page"=>$per_page, "current_page"=>$p);
        }
        return;
    }

    //Карта googleMap голосования
    public function getPollMap($pollId = false, $parentCountry = ''){
        $data = getRequest('data');
        $hierarchy = umiHierarchy::getInstance();

        $variantId = isset($data['google_select_map']) ? $data['google_select_map'] : "";
        $variantId = is_array($variantId) ? $variantId : "";
        if (is_array($variantId)){
            $variantId = implode("' OR variant='", $variantId);
            $variantId = "variant='".$variantId."'";
        }
        $variantId = $variantId ? $variantId : (getRequest('custom') ? "variant='-1'" : ""); //-1 несуществующий вариант, чтобы отобразилась карта полностью, если пользователем был уже сделан выбор карты

        //Проверка, голосовал ли текущий пользователь. Если нет, то при условии в опросе "Показ.рез.до голос-я" отображается "чистая" карта
        $identification = isset($_SESSION['identification']) ? $_SESSION['identification'] : identification();
        $user_auth = $identification[0];
        $userId = $identification[1];
        $needAuth = $identification[2];

        $getPage = $hierarchy -> getElement($pollId);
        $obj_id = false;
        if ($getPage instanceof umiHierarchyElement) {
            $preview = $getPage -> getValue('preview');
            if ($userId == 2) $preview = 1;
            $obj_id = $getPage -> getObjectId();
            if ($obj_id){
                $q = "SELECT * FROM polls WHERE obj_id='".$obj_id."' AND user='".$userId."' AND user_reg=".($user_auth ? 'true' : 'false');
                $r = mysql_query($q);
                $num_rows = mysql_num_rows($r);
                if (!$num_rows && !$preview) $variantId = "variant='-1'";
            }
        }

        $parentCountry = ((strlen($parentCountry) == 2) or (strlen($parentCountry) == 3)) ? $parentCountry : false;
        $result = array();
        $name_ru = array();
        if (is_numeric($obj_id)){
            $q = "SELECT * FROM polls WHERE obj_id='".$obj_id."' ".($variantId ? ("AND (".$variantId.")") : "");
            $r = mysql_query($q);
            while($row = mysql_fetch_array($r)){
                $cityId = $row['city_id'];
                $q1 = "SELECT iso,country,sxgeo_regions.name_ru as region_name FROM sxgeo_regions LEFT JOIN sxgeo_cities ON sxgeo_cities.region_id = sxgeo_regions.id WHERE sxgeo_cities.id = '".$cityId."'";
                $r1 = mysql_query($q1);
                $row1 = mysql_fetch_array($r1);

                if (isset($row1['country']) && isset($row1['iso'])){
                    $country = $row1['country'];
                    $iso = $row1['iso'];
                    if (!isset($result[$country][$iso])) $result[$country][$iso] = 0;
                    $result[$country][$iso]++;
                    $q3 = "SELECT name_ru FROM sxgeo_country WHERE iso='".$country."'";
                    $r3 = mysql_query($q3);
                    $getCountry = mysql_fetch_array($r3);
                    $name_ru[$country] = $getCountry['name_ru'];
                    $name_ru[$iso] = $row1['region_name'];
                }
            }
        }

        if ($parentCountry !== false) if (isset($result[$parentCountry]))
            foreach($result as $country=>$regions) if ($country != $parentCountry) unset($result[$country]);

        if (count($result) == 1){
            reset($result);
            $googleMapRegion = array("regions"=>"provinces", "region"=>key($result));
            $votes = array();
            foreach($result as $countryISO=>$regions)
                foreach($regions as $regionISO=>$num)
                    $votes[] = array("@region"=>$regionISO, "@votes"=>$num, "@name"=>$name_ru[$regionISO]);
            $res = $googleMapRegion;
            $res['votes'] = array("nodes:item"=>$votes);
            return $res;
        } else {
            $listCountries = array();
            foreach($result as $country=>$votes) $listCountries[] = $country;
            $googleMapRegion = array("regions"=>"countries", "region"=>googleMapContinentHierarchy($listCountries));
            $votes = array();
            foreach($result as $countryISO=>$regions) {
                $total = 0;
                foreach($regions as $num) $total += $num;
                $votes[] = array("@region"=>$countryISO, "@votes"=>$total, "@name"=>$name_ru[$countryISO]);
            }

            $res = $googleMapRegion;
            $res['votes'] = array("nodes:item"=>$votes);
            return $res;
        }
    }

    //Список вариантов ответа указанного опроса
    public function getVariantsAdmin($id = false){
        $hierarchy = umiHierarchy::getInstance();
        $getPoll = $hierarchy -> getElement($id);
        $result = '
        <style>
            .goods_for_compare{background-color:#f0f0f0;padding: 5px;}
            .goods_for_compare span.title{display: inline-block !important;margin-right: 10px; color:#2B6FB6;font-weight:bold;}
            .goods_for_compare span.remove{display: inline-block !important;margin-left: 10px;background: url("/images/cms/admin/mac/tree/ico_del.png") no-repeat; background-size:10px 10px; width:10px; height:10px;cursor:pointer;}
        </style>
        <table style="font-size: 13px;border-collapse: collapse;" border="1" cellpadding="5" cellspacing="0">
        <thead style="background-color: #999; color:#fff;"><td>№п/п</td><td>Вариант ответа</td><td>Голосов</td><td>Примечание</td><td width="200">URL parse</td></thead>
        ';
        if ($getPoll instanceof umiHierarchyElement){
            $objId = $getPoll -> getObjectId();
            $variants = unserialize(html_entity_decode($getPoll -> getValue('variants'),ENT_COMPAT | ENT_HTML401, 'UTF-8'));
            $votes = unserialize($getPoll -> getValue('votes'));
            foreach($variants as $index=>$variant){
                $note = '';
                $urlParse = '';
                $query = "SELECT * FROM goods_for_compare WHERE obj_id='".$objId."' AND variant='".$index."'";
                $r = mysql_query($query);
                if(mysql_num_rows($r)){
                    while($row = mysql_fetch_array($r)){
                        $note .= date("d.m.Y G:i",$row['date'])." | ";
                        $note .= ' мин.цена '.$row['price_min']." | ";
                        $note .= ' макс.цена '.$row['price_max']." | ";
                        $note .= $row['reviews_num'].' отзывов | ';
                        $note .= $row['likes'].'% лайков | ';
                        $note = trim($note," | ");
                        $urlParse = $row['url'];
                    }
                }

                $result .= '
                    <tr>
                        <td width="50" align="center" valign="top">'.$index.'</td>
                        <td width="400">'.$variant.'</td>
                        <td width="50" align="center" valign="top">'.(isset($votes[$index]) ? $votes[$index] : '').'</td>
                        <td>'.($note ? ('<div class="goods_for_compare" data-table-name="goods_for_compare" data-id="'.$objId.'" data-variant-id="'.$index.'"><span class="title">Товар</span>'.$note.'<span class="remove"></span></div></td>') : '').'
                        <td><div class="parse" data-page-id="'.$id.'" data-id="'.$objId.'" data-variant-id="'.$index.'"><input type="text" value="'.$urlParse.'" style="width:140px" /><button type="button">Парсинг</button></div></td>
                    </tr>';
            }
        }
        $result .= '</table>';
        return $result;
    }

    //Изменение данных опросов в кабинете пользователя
    public function changeUserPolls(){
        $data = getRequest('data');
        if (is_array($data)){
            $hierarchy = umiHierarchy::getInstance();
            $oC = umiObjectsCollection::getInstance();
            $userId = permissionsCollection::getInstance() -> getUserId();
            file_put_contents(CURRENT_WORKING_DIR."/test.txt",print_r($data, true));
            foreach($data as $id=>$item){
                $getElement = $hierarchy -> getElement($id);
                if ($getElement instanceof umiHierarchyElement){
                    $getUserId = $getElement -> getValue('user') ? $getElement -> getValue('user') : false;
                    if ((($getUserId !== false) && ($userId == $getUserId)) or ($userId == 2)){

                        //Изменение активности
                        if (isset($item['is_active']))
                            $getElement -> setIsActive(($item['is_active'] == "1") ? true : false);

                        //Изменение принадлежности опроса к ленте
                        $resFeed = array();
                        if (isset($item['feed'])){
                            if (is_array($item['feed'])){
                                foreach($item['feed'] as $feedId){
                                    $getFeed = $oC -> getObject($feedId);
                                    if (is_object($getFeed)){
                                        $getUserFeed = $getFeed -> getValue('user');
                                        if ($getUserFeed == $getUserId) $resFeed[] = $feedId;
                                    }
                                }
                            }
                            $getElement -> setValue("feed", $resFeed);
                        }
                       

                        //Убрать привязку опроса к статье (прикрепить к статье)
                        if (isset($item['base']) && isset($item['article_id'])){
                            if (($item['base'] == "0") && is_numeric($item['article_id'])){
                                $getListBase = $getElement -> getValue('base');
                                if ($getListBase)
                                    if (is_array($getListBase))
                                        if (in_array($item['article_id'], $getListBase)){
                                            unset($getListBase[array_search($item['article_id'], $getListBase)]);
                                            $getElement -> setValue('base', $getListBase);
                                            $getElement -> setIsActive(false);
                                        }
                            }
                        }


                        $getElement -> commit();

                        //Вызов системного события "Изменение страницы в админке"
                        $oEventPoint = new umiEventPoint("systemModifyElement");
                        $oEventPoint->setMode("before");
                        $oEventPoint->addRef("element", $getElement);
                        $this->setEventPoint($oEventPoint);

                        clearCachePoll($id);
                    }
                    $this->redirect('/vote/preview/'.$id);
                }
            }
        }
        $this->redirect('/cabinet/polls/');
        return;
    }

    //Прикрепить опрос к статье
    public function attachPollToArticle(){
        $article_id = getRequest('article_id');
        $vote_id = getRequest('vote_id');

        if (is_numeric($article_id) && is_numeric($vote_id)) {
            $hierarchy = umiHierarchy::getInstance();
            $userId = permissionsCollection::getInstance() -> getUserId();
            $getElement = $hierarchy -> getElement($vote_id);
            if ($getElement instanceof umiHierarchyElement) {
                $getUserId = $getElement->getValue('user') ? $getElement->getValue('user') : false;
                if ((($getUserId !== false) && ($userId == $getUserId)) or ($userId == 2)) {
                    $getListBase = $getElement->getValue('base');
                    $getListBase = is_array($getListBase) ? $getListBase : array();
                    if (is_array($getListBase)) {
                        if (!in_array($article_id, $getListBase)) {
                            $getListBase = array($article_id);
                            $getElement->setValue('base', $getListBase);
                            $getElement->setIsActive(false);
                            $getElement->commit();

                            //Вызов системного события "Изменение страницы в админке"
                            $oEventPoint = new umiEventPoint("systemModifyElement");
                            $oEventPoint->setMode("before");
                            $oEventPoint->addRef("element", $getElement);
                            $this->setEventPoint($oEventPoint);

                            clearCachePoll($vote_id);
                            $this->redirect('/vote/preview/' . $vote_id);
                        }
                    }
                }
            }
        }
        $this->redirect('/cabinet/polls/');
        return;
    }

    //Список опросов в категории
    public function getListVotesOfCategory($parentId = false, $setPerPage = false, $setSort = 'new', $desc = true, $filter='', $filter_value='', $filter_field_mysql=''){
        $oC = umiObjectsCollection::getInstance();
        $getSettings = $oC -> getObject(3934);
        $p = getRequest('p') ? getRequest('p') : 0;
        $per_page = 20;
        if(is_object($getSettings)){
            $per_page = $getSettings -> getValue('category_polls_per_page');
        }
        if ($setPerPage) $per_page = $setPerPage;
        if ($setSort == "auto") $setSort = getRequest('sort');
        switch($setSort){
            case "new":
                $sort = 525;
                $desc = true;
                break;
            case "old":
                $sort = 525;
                $desc = false;
                break;
            case "popularity":
                $sort = 569;
                $desc = true;
                break;
            default:
                $sort = 525;
                $desc = true;
                break;
        }

        //Возрастное ограничение
        $oC = umiObjectsCollection::getInstance();
        $userId = permissionsCollection::getInstance() -> getUserId();
        $getUser = $oC -> getObject($userId);

        $age = $getUser -> getValue('birthday');
        $age = is_object($age) ? $age -> getDateTimeStamp() : false;
        $age = $age ? (((time() - $age) > 567648000) ? true : false) : false;

        //Географический таргетинг
        if (!isset($_SESSION['geo'])) $this -> geo();

        $geo = $_SESSION['geo'];
        $country_iso = $geo['country_iso'];
        $region = $geo['region'];

        $qTC = " AND oc.obj_id NOT IN (SELECT obj_id FROM cms3_object_content WHERE field_id=513 AND varchar_val!='".$country_iso."' AND varchar_val IS NOT NULL)";
        $qTR = " AND oc.obj_id NOT IN (SELECT obj_id FROM cms3_object_content WHERE field_id=514 AND int_val!='".$region."' AND int_val IS NOT NULL)";

        $filterS = ''; $filterW = '' ;
        if ($filter && $filter_value && $filter_field_mysql){
            $filterS = "LEFT JOIN cms3_object_content oc_".$filter."_lj ON oc_".$filter."_lj.obj_id=o.id AND oc_".$filter."_lj.field_id = '".$filter."'";
            if ($filter_value == 'NULL'){
                $filterW = " AND oc_".$filter."_lj.".$filter_field_mysql." IS NULL ";
            } else {
                $filterW = " AND oc_".$filter."_lj.".$filter_field_mysql." = '".$filter_value."' ";
            }
        }

        $q = "  SELECT DISTINCT SQL_CALC_FOUND_ROWS h.id as id
                FROM cms3_hierarchy h, cms3_object_types t, cms3_permissions p, cms3_hierarchy_relations hr, cms3_objects o

                LEFT JOIN cms3_object_content oc ON oc.obj_id=o.id AND oc.field_id = '".$sort."' LEFT JOIN cms3_object_content oc_516_lj ON oc_516_lj.obj_id=o.id AND oc_516_lj.field_id = '516' ".$filterS." LEFT JOIN cms3_object_content oc_625_lj ON oc_625_lj.obj_id=o.id AND oc_625_lj.field_id = '625'

                WHERE o.type_id IN (71) AND t.id = o.type_id ".(!$age ? ("AND ((oc_516_lj.int_val != '1' OR oc_516_lj.int_val IS NULL))") : "")." AND ((oc_625_lj.int_val != '1' OR oc_625_lj.int_val IS NULL)) ".$filterW." AND h.lang_id = '1' AND h.is_deleted = '0' AND h.is_active = '1' AND (p.rel_id = h.id AND p.level & 1 AND p.owner_id IN(337)) AND h.id = hr.child_id AND (hr.level <= 5 AND hr.rel_id = '".$parentId."') AND h.obj_id = o.id
                ".$qTC.$qTR."
                ORDER BY oc.int_val ".($desc ? "DESC" : "");

        $r = mysql_query($q);
        $total = mysql_num_rows($r);
        $result = array();
        if ($total)
            if (mysql_data_seek($r, $p*$per_page)){
                while($row = mysql_fetch_array($r)){
                    $result[] = array("@id"=>$row['id']);
                    if (count($result) == $per_page) break;
                }
            }

        return array("items"=>array("nodes:item"=>$result), "total"=>$total, "per_page"=>$per_page, "current_page"=>$p,
            "last_page" => (ceil($total / $per_page) == ($p+1)) ? "1" : "0",
            "url_sort_new"=>insertUrlParam("sort","","new"), "url_sort_old"=>insertUrlParam("sort","","old"),
            "url_sort_popularity"=>insertUrlParam("sort","","popularity")
        );
    }

    //Счетчик посещаемости
    public function viewsCounter($objId = false){
        $userId = permissionsCollection::getInstance() -> getUserId();
        if ($userId == 2) return;
        updateViewsCounter($objId);
        return;
    }

    //Создание страницы-новости из mysql
    public function addArticleFromNews($newsId = false, $parent = false){
        if (!is_numeric($newsId)) return;
        if (!is_numeric($parent)) return;

        $query = "SELECT * FROM news WHERE id=".$newsId;
        $r = mysql_query($query);
        if ($r){
            $userId = permissionsCollection::getInstance() -> getUserId();

            $news = mysql_fetch_array($r);

            $lent_id = $news['lent_id'];
            $title = html_entity_decode($news['title']);
            $link = html_entity_decode($news['link']);
            $description = html_entity_decode($news['description']);
            $content = html_entity_decode($news['content']);
            $image = $news['image'];
            $date = $news['date'];

            //Создание страницы
            $h = umiHierarchy::getInstance();
            $oC = umiObjectsCollection::getInstance();
            $root = CURRENT_WORKING_DIR;

            $pageId = $h->addELement($parent, 30, $title, '',141);
            $getPage = $h->getElement($pageId);
            if ($getPage instanceof umiHierarchyElement){
                $old_mode = umiObjectProperty::$IGNORE_FILTER_INPUT_STRING;		//Откючение html сущн.
                umiObjectProperty::$IGNORE_FILTER_INPUT_STRING = true;

                $getLent = $oC->getObject($lent_id);
                $source_title = ''; $source_url = '';

                if (is_object($getLent)){
                    $source_title = $getLent -> getValue('title');
                    $source_url = $getLent -> getValue('source_url');
                }

                $getPage->setIsActive(true);
                $getPage->setAltName($pageId);
                $getPage->setValue('h1', $title);
                $getPage->setValue('title', $title);
                $getPage->setValue('meta_descriptions', $description);
                $getPage->setValue('content', $content);
                $getPage->setValue('date', $date);
                $getPage->setValue('source_title', $source_title);
                $getPage->setValue('source_url', $source_url);
                $getPage->setValue('user', $userId);

                $getLentId = $h->getObjectInstances($lent_id);
                if (is_array($getLentId)) $getPage->setValue('source_news_lent', current($getLentId));

                $getPage->setValue('type', 3921);

                //Сохранение изображения
                $newFileName = createImage($root."/files/news_images/".$image.".jpg", $pageId);
                unlink($root."/files/news_images/".$image.".jpg");
                unlink($root."/files/news_images/".$image."_120.jpg");
                $getPage->setValue('img', ".".$newFileName);
                $getPage -> commit();
                permissionsCollection::getInstance()->setDefaultPermissions($pageId);
            }
            $query = "UPDATE news SET is_deleted='1',title='',link='',description='',content='',image='',date='' WHERE id=".$newsId;
            mysql_query($query);
            return $pageId;
        }
        return;
    }

    //Активация опроса
    public function activate($pollId = false){
        //Проверка пользователя
        $hierarchy = umiHierarchy::getInstance();
        $getPoll = $hierarchy -> getElement($pollId);
        if ($getPoll instanceof umiHierarchyElement){
            if ($getPoll -> getObjectTypeId() != 71) $this->redirect('/');
            $userId = permissionsCollection::getInstance()->getUserId();
            $getUserId = $getPoll->getValue('user') ? $getPoll->getValue('user') : false;
            if ((($getUserId !== false) && ($userId == $getUserId)) or ($userId == 2)) {
                $getPoll -> setIsActive(true);
                $getPoll -> commit();
                clearCachePoll($pollId);
                $this->redirect($hierarchy -> getPathById($pollId));
            }
        }
        return;
    }

    //Реализация круговой диаграммы
    public function pieChart($arr = array()){
        include(CURRENT_WORKING_DIR."/templates/iview/classes/modules/vote/pieChart/pChart/pData.class");
        include(CURRENT_WORKING_DIR."/templates/iview/classes/modules/vote/pieChart/pChart/pChart.class");

        $DataSet = new pData;
        $DataSet->AddPoint(array_values($arr),"Serie1");
        $DataSet->AddAllSeries();

        $pie = new pChart(560,300);
        $pie->drawFilledRoundedRectangle(0,0,588,304,1,254,254,254);
        $pie->drawRoundedRectangle(0,0,588,304,1,254,254,254);
        $index = 0;
        foreach($arr as $id=>$value){
            $getColors = getColor($id);
            $pie->setColorPalette($index,$getColors[1][0], $getColors[1][1], $getColors[1][2]);
            $index++;
        }
        // Draw the pie chart
        $pie->setFontProperties(CURRENT_WORKING_DIR."/templates/iview/classes/modules/vote/pieChart/Fonts/tahoma.ttf",14);
        $pie->drawPieGraph($DataSet->GetData(),$DataSet->GetDataDescription(),280,140,230,PIE_PERCENTAGE,TRUE,50,20,5);

        $pie->Render(CURRENT_WORKING_DIR."/images/pie_cahrt.png");
        return "/images/pie_cahrt.png";
    }

    //Автозаполнение нового опроса для ленты
    public function newPollAutocomplete($feedId = ''){
        if (!is_numeric($feedId)) return;
        $s = new selector('pages');
        $s->types('object-type')->name('vote', 'poll');
        $s->where('feed')->equals($feedId);
        $length = $s -> length();

        $result = array();

        foreach($s->result() as $vote){
            $variants = unserialize($vote->getValue('variants'));
            if (is_array($variants) && count($variants)){
                foreach ($variants as $pos=>$variant){
                    $md5Variant = md5($variant);
                    $posArr = isset($result[$md5Variant]) ? $result[$md5Variant][0] : array();
                    $num = isset($result[$md5Variant]) ? ($result[$md5Variant][1]+1) : 1;
                    $posArr[] = $pos;
                    $result[$md5Variant] = array($posArr, $num, $variant);
                }
            }
        }

        //Удаление вариантов, которые встречаются в опросе только один раз (кроме случая, когда в ленте всего один опрос)
        //и подсчет средней позиции
        foreach($result as $index=>$item){
            if (($length > 1) && ($item[1] < 2)) {
                unset($result[$index]);
                continue;
            }
            $result[$index][0] = round(array_sum($result[$index][0]) / count($result[$index][0]));
            unset($result[$index][1]);
        }

        sort($result);
        foreach($result as $index=>$item) $result[$index] = $item[2];

        return $result;
    }


    //Выводит случайный опрос
    public function getRandPoll_(){
        $s = new selector('pages');
        $s->types('object-type')->name('vote', 'poll');
        $s->order('rand');
        $s->limit(0,1);
        $first = $s->first;
        $h1 = $first -> getValue('h1');
        $variants = unserialize(html_entity_decode($first -> getValue('variants'),ENT_COMPAT | ENT_HTML401, 'UTF-8'));
        $variants = $variants ? $variants : array();
        $link = "http://glas.media".$first -> link;
        $img = $first -> getValue('img_0');
        $img = is_object($img) ? "http://glas.media".trim($img -> getFilePath(),".") : "";
        $img = $img ? '<div class="gm_img"><img src="'.$img.'" /></div>' : "";
        if ($link && $h1 && count($variants)){
            $var_s = '';
            foreach($variants as $gvar){
                $var_s .= "<li><img src='/images/ok.png'/> ".$gvar."</li>";
            }
            $out = '
            <div class="glass_media" onclick="window.open(\''.$link.'\', \'_blank\');">
                <div class="gm_title">'.$h1.'</div>
                <ul class="gm_variants">'.$var_s.'</ul>
                '.$img.'
            </div>
        ';
            $buffer = outputBuffer::current();
            $buffer->charset('utf-8');
            $buffer->contentType('text/plane');
            $buffer->clear();
            $buffer->push($out);
            $buffer->end();

        }
    }

    //Выводит случайный опрос
    public function getRandPoll($pollsId = ''){
        $pollsId = ''; //Отключено
        $hierarchy = umiHierarchy::getInstance();
        if ($pollsId){
            $arr = explode(",",$pollsId);
            if (is_array($arr)) {
                if (count($arr)) {
                    $firstId = rand(0,count($arr)-1);
                    $first = $hierarchy -> getElement($arr[$firstId]);
                }
            }
        }
        if ($first instanceof umiHierarchyElement){} else {
            $s = new selector('pages');
            $s->types('object-type')->name('vote', 'poll');
            /*$s->order('popularity')->desc();
            $s->limit(0,10);
            $result = $s->result();
            $first = $result[rand(0,9)];*/
            $s->order('rand');
//            $result = $s->result();
            $first = $s -> first;;
        }

        $h1 = $first -> getValue('h1');
        $variants = unserialize(html_entity_decode($first -> getValue('variants'),ENT_COMPAT | ENT_HTML401, 'UTF-8'));
        $variants = $variants ? $variants : array();
        $link = "http://glas.media".$first -> link;
        $img1 = $first -> getValue('img_0');
        $img1 = is_object($img1) ? "http://glas.media".trim($img1 -> getFilePath(),".") : "";

        if ($link && $h1 && count($variants)){
            $var_s = '';
            foreach($variants as $gvar){
                $var_s .= '
<div class="item">
<label>'.$gvar.'</label><table width="100%"><tbody><tr>
<td><div class="percent_bar"><span class="percent_bar" style="width:0%"></span></div></td>
<td class="width_voices width_voices_1"><div class="voices">
<span class="perc_value">0%</span>(0)</div></td>
</tr></tbody></table>
</div>
                ';
            }
            $out = '
            <style>
                .poll, {
                font-family: Arial;
                }
                .poll a,.poll a:hover{
                text-decoration: none;
                }
                .poll {
    position: relative;
    display: inline-block;
    vertical-align: top;
}
.poll.medium{
    width: 335px;
    background-color: #fff;
    padding: 20px 20px 20px 20px;
    margin-bottom: 20px;
    border: 1px solid #ddd;
    overflow: hidden;
}
.poll.medium .theme{
    margin: -5px -5px 10px -5px;
    border-bottom: 1px solid #eee;
    padding: 0px 0px 6px 0px;
    position: relative;
    line-height: 18px;
}
.poll.medium .theme a{
    font-size: 18px;
    margin: 0px;
    color: #555;
}
.poll.medium .warning {
    margin: 0px 0px 5px 0px;
    color: #999;
    font-size: 12px;
}
.poll.medium div.for_article{
    margin-top:15px;
}
.poll.medium div.for_article span.label{
    margin-left: 5px;
}
.poll.medium div.for_article .article_title{
    font-size: 12pt;
    margin-bottom: 5px;
    line-height: 12px;
    vertical-align: middle;
}
.poll.medium div.for_article img{
    width: 100%;
    height: auto;
    margin-top: 5px;
}
.poll .anonymous{
    display: inline-block;
    margin-top: 15px;
    float: right;
    color: #bbb;
}
.poll .variants{
    font-size: 12px;
    margin: 10px 0px 10px 0px !important;
    color: #555;
    position: relative;
}
.poll .variants .item{
    position: relative;
    overflow: hidden;
    margin: 0px 0px 0px 0px;
    padding: 5px 0px 5px 0px;
    border-bottom: 1px solid #ddd;
}
.poll .variants .item:last-child{
    border-bottom: none !important;
}
.poll .variants .item:hover{
    cursor: pointer;
}
.poll .variants .item .googleMapSelect{
    font-size: 14pt;
    vertical-align: middle;
    color: #ccc;
}
.poll .variants .item .googleMapSelect.active{
    color:#666;
}
.poll .variants .item .user_vote{
    color: #aaa;
    margin-right: 5px;
}
.poll .item input[type=\'checkbox\']{
    position: relative;
    vertical-align: top;
    display: inline-block;
    cursor: pointer;
}
.poll .item .voted {
    z-index: 1;
    margin-right:5px;
}
.poll .item label{
    font-weight: normal;
    font-size: 14px;
    line-height: 16px;
    display: inline !important;
    cursor: pointer;
    margin: -1px 0px 0px 0px !important;
}
.poll .item label span.glyphicon{
    margin-left:5px;
    font-size: 9pt;
}
.poll .item .perc_value{
    font-size: 14px;
    margin-right: 5px;
    color: #666;
    font-family: impact, arial, sans-serif;
}
.poll .variants .item label{
    position: relative; z-index: 1;
    vertical-align: middle;
}
.poll .variants .item input[type=\'checkbox\']{
    margin-right: 10px;
    z-index: 1;
    width: 18px;
    height: 18px;
}
.poll .vote {
    position: relative;
    width:170px;
    margin-top:5px;
}
.poll .poll_navbar{
    margin: 0px 0px 10px 0px;
    font-size: 12px;
}
.poll .poll_navbar span,.poll .poll_navbar a{
    color:#aaa;
}
.poll .poll_navbar a{
    text-decoration: underline;
}
.poll .poll_navbar span.date{
    float:right;
}
.poll .variants .item .voices{
    line-height: 12px;
    color: #bbb;
}

.poll .variants .width_voices{
    padding-left: 10px;
    max-width: 100px;
    width: 100px;
}
.poll .variants .width_voices.width_voices_1{
    width: 75px;
}
.poll .variants .width_voices.width_voices_2{
    width: 80px;
}
.poll .variants .width_voices.width_voices_3{
    width: 85px;
}
.poll .variants .width_voices.width_voices_4{
    width: 90px;
}
.poll .variants .width_voices.width_voices_5{
    width: 95px;
}
.poll .variants .item div.percent_bar{
    background-color: #eee;
    margin: 5px 0px 5px 0px;
}
.poll .variants .item span.percent_bar{
    height: 10px;
    background-color: #777;
    z-index: 0;
    display: block;
}
.poll td img{
    padding: 0px 1px 1px 0px;
}
.poll .image td{
    position: relative;
}
</style>

<table>
<tr>
<td width="375" style="font-family:Arial;">
<div class="poll medium shadow" style="margin:0px;">
<div class="theme"><a target="_blank" href="'.$link.'">'.$h1.'</a></div>
<div class="poll_navbar"><span>Раздел: </span>Общество<span class="date">'.date("d.m.Y G:i",time()).'</span></div>
<a target="_blank" href="'.$link.'">
'.($img1 ? '<div class="image" style="overflow:hidden; text-align: center;"><img src="'.$img1.'" style="max-height:250px; max-width:335px;" /></div>' : "").'
<div class="variants">'.$var_s.'</div>

<button type="button" class="btn btn-primary btn-sm vote" style="padding:5px;cursor:pointer;"><span>Результат | Голосовать</span></button></a>
</div>
</td>
<td width="300" style="background-color:#3771b1; vertical-align:middle; font-family:Arial;">
<div style="width:300px; text-align:center;padding:15px 0px;"><span style="color: #fff; font-size: 22px !important; line-height:30px; font-family: \'Raleway\',sans-serif; font-weight: 500 !important; text-shadow: rgba(0,0,0,1) 2px 2px 5px; text-transform: uppercase; display: block; margin-bottom: 30px;">Сервис онлайн опросов</span> <span style="color: #fff; font-family: \'Raleway\',sans-serif; font-size: 40px !important; font-weight: bold; text-shadow: rgba(0,0,0,1) 3px 2px 5px; margin-bottom: 20px; display: block; line-height: 40px;">Создай свой опрос</span>
<p style="color: #fff; font-size: 12pt; display: block; margin-bottom: 25px; line-height: 28px;">Интуитивно-понятный интерфейс позволит Вам в считанные минуты создать свой опрос на любую интересующую тему.</p>
<div style="color: #fff; font-size: 16pt; padding-left: 30px; background: url(\'http://glas.media/templates/iview/images/vote.png\') no-repeat 0 0; background-size: 20px; background-position: 0px 1px; display: inline-block; margin: 0px 30px 7px 0px;">Удобство</div>
<div style="color: #fff; font-size: 16pt; padding-left: 30px; background: url(\'http://glas.media/templates/iview/images/vote.png\') no-repeat 0 0; background-size: 20px; background-position: 0px 1px; display: inline-block; margin: 0px 30px 7px 0px;">Быстрота</div>
<div style="color: #fff; font-size: 16pt; padding-left: 30px; background: url(\'http://glas.media/templates/iview/images/vote.png\') no-repeat 0 0; background-size: 20px; background-position: 0px 1px; display: inline-block; margin: 0px 30px 7px 0px;">Гибкость настроек</div>
<div style="margin-top: 35px;"><a href="http://glas.media/" target="_blank"><button class="btn btn-primary" style="padding: 10px 30px; font-size: 18px; color: #666; cursor:pointer;" type="button">Создать опрос</button></a></div>
</div>
</td>
</tr>
</table>
        ';
            $buffer = outputBuffer::current();
            $buffer->charset('utf-8');
            $buffer->contentType('text/html');
            $buffer->clear();
            $buffer->push($out);
            $buffer->end();

        }
    }


    //Автоматическое создание похожего опроса на основе другого опроса
    public function createPollFromTemplate($templateId = '', $title = '', $photo = ''){
        $vote = cmsController::getInstance()->getModule("vote");
        $vote -> editPoll($templateId, false);
        $poll = $_SESSION['poll_new'];
        $poll['theme'] = $title;

        $_REQUEST['url'] = $photo;
        $vote -> upload_image_poll(true);

        if (isset($_SESSION['poll_new_image'])){
            if ($_SESSION['poll_new_image']){
                $images = array();
                $images[] = array("name"=>$_SESSION['poll_new_image'], "top"=>0,"left"=>0, "width"=>100, "row"=>1, "col"=>1,"sizex"=>1,"sizey"=>1);
                $poll['images'] = $images;
            }
            //Когда загружено новое изображение, определяем наиболее подходящую компоновку всех изображений
            $poll['images'] = $vote->optimal_layout($poll['images']);
            unset($_SESSION['poll_new_image']);
        }

        $_SESSION['poll_new'] = $poll;

        $this->redirect("/polls/new_poll/");
    }
}


?>
