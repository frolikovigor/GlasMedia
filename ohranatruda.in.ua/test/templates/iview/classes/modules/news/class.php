<?php

require_once CURRENT_WORKING_DIR."/files/scripts-parsing/default.php";

class news_custom extends news {
    
    /**
     * Get module setting
     * 
     * Checks the value of the setting of module passed in the parameter $setting.
     * 
     * @param $setting string Name of the setting value you want to get.
     * 
     * @return mixed Returns setting value and 0 otherwise.
     */
     
     public function getModuleSetting($setting) {

        /** Instance of regedit */
        $regedit = regedit::getInstance();
        /** Value of the option */
        $result = $regedit -> getVal('//modules/news/'. $setting);

        if(!$result) {
            return 0;
        } else {
            return $result;
        }
     }


    /**
     * Format month of news
     *
     * Change the numeric month name to a string of news.
     *
     * @param $newsId int ID of news page.
     *
     * @return string Return a formatted date news publication.
     */

     public function formatMonthOfNews($newsId) {

        /** Prefix of the current language version */
        $langPrefix = cmsController::getInstance() -> getCurrentLang() -> getPrefix();

        /** Russian array months */
        $monthsRu = array(
            '01' => 'января',
            '02' => 'февраля',
            '03' => 'марта',
            '04' => 'апреля',
            '05' => 'мая',
            '06' => 'июня',
            '07' => 'июля',
            '08' => 'августа',
            '09' => 'сентября',
            '10' => 'октября',
            '11' => 'ноября',
            '12' => 'декабря',
        );
        /** English array months */
        $monthsEn = array(
            '1' => 'january',
            '2' => 'february',
            '3' => 'march',
            '4' => 'april',
            '5' => 'may',
            '6' => 'june',
            '7' => 'july',
            '8' => 'august',
            '9' => 'september',
            '10' => 'october',
            '11' => 'november',
            '12' => 'december',
        );

        /** Instance of umiHierarchy */
        $h = umiHierarchy::getInstance();
        /** Page object */
        $page = $h -> getElement($newsId);
        /** News publish month string value */
        $publishMonthStr = null;

        if ($page instanceof umiHierarchyElement) {
            /** Publish time unix timestamp */
            $publishTime = strtotime($page -> getValue('publish_time'));
            /** News publish month */
            $publishMonth = date('m', $publishTime);

            switch ($langPrefix) {
                case 'en':
                    $publishMonthStr = $monthsEn[$publishMonth];
                    break;

                default:
                    $publishMonthStr = $monthsRu[$publishMonth];
            }

            /** News publish date with the numeric month name */
            //$formatPublishDate = str_replace('.', ' ', date('j.m.Y', $publishTime));
			//$formatPublishDate = str_replace($publishMonth, $publishMonthStr, $formatPublishDate);
            return date('j', $publishTime).' '.$publishMonthStr.' '.date('Y', $publishTime);
        }
     }


    /**
     * Get new in necessary month
     *
     * Select all news in a month in the specified year.
     *
     * @param $newsLineId int ID of a news line from which it is necessary to choose news.
     *
     * @return array Array with news of the specified year and month, their total, quantity of news being displayed on one page the period from which selection is made.
     */

    public function getNewInNecessaryMonth ($newsLineId) {

        $months = array(
                        1 => 'январь',
                        2 => 'февраль',
                        3 => 'март',
                        4 => 'апрель',
                        5 => 'май',
                        6 => 'июнь',
                        7 => 'июль',
                        8 => 'август',
                        9 => 'сентябрь',
                        10 => 'октябрь',
                        11 => 'ноябрь',
                        12 => 'декабрь'
                       );

        $p = intval(getRequest('p'));
        $perPage = regedit::getInstance() -> getVal("//modules/news/per_page");

        $month = intval(getRequest('month'));
        $year = intval(getRequest('year'));

        if($year < 2000) {
            $year = 0;
        }

        if($month < 1 || $month > 12) {
            $month = 0;
        }

        $timeFrom = 0;
        $timeTo = 0;

        if($month > 0 || $year > 0) {
            if(!$year) $year = date('Y');

            if($month > 0) {
                $timeFrom = mktime(0, 0, 0, $month, 1, $year);
                $timeTo = strtotime('+1 month - 1 second', $timeFrom);
            } else {
                $timeFrom = mktime(0, 0, 0, 1, 1, $year);
                $timeTo = strtotime('+1 year - 1 second', $timeFrom);
            }
        }

        $s = new selector('pages');
        $s -> types('object-type') -> id(53);
        $s -> where('hierarchy') -> page($newsLineId) -> childs(1);
        $s -> limit($p * $perPage, $perPage);

        if($timeFrom > 0 && $timeTo > 0) {
            $s -> where("publish_time") -> between($timeFrom, $timeTo);
        }

        $s -> order('publish_time') -> desc();
        $items = $s -> result();
        $total = $s -> length();

        $datePeriod = null;

        if(isset($months[$month])) {
            $datePeriod = $months[$month].' ';
        }

        if($year > 0) {
            $datePeriod .= $year;
        }

        return array('items' => array('nodes:item' => $items), 'total' => $total, 'per_page' => $perPage, 'date_period' => $datePeriod);
    }

