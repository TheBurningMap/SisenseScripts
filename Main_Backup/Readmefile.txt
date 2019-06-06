1. Configuration File
dashboards.conf (User has to update config file)
hostName - From which environment dashboards has to be integrated to GIT
example: hostName=demo001
gitfolder - User can integrate dashboards to specific folder on GIT
example: gitfolder=Dashboards
gitrepo- User should provide git repo URL
example: gitrepo="git@github.build.ge.com:SSO(or)Org name/repo_name.git"
gitbranch- User should provide GIT branch name
example: gitbranch="develop"
dashList- dash list if specific list of dashboards to be integrated to GIT (Specify dashboardId list seperated by ',')(This field need to be configured only when running "pushSpecificDash.ps1")
example: dashList=dashboardId or dashList=dashboardId,dashboardId

2.
Scripts names                  Usage                                                                                      

hosts.ps1-                     User should update hosts.ps1 by providing environment name, baseURL and access_token
                               Example:
							   "beta002" {
				               $baseURL = "https://beta002.insights.health.ge.com:8945";
				               $access_token = "<Copy access_token here>";
				               break
			                   }
exportDash_MIT.ps1-            User can select and integrate one or multiple dashboards to GIT by providing dashboardId as an input
getSisenseDash_Test_old.ps1-   User can integrate all dashboards to GIT in a single shot. i.e., Using this script all dashboards on environment will be intergrated to GIT withoug passing any inputs
pushSpecificDash.ps1-          User can integrate dashboards to GIT by specifying list of dashboard ID's. Please update "dashList" field in "dashboards.conf" file with dashboard ID's list sperated by comma ','. For example please refer above "dashList" field in the Configuration File section
syncDashboards.ps1-            User can syncDashboads on GIT with Sisense if anydashboard is missing on sisense you will be promted to purge or preserve
recommit.ps1-                  User can recommit the dashboards on GIT (It will check with Sisense for dashboard changes if there are any changes only those dashboards will be updated to GIT) recommit script to sycn only already existing dashboards to git if any updates on Sisense
deleteDash.ps1-                User can delete selected dashboard on Sisense by providing dashboardId as an input and it will automatically delete that particular .dash from GIT.





















# hostname property
hostName=demo001
# Folder Name
gitfolder=
# git repo to integrate dashboards
gitrepo="git@github.build.ge.com:502768000/Applied_Intelligence.git"
# git branch name
gitbranch="develop"
# dash list if specific list of dashboards to be synced (This field need to be configured only when running "pushSpecificDash.ps1")
dashList=