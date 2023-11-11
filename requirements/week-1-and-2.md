# Requirements
For the first and second week’s exercises the following steps must be done before the start:
* Only on Windows, you have to enable running PowerShell scripts - see below for a detailed description, how to do this
* Install Postman (https://www.postman.com/downloads/) if you have no problem registering to their service
  * Otherwise I recommend using Bruno (https://www.usebruno.com/downloads), which does not require registration - about its usage, see the video
* Install Git (https://git-scm.com/downloads)
* Add the git command-line tool to the PATH if it was not done by the installer
  * The folder to add: <path of the installation>/cmd
* Have a GitHub account registered (https://github.com/)
* Install a Git graphical user interface - recommended one is GitHub Desktop, as I will use that during the exercises (https://desktop.github.com/)
  * Note that GitHub Desktop is only available on Windows and MacOS, for Linux you will have to choose a different GUI, see: https://git-scm.com/downloads/guis
  * With GitHub Desktop you can log in to your GitHub account, making authentication easier
* Install Java Development Kit 17 or higher (https://adoptium.net/download/)
* Add the java command-line tool to the PATH if it was not done by the installer
  * The folder to add: <path of the installation>/bin
* Add JAVA_HOME as a global level environment variable pointing to the Java installation folder (<path of the installation>)
* Install Docker, recommended to have Docker Desktop (https://www.docker.com/products/docker-desktop/)
  * On Windows WSL2 is the recommended virtualization technology (Docker will help installing it)
* Add the docker command-line tool to the PATH if it was not done by the installer
  * The folder to add: <path of the installation>/Docker/resources/bin
* Have a command-line / terminal that is comfortable for you ready
  * On Windows it is highly recommend to use PowerShell instead of the conventional cmd tool
  * On Windows it is recommended to use Windows Terminal (https://www.microsoft.com/store/productId/9N0DX20HK701)

# Enable running PowerShell scripts on Windows

By default on Windows one can not run PowerShell scripts (.ps1 files) due to security risks, see [here](https:/go.microsoft.com/fwlink/?LinkID=135170). 
However for this training we have some scripts that will be required for us. Below I list a few options, what can you do. 
You must enter these commands in a PowerShell terminal (can be also from Windows Terminal).

## Enable running all the scripts

If you are not afraid of the security risks of running scripts, you can enable running any scripts for your Windows user:

```
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
```

If you would like to reset this later on, enter:

```
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser
```

## Enable running scripts for the current terminal session

This command will enable running scripts only for the current terminal session - if you open a new window, you have to enter this again:

```
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

If you close the window, this setting will be gone.

# Checking if everything is fine
These steps should be done by you before starting the exercises - if these will work as expected, no problem should occur during the exercise.
* Create a folder where you will work.
* Enter a terminal / command-line prompt to that folder
* Enter the following command: `java -version`
  * It should return something like this: `openjdk version "17.0.5" 2022-10-18` what matters is that it does not show any error, and the first number in the version is 17 or higher
  * If this fails, it means your Java installation is not correct, or java is not added to the PATH
* Enter the following command: `git clone https://github.com/drsylent/cubix-cloudnative-example-springboot`
  * It should not show any errors
  * If this fails, it means your Git installation is not correct, or git is not added to the PATH
* Enter the new folder that was created by this git clone command
* Enter the following command: `./mvnw clean`
  * It should write out multiple lines, at the end there should be a build success text
  * If this fails, it means the JAVA_HOME environment variable is not set up correctly
* Enter the following command: `docker run --rm hello-world`
  * It should write out a hello text message
  * If this fails, it means that maybe you did not start the Docker Desktop / Daemon beforehand, the Docker installation is not correct, or docker is not added to the PATH
* Open the installed Postman or Bruno application
  * It should open without issues - for Postman you will need to create an account to use the functionality we will need
  * If you can not open it, it means the Postman or Bruno installation is not correct
* Enter GitHub: https://github.com/ and create a new repository, which is set to private, and the Add a README file is ticked - the other values do not matter
  * Like this: <img src='/requirements/img/1-privaterepo.png' width='600'>
* Click on Code, and copy the URL
* Open the Git graphical user interface you have chosen, find a button that says clone, paste the copied URL and hit go - if it says you require authentication, follow the instructions
  * With GitHub Desktop, it can be found at the top-left corner: <img src='/requirements/img/1-clone.png' width='600'>
  * There should be no errors, you should see the newly created repository on your computer
  * If it fails, it can mean that the graphical user interface installation is not correct, or check that the authentication works fine

# Helpful links

How to set environment variables (in our case, JAVA_HOME) on your machine:
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
