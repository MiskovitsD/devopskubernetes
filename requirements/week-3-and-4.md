# Requirements
For the third week’s exercises the following steps must be done before the start:
* Install the kubectl CLI tool and add it to the PATH
  * If you installed Docker Desktop on Windows, probably you already have it installed and added to the PATH - see check section to see if this is the case for you
  * If not, you can download it from here: https://kubernetes.io/docs/tasks/tools/#kubectl - follow the instructions for your operating system
  * Do not forget to add it to the PATH - the name of the executable must be `kubectl`
* Install the kind CLI tool and add it to the PATH
  * Follow one of the instructions listed here that seems good for you: https://kind.sigs.k8s.io/docs/user/quick-start/#installation
  * The release binaries can be the simplest way if you do not have any package managers: https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries
  * Do not forget to add it to the PATH - the name of the executable must be `kind`
  * You do not have to create a cluster - we will create one by our own rules
* Install the helm CLI tool and add it to the PATH
  * Follow one of the instructions listed here that seems good for you: https://helm.sh/docs/intro/install/
  * The first option, release binaries can be the simplest way if you do not have any package managers: https://helm.sh/docs/intro/install/#from-the-binary-releases
  * Do not forget to add it to the PATH - the name of the executable must be `helm`
* You have to add three entries to your hosts file (see below for help about this)
  * `127.0.0.1 application.cubix.localhost`
  * `127.0.0.1 other.cubix.localhost`
  * `127.0.0.1 grafana.cubix.localhost`
  * You can do this manually, or by running the provided [script](/requirements/scripts/3-1-hosts-file-extending) - you need administrator/root/sudo rights to run it
* Start Kubernetes cluster
  * there is a detailed description about this below, but first check the other tools

# Checking if everything is fine (except the Kubernetes cluster)
* Open a terminal / command-line prompt (the location does not matter)
* Enter the following command: `kubectl version --client`
  * You may have already done this according to the description provided by the installation website
  * You should get a few lines of information, including a `Client version` and a `Kustomize version`
  * If this fails, it means your kubectl installation is not correct, or kubectl is not added to the PATH
* Enter the following command: `kind version`
  * You should get a line something like this: `kind v0.17.0 go1.19.3 windows/amd64` (the version may differ)
  * If this fails, it means your kind installation is not correct, or kind is not added to the PATH
* Enter the following command: `helm version`
  * You should get a line which starts with `version.BuildInfo`
  * If this fails, it means your helm installation is not correct, or helm is not added to the PATH
* Check the contents of the hosts file
  * On Windows (with PowerShell): `cat C:\Windows\System32\drivers\etc\hosts`
  * On MacOS or Linux: `cat /etc/hosts`
  * The result must include the three lines that we added (an IP address and a hostname, separated by a space)

# Starting the Kubernetes cluster

* Open a terminal / command-line prompt where cluster starting scripts are available for your platform (under requirements/scripts/3-2-cluster-start)
  * for [Windows/PowerShell](/requirements/scripts/3-2-cluster-start/windows)
  * for [Linux/MacOS/Shell](/requirements/scripts/3-2-cluster-start/macos-linux)
* The `create` script will create and start up the cluster
  * Note - from now on, up until you delete the cluster, it will start up together with Docker and will occupy the 8080 port on your machine
  * If all the above checks go well but this fails, please reach out to me
* Wait a few minutes, then the `test` script will check if an example service can be created and called
  * It will clean up everything needed for the test
  * If it fails first, try again a bit later
  * If all the above checks go well but this fails even after a first try and after 5 minutes, please reach out to me

# Helpful links

How to edit the hosts file:
* Recommended for our training: use the provided script in the requirements/scripts/3-1-hosts-file-extending folder
  * Has a different script for Windows and MacOS/Linux - use the appropriate one for your system
  * If this does not work, reach out to me or try it manually, as described below
* Windows: 
  * it can be found at `C:\Windows\System32\drivers\etc\hosts` location
  * you have to edit it with a program running with administrator rights
* MacOS and Linux:
  * it can be found at `/etc/hosts` location
  * you have to edit it with a program running with root/sudo rights
* a more detailed description can be found here: https://www.howtogeek.com/27350/beginner-geek-how-to-edit-your-hosts-file/

How to set environment variables on your machine:
* Windows: follow the steps below
  * open the Start menu, and type in: environment variable (in Hungarian: környezeti változó)
  * open the result, and click on the environment variables button
  * You should see something like this: <img src='/requirements/img/1-env.png' width='400'>
  * Add a new one to the top, account level ones, and enter the name and the value of the environment variable
* Linux and MacOS: https://linuxize.com/post/how-to-set-and-list-environment-variables-in-linux/#persistent-environment-variables use the one that requires the modification of ~/.bashrc

How to modify the PATH on your machine:
* Windows: go to the same window as with the environment variables and modify the account level PATH variable
  * Add a new entry here: <img src='/requirements/img/1-path.png' width='400'>
* Linux and MacOS: do an environment variable setting as previously, and add something new to the path like this: `export PATH="$PATH:<path to add>"`
