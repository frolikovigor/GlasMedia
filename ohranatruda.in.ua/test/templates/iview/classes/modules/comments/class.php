<?php

class comments_custom extends comments {

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
        $result = $regedit -> getVal('//modules/comments/'. $setting);
        
        if(!$result) {
            return 0;
        } else {
            return $result;
        }         
     }

}

?>