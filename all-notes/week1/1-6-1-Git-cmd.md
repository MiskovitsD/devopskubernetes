# Create local repository

First find a folder, where we will create our repository.

```shell
git init local-tutorial
cd local-tutorial
```

# Check the branch that was created

```shell
git status
```

A default was created: master or main. Some commands wont work as expected because no commits have been made yet:

```shell
git log
```

# Create a file and commit it

```shell
echo Hello! > hello.txt
git add hello.txt
git status
git commit -m "Hello message"
```
If there was no setting for user's name and email:

```shell
git config user.email
git config user.name
```

# Check the log

```shell
git status
git log
```

We have the commit hash and message

# Create a new branch and check it out

```shell
git checkout -b test
git branch -l
```

# Create a new file and modify the existing one, and commit

```shell
echo New file > new.txt
echo Hello from another branch > hello.txt
git status
git add .
git status
git commit -m "Modification and new file"
```

# Merge this to the master/main branch

```shell
git checkout master
git merge test
ls
cat hello.txt
```

We have the new file.

# Create a new branch but dont check it out

```shell
git branch conflict
git log
```

# Create a new file, modify both existing ones and commit

```shell
echo Will this cause conflict? > conflict.txt
echo master hello! > hello.txt
echo changed on master > new.txt
```

We can use -a for automatically adding files to the index.

```shell
git commit -a -m “This will cause conflicts - from master”
```

Note - the new file (conflict.txt) was not added

```shell
git add .
git commit -m "New file created on master"
```

# Check out our new branch, create a new file, modify one of the existing ones and commit

```shell
git checkout conflict
echo Will this cause conflict? > conflict-branch.txt
echo conflict hello! > hello.txt
git add .
git commit -m "Create conflict from the conflict branch with this commit"
```

# Try and merge the new branch to the master! If there are conflicts, both changes should remain one after the other!

```shell
git checkout master
git merge conflict
git status
```

Open the conflicting file in a text editor! Delete the signs.

HEAD is a pointer to our currently checked out reference - it can be a branch (like now, master) or just a commit.

```shell
git add .
git commit -m "Resolve conflict"
git status
```

Is it done now, is it merged?
