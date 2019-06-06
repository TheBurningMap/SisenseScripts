$hostName=$args[0]
switch ($hostName) {
   "sand213.insights.health.ge.com" {
				$baseURL = "https://sand213.insights.health.ge.com:8943";
				$access_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiNWI3MmZlYjgzOTE0YTkxZWEwZGQwZjRjIiwiYXBpU2VjcmV0IjoiZTJiMjI4MzUtZjNhNi0yY2FlLTg3ZGUtMTJmMTZlZWU4ZGQ2IiwiaWF0IjoxNTQyNjUzMDcyfQ.wa2FFlhmW8H883_ZdMrSl9xfEGXCMh--WqvyoRmMDQ8";
				break
			}
   "sand210.insights.health.ge.com" {
                 $baseURL = "https://sand210.insights.health.ge.com:8943"; 
				 $access_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiNTllN2MyNGY2NzFlNGZmY2E1NmJmNmIzIiwiYXBpU2VjcmV0IjoiODRkZWUwNWYtZGMxMy1lNmExLTU0YWYtZTdkMzYzNGFhMDdmIiwiaWF0IjoxNTQyNjYwODcxfQ.xZYwzxWX8iw9XYl3PzD8NmpYeoPXlPZ9qZfTShuJt7Q";
				 break
				 }
   "demo001.insights.health.ge.com" {
				$baseURL = "https://demo001.insights.health.ge.com:8943"; 
				$access_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiNWEzMjFkOTIzMTA2ZDgwNGQyNjViM2FiIiwiYXBpU2VjcmV0IjoiZTAxODhhZmUtZTc1MS03NmMwLTczOGEtYjc1ODFjMzRkMjliIiwiaWF0IjoxNTM3MzEzMjM1fQ.TCA6fImp4vYUlHYAvNGxckB1rqSpLc1IvvQW226EFG8";
				break
			}
   "demo002.insights.health.ge.com" {
				$baseURL = "https://demo002.insights.health.ge.com:8943";
				$access_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiNTlkNTQ5NmVhZmYwNmJkMWYzMTdlODFlIiwiYXBpU2VjcmV0IjoiOGFiZjU2ZWYtNjgyNC1kNDI2LTZiZTAtMWQyMzUyMzE0OTJjIiwiaWF0IjoxNTQyODM5OTY2fQ.NhwtREIQ3pSsWoAlAwqEAhswZRkexg0piBECFmUDQ2c";
				break
			}
   "sand009.insights.health.ge.com" {
              $baseURL = "https://sand009.insights.health.ge.com:8943";
              $access_token = "<GENERATE access_token and copy here>";			  
			  break
			 }
   default { echo "Invalid hostname $hostName"; exit}
}
