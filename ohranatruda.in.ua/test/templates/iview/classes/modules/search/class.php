<?php

class search_custom extends search {
    
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
        $result = $regedit -> getVal('//modules/search/'. $setting);
        
        if(!$result) {
            return 0;
        } else {
            return $result;
        }         
     }
	    
    
    /**
     * Morph words
     * 
     * Morphological analysis of words based on the quantity of parameter passed.
     * 
     * @param $count int The number you want to return the morphologically right word.
     * @param $word string Key to the array of words denoting the required quantity.
     * @param $noCount bool[optional] If true return morphologically correct word without the quantity.
     * 
     * @return string Returns morphologically correct word and quantity, and correct word without quantity if $noCount = false, for a certain amount.
     */
    
    public function morphWords($count, $word, $noCount = false) {
    	 
		/** Prefix of the current language version */
		$langPrefix = cmsController::getInstance() -> getCurrentLang() -> getPrefix();
       	/** Words array */
       	$words = array();

        switch ($langPrefix) {
			case 'en':
		        $words = array(
		            'pages' => array('page', 'pages', 'pages'),
		            'found' => array('found', 'found', 'found')
		        );
				break;			
			default:
		        $words = array(
		            'pages' => array('страница', 'страницы', 'страниц'),
		            'found' => array('найдена', 'найдено', 'найдено')
		        );								
        }

        if(array_key_exists($word, $words)) {
            list($first, $second, $third) = $words[$word];

            if($count == 1) {
                
                if (!$noCount) $result = '1 ' . $first;
                else $result = $first;
                
            } elseif (($count > 20) && (($count % 10) == 1)) {
                    
                if(!$noCount) $result = str_replace('%', $count, '% ' . $first);
                else $result = $first;
                
            } elseif ((($count >= 2) && ($count <= 4)) || ((($count % 10) >= 2) && (($count % 10) <= 4)) && ($count > 20)) {
                    
                if(!$noCount) $result = str_replace('%', $count, '% ' . $second);
                else $result = $second;
                
            } else {
                    
                if(!$noCount) $result = str_replace('%', $count, '% ' . $third);
                else $result = $third;
            }
            
            return $result;
        }
    }
    
	public function search_do_custom($per_page = 0) {
		$search_string = trim((string)getRequest('search_string'));
		
		$search_string = urldecode($search_string);
        $search_string = htmlspecialchars($search_string);
        $search_string = str_replace(". ", " ", $search_string);
        $search_string = trim($search_string, " \t\r\n%");
        $search_string = str_replace(array('"', "'"), "", $search_string);
        $url_photo = '';
        
        $block_arr = array(); $lines = array();
		$total = 0;
		if (!$per_page) $per_page = intval(getRequest('per_page'));
        if (!$per_page) $per_page = $this->per_page;
		
		$p = (int)getRequest('p');
		
        if($search_string != '')
        {
            $tmp = array(); $tmp_artikul = array(); $tmp_text = array();
			// строка разбивается, для поиска каждой подстроки
            $mas_str = explode(' ', $search_string);
			
			$s = new selector('pages');
			$s->types('hierarchy-type')->name('catalog','object');
			
			// можно задать какие угодно поля
			$search_fields = array('h1','description', 'descr_anons');
			
			// условие для поиска каждой подстроки по условию "ИЛИ"
			$s->option('or-mode')->fields('h1','description', 'descr_anons');
			foreach($search_fields as $field) {
				foreach($mas_str as $str) {
					$s->where($field)->ilike("%{$str}%");
				}
			}
			$s->limit($p*$per_page,$per_page);
			$s->order('name')->asc();
			
			$_lines = $s->result();
			$__lines = array();
			
			$total = $s->length;
		}
		
        $block_arr['items']['nodes:item'] = $lines;
        $block_arr['total'] = $total;
        $block_arr['per_page'] = $per_page;

        return $block_arr;
    }

    public function s($template = "default", $search_string = "", $search_types = "", $search_branches = "", $per_page = 0, $fullList = false) {
        // поисковая фраза :
        if (!$search_string) {
            $search_string = (string) getRequest('search_string');
        }

        $p = (int) getRequest('p');
        // если запрошена нетипичная постраничка
        if (!$per_page) {
            $per_page = intval(getRequest('per_page'));
        }
        if (!$per_page) {
            $per_page = $this->per_page;
        }

        $config = mainConfiguration::getInstance();
        $searchEngine = $config->get('modules', 'search.using-sphinx');
        if ($searchEngine){
            return $this->sphinxSearch($template, $search_string, $per_page, $p);
        }

        list(
            $template_block, $template_line, $template_empty_result, $template_line_quant
            ) = self::loadTemplates("search/".$template,
            "search_block", "search_block_line", "search_empty_result", "search_block_line_quant"
        );

        $block_arr = Array();
        $block_arr['last_search_string'] = $search_string;

        $search_string = urldecode($search_string);
        $search_string = htmlspecialchars($search_string);
        $search_string = str_replace(". ", " ", $search_string);
        $search_string = trim($search_string, " \t\r\n%");
        $search_string = str_replace(array('"', "'"), "", $search_string);

        $orMode = (bool) getRequest('search-or-mode');

        if (!$search_string) return $this->insert_form($template);

        // если запрошен поиск только по определенным веткам :
        $arr_search_by_rels = array();
        if (!$search_branches) $search_branches = (string) getRequest('search_branches');
        $search_branches = trim(rawurldecode($search_branches));
        if (strlen($search_branches)) {
            $arr_branches = preg_split("/[\s,]+/", $search_branches);
            foreach ($arr_branches as $i_branch => $v_branch) {
                $arr_branches[$i_branch] = $this->analyzeRequiredPath($v_branch);
            }
            $arr_branches = array_map('intval', $arr_branches);
            $arr_search_by_rels = array_merge($arr_search_by_rels, $arr_branches);
            $o_selection = new umiSelection;
            $o_selection->addHierarchyFilter($arr_branches, 100, true);
            $o_result = umiSelectionsParser::runSelection($o_selection);
            $sz = sizeof($o_result);
            for ($i = 0; $i < $sz; $i++) $arr_search_by_rels[] = intval($o_result[$i]);
        }
        // если запрошен поиск только по определенным типам :
        if (!$search_types) $search_types = (string) getRequest('search_types');

        $search_types = rawurldecode($search_types);
        if (strlen($search_types)) {
            $search_types = preg_split("/[\s,]+/", $search_types);
            $search_types = array_map('intval', $search_types);
        }

        $typesCollection = umiObjectTypesCollection::getInstance();
        $getListArticlesTypes = $typesCollection -> getChildClasses(141);
        $getFullListArticlesTypes = array_merge(array(71,146,141),$getListArticlesTypes);

        $lines = Array();
        
        $result = searchModel::getInstance()->runSearch($search_string, $getFullListArticlesTypes, $arr_search_by_rels, $orMode);

        $h = umiHierarchy::getInstance();

        if ($fullList){
            $items = array();
            foreach($getFullListArticlesTypes as $item){
                if (isset($result[$item])){
                    foreach($result[$item] as $objId=>$num){
                        $items[$objId] = $num;
                    }
                }
            }
            arsort($items);
            $i = 0;
            foreach($items as $index=>$item){
                $items[$index] = $i;
                $i++;
            }
            $items = array_flip($items);
            foreach($items as $index=>$objId){
                $getObjectInstances = $h -> getObjectInstances($objId);
                if (is_array($getObjectInstances) && count($getObjectInstances))
                    $items[$index] = array("@id"=>current($getObjectInstances));
                else unset($items[$index]);
            }
            return array("items"=>array("nodes:item"=>$items));
        }

        foreach($getListArticlesTypes as $item){
            if (isset($result[$item])){
                foreach($result[$item] as $objId=>$num){
                    $result[141][$objId] = $num;
                }
                unset($result[$item]);
            }
        }

        //Статьи (тип = 141). Определяем какие опросы связаны со статьями и добавляем в общий список опросов
        if (!isset($result[71])) $result[71] = array();
        if (!isset($result[146])) $result[146] = array();

        if (isset($result[141]) && count($result[141])){
            //Для прикрепленных статей
            $query141 = "h.obj_id=".implode(" OR h.obj_id=",array_keys($result[141]));
            $q = "SELECT oc.obj_id AS obj_to, h.obj_id AS obj_from FROM cms3_object_content oc JOIN cms3_hierarchy h
                  ON oc.tree_val = h.id WHERE oc.field_id=591 AND h.is_active='1' AND h.is_deleted='0' AND (".$query141.")
                  AND oc.obj_id NOT IN(
                    SELECT oc1.obj_id FROM cms3_object_content oc1 JOIN cms3_hierarchy h1 ON oc1.obj_id = h1.obj_id
                    WHERE h1.is_active='0' OR h1.is_deleted='1'
                  )";
            $r = mysql_query($q);
            while($row = mysql_fetch_array($r)) {
                if (isset($result[71][$row['obj_to']]))
                    $result[71][$row['obj_to']] = ($result[71][$row['obj_to']] > $result[141][$row['obj_from']]) ? $result[71][$row['obj_to']] : $result[141][$row['obj_from']];
                else {
                    $result[71][$row['obj_to']] = $result[141][$row['obj_from']];
                }
            }

            //Для статей, участвующих в рейтинге
            $query141 = "h.obj_id=".implode(" OR h.obj_id=",array_keys($result[141]));
            $q = "SELECT oc.obj_id AS obj_to, h.obj_id AS obj_from FROM cms3_object_content oc JOIN cms3_hierarchy h
                  ON oc.rel_val = h.obj_id WHERE oc.field_id=511 AND h.is_active='1' AND h.is_deleted='0' AND (".$query141.")
                  AND oc.obj_id NOT IN(
                    SELECT oc1.obj_id FROM cms3_object_content oc1 JOIN cms3_hierarchy h1 ON oc1.obj_id = h1.obj_id
                    WHERE h1.is_active='0' OR h1.is_deleted='1'
                  )";

            $r = mysql_query($q);
            while($row = mysql_fetch_array($r)) {
                if (isset($result[71][$row['obj_to']]))
                    $result[71][$row['obj_to']] = ($result[71][$row['obj_to']] > $result[141][$row['obj_from']]) ? $result[71][$row['obj_to']] : $result[141][$row['obj_from']];
                else {
                    $result[71][$row['obj_to']] = $result[141][$row['obj_from']];
                }
            }
        }

        if (isset($result[141])) unset($result[141]);
        arsort($result[71]);

        if (isset($result[71])) {
            if (!count($result[71])) unset($result[71]);
            else
                $result[71] = array_keys($result[71]);
        }
        if (isset($result[146])) {
            if (!count($result[146])) unset($result[146]);
            else
                $result[146] = array_keys($result[146]);
        }

        $total_71 = isset($result[71]) ? count($result[71]) : 0;
        $total_146 = isset($result[146]) ? count($result[146]) : 0;

        //Атоматически выбирается вкладка поиска "Опросы" или "Ленты"
        $preference = ($total_71 >= $total_146) ? 71 : 146;

        $search_types = is_array($search_types) ? (count($search_types) ? $search_types : array($preference)) : array($preference);

        //Если тип данных - Опросы
        if (in_array(71,$search_types)){
            $total = isset($result[71]) ? count($result[71]) : 0;
            $result = isset($result[71]) ? $result[71] : array();
            $result = array_slice($result, $per_page * $p, $per_page, true);

            foreach($result as $index=>$objId){
                $pagesId = $h->getObjectInstances($objId);
                if (is_array($pagesId)){
                    $pageId = current($pagesId);
                    if ($pageId){
                        $result[$index] = array("@id"=>$pageId);
                    }
                }
            }
        }

        //Если тип данных - Ленты
        if (in_array(146,$search_types)){
            $total = isset($result[146]) ? count($result[146]) : 0;
            $result = isset($result[146]) ? $result[146] : array();
            $result = array_slice($result, $per_page * $p, $per_page, true);

            foreach($result as $index=>$objId){
                $result[$index] = array("@id"=>$objId);
            }
        }


        $block_arr['subnodes:items'] = $block_arr['void:lines'] = $result;
        $block_arr['total'] = $total;
        $block_arr['per_page'] = $per_page;
        $block_arr['sections'] = array("nodes:section"=>array(
            array("@type-id"=>71, "name"=>"Опросы", "@selected"=>(in_array(71,$search_types) ? "1" : ""), "@num"=>$total_71),
            array("@type-id"=>146, "name"=>"Ленты", "@selected"=>(in_array(146,$search_types) ? "1" : ""), "@num"=>$total_146)
//            array("@type-id"=>141, "name"=>"Публикации", "@link"=>insertUrlParam("search_types",null,"141"), "@selected"=>(in_array(141,$search_types) ? "1" : ""))
        ));

        return self::parseTemplate(($total > 0 ? $template_block : $template_empty_result), $block_arr);
    }

}

?>
