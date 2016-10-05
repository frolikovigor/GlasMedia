<?php

class opinions_helper extends def_module {

    protected static $instance;
    protected $h = null;
    protected $oc = null;
    protected $pc = null;
    // id типа данных 
    protected $type_id = null;
    // id иерархического типа данных
    protected $hierarchy_type_id = null;
    // id родительской страницы
    protected $rel_id = null;
    // игнорировать ли капчу (true/false)?
    protected $ignore_captcha = null;
    // нужна ли премодерация?
    protected $need_moderation = null;
    // e-mail для уведомления
    protected $email_to = null;

    public function cms_callMethod($method_name, $args) {
        return call_user_func_array(Array($this, $method_name), $args);
    }

    public function __call($method, $args) {
        throw new publicException("Method " . get_class($this) . "::" . $method . " doesn't exists");
    }

    public function __construct($_type_id, $_hierarchy_type_id, $_rel_id, $_ignore_captcha = false, $_need_moderation = false, $_email_to = null) {
        $this->h = umiHierarchy::getInstance();
        $this->oc = umiObjectsCollection::getInstance();
        $this->pc = permissionsCollection::getInstance();
        $this->type_id = $_type_id;
        $this->hierarchy_type_id = $_hierarchy_type_id;
        $this->rel_id = $_rel_id;
        $this->ignore_captcha = $_ignore_captcha;
        $this->need_moderation = $_need_moderation;
        $this->email_to = $_email_to;
    }

    public function add() {
        if (!$this->ignore_captcha) {
            if (isset($_REQUEST['captcha'])) {
                $_SESSION['user_captcha'] = md5((int) getRequest('captcha'));
            }

            if (!umiCaptcha::checkCaptcha()) {
                $this->errorAddErrors('errors_wrong_captcha');
            }
		}	
		
		$elt_id = $this->h->addElement($this->rel_id, $this->hierarchy_type_id, getRequest('name'),null,$this->type_id);
		if ($elt_id > 0) {
			$elt = $this->h->getElement($elt_id);
			if (is_object($elt)) {
				if (!$this->need_moderation) {
					$elt->setIsActive(false);
				}
				$this->pc->setDefaultPermissions($elt->getObject()->getId());
				
				$elt->setValue('date',new umiDate());
				
				$data_module = cmsController::getInstance()->getModule('data');
				$data_module->saveEditedObjectWithIgnorePermissions($elt->getObject()->getId(), true);
				
				$elt->commit();

				if ($this->email_to != null) {
					$regedit = regedit::getInstance();
					$letter = new umiMail();
					$letter->addRecipient($this->email_to);

					$cmsController = cmsController::getInstance();
					$domains = domainsCollection::getInstance();
					$domainId = $cmsController->getCurrentDomain()->getId();
					$defaultDomainId = $domains->getDefaultDomain()->getId();

					if ($regedit->getVal("//modules/emarket/from-email/{$domainId}")) {
						$fromMail = $regedit->getVal("//modules/emarket/from-email/{$domainId}");
						$fromName = $regedit->getVal("//modules/emarket/from-name/{$domainId}");
					} elseif ($regedit->getVal("//modules/emarket/from-email/{$defaultDomainId}")) {
						$fromMail = $regedit->getVal("//modules/emarket/from-email/{$defaultDomainId}");
						$fromName = $regedit->getVal("//modules/emarket/from-name/{$defaultDomainId}");
					} else {
						$fromMail = $regedit->getVal("//modules/emarket/from-email");
						$fromName = $regedit->getVal("//modules/emarket/from-name");
					}

					$letter->setFrom($fromMail, $fromName);
					$letter->setSubject('Добавлен новый отзыв');                        
					$content = '<p>Здравствуйте!<br/>Несколько секунд назад на сайте был добавлен новый отзыв.<br/>Вы можете просмотреть его, перейдя по ссылке: <a href="http://'.$_SERVER['HTTP_HOST'].'/admin/content/edit/'.$elt_id.'/">http://'.$_SERVER['HTTP_HOST'].'/admin/content/edit/'.$elt_id.'/</a>';
					$letter->setContent($content);
					$letter->commit();
					$letter->send();
				}
				
				return 1;
			}
		}
        return 0;
    }
}