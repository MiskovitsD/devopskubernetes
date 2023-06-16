# Requirements
TODO for Kubernetes environment setup

# Checking if everything is fine
TODO for Kubernetes environment checkup

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
