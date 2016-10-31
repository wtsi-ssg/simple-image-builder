# Example Image builder

These are scripts to build a Ubuntu 14.04,16.04 and Centos 7.2 image for Openstack.

The system is controlled via variables.json and .gitlab-ci.yml and finally the variables configured by the repository.

The expectation is that this repository will be used as a basis for a groups work, here is an example of using it as a basis for a new task.

Use gitlab to create a new project in this case jb23_play


```
14:15 ~/src/git $ git clone git@gitlab.internal.sanger.ac.uk:jb23/play.git
Cloning into 'play'...
warning: You appear to have cloned an empty repository.
Checking connectivity... done.
```

Now add this repository as a remote

```
14:16 ~/src/git $ cd play/
14:16 ~/src/git/play (master)$ git remote add ISG_SOURCE git@gitlab.internal.sanger.ac.uk:sciaas/simple-image-builder.git
14:17 ~/src/git/play (master)$ git remote -v
ISG_SOURCE	git@gitlab.internal.sanger.ac.uk:sciaas/simple-image-builder.git (fetch)
ISG_SOURCE	git@gitlab.internal.sanger.ac.uk:sciaas/simple-image-builder.git (push)
origin	git@gitlab.internal.sanger.ac.uk:jb23/play.git (fetch)
origin	git@gitlab.internal.sanger.ac.uk:jb23/play.git (push)
```

Now pull the example down.

```
14:18 ~/src/git/play (master)$ git pull  ISG_SOURCE master
remote: Counting objects: 638, done.
remote: Compressing objects: 100% (226/226), done.
remote: Total 638 (delta 301), reused 627 (delta 295)
Receiving objects: 100% (638/638), 123.93 KiB | 0 bytes/s, done.
Resolving deltas: 100% (301/301), done.
From gitlab.internal.sanger.ac.uk:sciaas/simple-image-builder
 * branch            master     -> FETCH_HEAD
 * [new branch]      master     -> ISG_SOURCE/master
14:18 ~/src/git/play (master)$ ls -l
total 20
lrwxrwxrwx 1 james james   29 Oct 31 14:18 ansible -> image-creation/packer/ansible
lrwxrwxrwx 1 james james   27 Oct 31 14:18 bootstrap.sh -> image-creation/bootstrap.sh
lrwxrwxrwx 1 james james   32 Oct 31 14:18 cleanup.py -> image-creation/packer/cleanup.py
lrwxrwxrwx 1 james james   37 Oct 31 14:18 create_image.py -> image-creation/packer/create_image.py
drwxrwxr-x 5 james james 4096 Oct 31 14:18 image-creation
lrwxrwxrwx 1 james james   33 Oct 31 14:18 kitchen_wrapper.sh -> image-creation/kitchen_wrapper.sh
-rw-rw-r-- 1 james james 1192 Oct 31 14:18 README.md
lrwxrwxrwx 1 james james   45 Oct 31 14:18 remove_failed_builds.py -> image-creation/packer/remove_failed_builds.py
drwxrwxr-x 2 james james 4096 Oct 31 14:18 scripts
lrwxrwxrwx 1 james james   52 Oct 31 14:18 template-openstack-centos.json -> image-creation/packer/template-openstack-centos.json
lrwxrwxrwx 1 james james   52 Oct 31 14:18 template-openstack-ubuntu.json -> image-creation/packer/template-openstack-ubuntu.json
drwxrwxr-x 3 james james 4096 Oct 31 14:18 test
-rw-rw-r-- 1 james james  644 Oct 31 14:18 variables.json
```

Ensure the variables are defined ( in gitlab, see image below ):

<kbd>![ Image showing menu ] ( https://gitlab.internal.sanger.ac.uk/sciaas/simple-image-builder/raw/master/docs/variables%20menu.png )</kbd>

OS_TENANT_NAME which should be set to the tenant, each group should have their own tenant for ci jobs.

OS_USERNAME this should normally be the same as the OS_TENANT by convention

OS_PASSWORD this is the password for the OS_USERNAME


Then push you master branch to origin and see if the ci builds an image for you. Once that works you can move on towards customising it.

```
14:27 ~/src/git/play (master)$ git push origin master
Counting objects: 638, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (220/220), done.
Writing objects: 100% (638/638), 123.93 KiB | 0 bytes/s, done.
Total 638 (delta 301), reused 638 (delta 301)
To git@gitlab.internal.sanger.ac.uk:jb23/play.git
 * [new branch]      master -> master
```

When there are later releases these can be pulled on to a feature branch so that you can take advantage of them.

There is a branch named vmware which extends the system to support vmware if you need to use this come and talk to us.

## extra_script

An additional script to run to configure this image - this script must exist, if no additional customization is required this should be a "NOOP" script

## scripts

This directory contains the scripts used additional software. 

## ansible

This directory by default is linked to the image-creation repository, if you wish to use ansible to configure you system then you will need to remove the symbolic link and copy the contents of image-creation/packer/ansible to ansible and then make changes. If additional roles are required they should be listed in variables.json as a role_path


