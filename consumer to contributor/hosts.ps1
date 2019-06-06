$hostName=$args[0]
switch ($hostName) {
   "sand006" {
   $baseURL = "https://sand006.insights.health.ge.com:8943"; 
   $access_token ="";
   break
   
   }
   "beta002" {
				$baseURL = "https://beta002.insights.health.ge.com:8945";
				$access_token = "";
				break
			}
   "beta003" {
                 $baseURL = "https://beta003.insights.health.ge.com:8943"; 
				 $access_token = "";
				 break}
   "demo001" {
				$baseURL = "https://demo001.insights.health.ge.com:8945"; 
				$access_token = "";
				break
			}
   "demo002" {
				$baseURL = "https://demo002.insights.health.ge.com:8945";
				$access_token = "";
				break
			}
   "sand002" {
               $baseURL = "https://sand002.insights.health.ge.com:8943"; 
			   $access_token = "";
			   break
			 }
   "sand003" {
                $baseURL = "https://sand003.insights.health.ge.com:8945"; 
				$access_token = "";
				break
				}
   "sand004" {
               $baseURL = "https://sand004.insights.health.ge.com:8943";
			   $access_token = "";
			   break
			   }
   "sand007" {
              $baseURL = "https://sand007.insights.health.ge.com:8943";
              $access_token = "";	break
			 }
   "sand008" {
               $baseURL = "https://sand008.insights.health.ge.com:8943";
               $access_token = "";
               break
			 }
   "VD" 	 {
		 $baseURL = "https://vdcawd01547.logon.ds.ge.com:8945";
         $access_token = "";
          break
		  }
   default { echo "Invalid hostname $hostName"; exit}
}