    public function KorrespondentNet($lentId = false, $url = ''){
        $root = CURRENT_WORKING_DIR;

        if (!$lentId or !$url) return;
        $getXml = simplexml_load_file($url);
        $result = array();
        foreach($getXml->channel->item as $item){
            $arr = (array) $item;
            $elem = array();
            foreach($arr as $field=>$value){
                $val = (string) $item->{$field};
                if ($val) $elem[$field] = $val;
                if ($field == 'pubDate') $elem["date"] = strtotime($val);
                if ($field == "image"){
                    if (strpos($elem['image'],"src")!==false){
                        $imgSrc = substr_replace($elem['image'],"",0,strpos($elem['image'], "src=")+5);
                        $imgSrc = substr($imgSrc, 0, strpos($imgSrc,"\""));
                        $imgSrc = strtr($imgSrc, array("190x120"=>"610x385"));
                        $newNameImg = uniqid();
                        $elem["image_from"] = $imgSrc;
                        $elem["image_to"] = $newNameImg;
                    } else {
                        $elem["image"] = "";
                        $elem["image_from"] = "";
                        $elem["image_to"] = "";
                    }
                }
            }
            $result[] = $elem;
        }

        foreach($result as $item){
            $query = "SELECT * FROM news WHERE lent_id=".$lentId." AND guid=".$item['guid'];
            $result = mysql_query($query);
            if (mysql_num_rows($result) == 0){
                $title = isset($item['title']) ? $item['title'] : "";
                $title = htmlentities($title, ENT_QUOTES);
                $link = isset($item['link']) ? $item['link'] : "";
                $link = htmlentities($link, ENT_QUOTES);
                $description = isset($item['description']) ? $item['description'] : "";
                $description = strip_tags($description);
                $description = htmlentities($description, ENT_QUOTES);
                $fulltext = isset($item['fulltext']) ? $item['fulltext'] : "";
                $fulltext = strip_tags($fulltext, "<p></p><strong></strong><b></b><i></i>");
                $fulltext = htmlentities($fulltext, ENT_QUOTES);
                $date = isset($item['date']) ? $item['date'] : "";
                $guid = isset($item['guid']) ? $item['guid'] : "";
                $image = "";
                if ($item['image_from'] && $item['image_to']) {
                    if (!copy($item['image_from'], $root."/files/temp/".$item['image_to'])){
                        if (file_exists($root."/files/temp/".$item['image_to'])) unlink($root."/files/temp/".$item['image_to']);
                        continue;
                    }
                    resize($root."/files/temp/".$item['image_to'],600, 400,$root."/files/news_images/".$item['image_to'].".jpg");
                    resize($root."/files/temp/".$item['image_to'],120, 80,$root."/files/news_images/".$item['image_to']."_120.jpg");
                    unlink($root."/files/temp/".$item['image_to']);

                    $image = $item['image_to'];
                }
                $q = "INSERT INTO news (lent_id,title,link,description,content,image,date,guid) VALUES(".$lentId.",'".$title."','".$link."','".$description."','".$fulltext."','".$image."',".$date.",'".$guid."')";
                mysql_query($q);
            }
        }
        return;
    }

    //Список новостей для текущей ленты новостей (в админке)
    public function listNewsSql($lentId = false, $per_page=15, $sort = "id", $desc = "ASC", $console = false){
        if (!$lentId) return;
        $query = "SELECT * FROM news WHERE lent_id=".$lentId." AND is_deleted='0' ORDER BY ".$sort." ".$desc;
        $r = mysql_query($query);
        $total = mysql_num_rows($r);
        $result = array();

        while($news = mysql_fetch_array($r)){
            $result[] = array(
                "@id" => $news['id'],
                "@lent_id" => $news['lent_id'],
                "title" => html_entity_decode($news['title']),
                "@link" => html_entity_decode($news['link']),
                "description" => html_entity_decode($news['description']),
                "content" => html_entity_decode($news['content']),
                "@image" => "/files/news_images/".$news['image'].".jpg",
                "@image_120" => "/files/news_images/".$news['image']."_120.jpg",
                "@unix-date" => $news['date'],
                "@date" => date("d.m.Y G:i",$news['date']),
                "@guid" => $news['guid'],
            );
        }
        $p = getRequest('p') ? getRequest('p') : 0;
        $result = array_slice($result, $p*$per_page, $per_page);
        if ($console) return $result;
        return array("items"=>array("nodes:item"=>$result), "total"=>$total, "per_page" => $per_page);
    }

    //Удаление новости с mysql
    public function delNewsMysql($newsId = false){
        if (!is_numeric($newsId)) return;
        $root = CURRENT_WORKING_DIR;
        $query = "SELECT * FROM news WHERE id=".$newsId;
        $r = mysql_query($query);
        $news = mysql_fetch_array($r);
        if (isset($news['image']))
            if ($news['image']) unlink($root.$news['image']);
        $query = "UPDATE news SET is_deleted='1',title='',link='',description='',content='',image='',date='' WHERE id=".$newsId;
        mysql_query($query);
        return;
    }

