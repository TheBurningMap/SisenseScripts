$hostName=$args[0]
switch ($hostName) {
   "sand213.insights.health.ge.com" {
				$baseURL = "https://sand213.insights.health.ge.com:8943";
				$access_token = "";
				break
			}
   "sand210.insights.health.ge.com" {
                 $baseURL = "https://sand210.insights.health.ge.com:8943"; 
				 $access_token = "";
				 break
				 }
   "demo001.insights.health.ge.com" {
				$baseURL = "https://demo001.insights.health.ge.com:8943"; 
				$access_token = "<GENERATE access_token and copy here>";
				break
			}
   "demo002.insights.health.ge.com" {
				$baseURL = "https://demo002.insights.health.ge.com:8945";
				$access_token = "";
				break
			}
   "sand009.insights.health.ge.com" {
              $baseURL = "https://sand009.insights.health.ge.com:8943";
              $access_token = "<GENERATE access_token and copy here>";			  
			  break
			 }
   default { echo "Invalid hostname $hostName"; exit}
}