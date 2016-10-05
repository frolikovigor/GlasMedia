<?php

class rating_helper extends def_module {
    
	protected static $instance;
	protected $h = null;
	protected $oc = null;
	protected $pc = null;
	
	// id �����������, ������� �������� ���-�� �����������
	protected $type_id = null;
	// ������������ ������
	protected $max_rate;
	
	// ���� �����������: ID �������� (page_id), ID ������������ (user_id), ������ (rate)
	
	public function cms_callMethod($method_name, $args) {
		return call_user_func_array(Array($this, $method_name), $args);
	}
	
	public function __call($method, $args) {
		throw new publicException("Method " . get_class($this) . "::" . $method . " doesn't exists");
	}
	
	public function __construct($_type_id, $_max_rate = 5) {
	    
		$this -> h = umiHierarchy::getInstance();
		$this -> oc = umiObjectsCollection::getInstance();
		$this -> pc = permissionsCollection::getInstance();
		$this -> type_id = $_type_id;
		$this -> max_rate = $_max_rate;
	}
	
	public function isUserCanVote($page_id, $user_id, $guest_can_vote = true) {
	    
		$is_guest = false;
        
		if($user_id == $this -> pc -> getGuestId()) {
			$is_guest = true;
		}
		
		if($is_guest && !$guest_can_vote) {
			return false;
		}
		
		$s = new selector('objects');
		$s -> types('object-type') -> id($this -> type_id);
		$s -> where('page_id') -> equals($page_id);
		$s -> where('user_id') -> equals($user_id);
		
		if($s -> length() > 0) {
			    
			if($is_guest && !isset($_COOKIE['page_'.$page_id.'_rate'])) {
				return true;
			}
            
			return false;
		}
		return true;
	}
	
	public function getPageRating($page_id, $intval = true) {
	    
		$rating = 0;
		
		if($this -> type_id > 0) {
			$s = new selector('objects');
			$s -> types('object-type') -> id($this->type_id);
			$s -> where('page_id') -> equals($page_id);
			
			$count_votes = $s -> length();

			if($count_votes > 0) {
				$votes = $s -> result();
				
				$votes_value = 0;
                
				foreach($votes as $vote) {
					$votes_value += $vote -> getValue('rate');
				}
				
				$rating = round(($votes_value/$count_votes), 2);
				
				if($intval) {
					$rating = intval($rating);
				}
                
			}
		}
		
		return $rating;
	}
	
	public function ratePage($page_id, $rate, $guest_can_vote = true) {
		$user_id = $this -> pc -> getUserId();
		
		if($this -> isUserCanVote($page_id,$user_id, $guest_can_vote) && $this -> type_id > 0) {
			$rate_id = $this -> oc -> addObject(date('d.m.Y H:i:s'), $this -> type_id);
			$rate_obj = $this -> oc -> getObject($rate_id);
            
			if(is_object($rate_obj)) {
				$rate = intval($rate);
				
				if($rate > $this -> max_rate) {
					$rate = $this -> max_rate;
				}
				
				if(intval($rate) <= 0) { 
					$rate = 1;
				}

				$rate_obj -> setValue('rate', $rate);
				$rate_obj -> setValue('user_id', $user_id);
				$rate_obj -> setValue('page_id', $page_id);
				$rate_obj -> commit();
				
				setcookie('page_'.$page_id.'_rate', $rate, (time()+60*60*24*365)); // 1 year-cookie
				
				return 1;
			}
		} else {
			return 0;
		}
		return -1;
	}
	
	public function deleteRates($page_id = 0, $user_id = 0) {
	    
		$s = new selector('objects');
		$s -> types('object-type') -> id($this -> type_id);
		
		if($page_id > 0) {
			$s -> where('page_id') -> equals($page_id);
		} 
        
		if($user_id > 0) {
			$s -> where('user_id') -> equals($user_id);
		}

		$rates = $s -> result();
        
		$i = 0;
		
		foreach($rates as $rate) {
			$this -> oc -> delObject($rate -> getId());
			$i++;
		}
        
		return $i;
	}
}