    //Подбор новостей для текущей страницы сайта
    public function getFitNews($objId = false, $per_page = 10, $num_parts = 1){
        if (!is_numeric($objId)) return;

        //Определение типа объекта
        $query = "SELECT type_id FROM cms3_objects WHERE id=".$objId;
        $r = mysql_query($query);
        if ($r){
            $typeId = mysql_fetch_array($r);
            $typeId = isset($typeId['type_id']) ? (is_numeric($typeId['type_id']) ? $typeId['type_id'] : false) : false;
            if ($typeId !== false){
                $h = umiHierarchy::getInstance();
                switch($typeId){

                    //Если опрос или статья
                    case 71:
                    case 141:
                        $query = "SELECT id FROM cms3_hierarchy WHERE obj_id=".$objId;
                        $r = mysql_query($query);
                        if ($r){
                            $parent = mysql_fetch_array($r);
                            $parent = isset($parent['id']) ? (is_numeric($parent['id']) ? $parent['id'] : false) : false;
                            if ($parent !== false){
                                $getAllParents = $h->getAllParents($parent);
                                $getAllParents = array_reverse($getAllParents);
                                $result = array();
                                foreach($getAllParents as $getParentId){
                                    if (($getParentId == 0) or ($getAllParents == 7)) continue;
                                    $q1 = "SELECT obj_id FROM cms3_object_content WHERE field_id=531 AND tree_val=".$getParentId;
                                    $r1 = mysql_query($q1);
                                    if ($r1){
                                        while($objIdNewsLent = mysql_fetch_array($r1)){
                                            $objIdNewsLent = isset($objIdNewsLent['obj_id']) ? ($objIdNewsLent['obj_id'] ? $objIdNewsLent['obj_id'] : false) : false;
                                            if ($objIdNewsLent === false) continue;

                                            //Определение title ленты
                                            $q2 = "SELECT varchar_val FROM cms3_object_content WHERE field_id=2 AND obj_id=".$objIdNewsLent;
                                            $r2 = mysql_query($q2);
                                            $title = false;
                                            if ($r2){
                                                $title = mysql_fetch_array($r2);
                                                $title = isset($title['varchar_val']) ? ($title['varchar_val'] ? $title['varchar_val'] : false) : false;
                                            }
                                            //Определение типа создаваемых статей
                                            $q2 = "SELECT o2.varchar_val FROM cms3_object_content o1 JOIN cms3_object_content o2 ON o1.rel_val=o2.obj_id WHERE o1.field_id=584 AND o1.obj_id=".$objIdNewsLent." AND o2.field_id=544";
                                            $r2 = mysql_query($q2);
                                            $type = false;
                                            if ($r2){
                                                $type = mysql_fetch_array($r2);
                                                $type = isset($type['varchar_val']) ? ($type['varchar_val'] ? $type['varchar_val'] : false) : false;
                                            }

                                            if (($title !== false) && ($type !== false)){
                                                if (!isset($result[$type."||".$title])) $result[$type."||".$title] = array();
                                                $listNewsSql = $this->listNewsSql($objIdNewsLent, $per_page, "date", "DESC", true);
                                                foreach($listNewsSql as $item) $result[$type."||".$title][] = $item;
                                            }
                                        }
                                    }
                                }
                                foreach($result as $index=>$item){
                                    $TypeTitle = explode("||",$index);
                                    $result[$index] = array(
                                        "@type" => current($TypeTitle),
                                        "@title" => end($TypeTitle),
                                        "items" => array("nodes:item"=>$item)
                                    );
                                }
                                foreach($result as $index=>$item){
                                    $result[$index]['items']['nodes:item'] = array_slice($result[$index]['items']['nodes:item'],0,10);
                                }
                                $result = array_slice($result,0,$num_parts);
                                return array("nodes:part"=>$result);
                            }
                        }
                        break;
                }
            }
        }
        return;
    }

    //Получить новость из БД
    public function getNewsMysql($newsId = false){
        if (!$newsId) return;
        $query = "SELECT * FROM news WHERE id=".$newsId;
        $r = mysql_query($query);
        $result = array();
        while($news = mysql_fetch_array($r)){
            $result = array(
                "@id" => $news['id'],
                "@lent_id" => $news['lent_id'],
                "title" => html_entity_decode($news['title']),
                "@link" => html_entity_decode($news['link']),
                "description" => html_entity_decode($news['description']),
                "content" => html_entity_decode($news['content']),
                "@image" => "/files/news_images/".$news['image'].".jpg",
                "@image_120" => "/files/news_images/".$news['image']."_120.jpg",
                "@unix-date" => $news['date'],
                "@date" => date("d.m.Y G:i",$news['date']),
                "@guid" => $news['guid'],
            );
        }
        return array("news"=>$result);
    }

}


?>
