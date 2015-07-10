# Terraria

This project is a Dockerfile to containerize [TShock](https://tshock.co/xf/index.php) and [Terraria](https://terraria.org/) TerrariaServer.exe to run on linux.  [Docker](https://www.docker.com/) will remove the need for someone to worry about how to setup a server in linux with all the right dependencies to run.  The installation and usage instructions are written with complete beginners in mind.

## Installation

Provision a linux machine that can support docker and containerization.  For more information visit [docker](https://www.docker.com/).  For a small or medium world with no more than 8 users a linux machine with 1-1.5GB of ram should suffice.  **If you are running a vm in the cloud, make sure to expose tcp port 7777 and udp port 7777.**

These instructions will work for a debian based distro like [ubuntu](http://www.ubuntu.com/).

Before starting the build process make sure the [lastest tshock version](https://github.com/NyxStudios/TShock/releases) is specified in the Dockerfile under
```Dockerfile
ENV TSHOCK_VERSION 4.3.1
ENV TSHOCK_FILE_POSTFIX _pre1
```

1. SSH into your linux machine. Windows users can use [putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)
2. Update your machine ```sudo apt-get update```
3. Install docker and git ```sudo apt-get install docker.io git```
4. Pull this repository ```cd $HOME && git clone https://github.com/ryansheehan/terraria.git```
5. Change to the terraria directory ```cd terraria```
6. Build the docker container ```sudo docker build -t your_name_here/terraria .```
7. Confirm your docker container exists ```sudo docker images```, you should see your_name_here/terraria under the Repository column.

Note: *your_name_here* can be any name you want

## Usage

Now that the docker container is built it is time to run it!  For a full set of docker commands go (here)[https://docs.docker.com/reference/run/]

### Make a folder to hold your world data, configuration, and logs
```
mkdir -p $HOME/terraria/world
```


### For an interactive first time run
```
sudo docker run -it --name="make_up_a_name" -p 7777:7777 -v $HOME/terraria/world:/world your_name_here/terraria
```
this will walk you through creating your first world, and generate all your config files.  *make_up_a_name* is just a name you attach to the running container.  You will need to reference this when attaching to a background running container, or killing the docker process


### To push the application into the background
press CTRL-p CTRL-q.  Now you should be able to end your ssh session without it killing the terraria server


### To start your server in the background
```
sudo docker run -dit --name="make_up_a_name" -p 7777:7777 -v $HOME/terraria/world:/world your_name_here/terraria -world /world/your_world_name.wld
```
where *your_world_name* is the name of the world you chose during the creation process


### To attach to a server that is currently in the background
```
sudo docker attach your_docker_process_name
```
*your_docker_process_name* references the --name="make_up_a_name" from starting the server.  Once attached to the docker process you can issue commands to tshock.  Type help for those options, or reference [tshock commands](https://tshock.atlassian.net/wiki/pages/viewpage.action?pageId=3047433)


### To kill a docker process
If for whatever reason you get an error because the process --name already exists, or you want to kill the docker process:
```
sudo docker rm your_process_name
```
where *your_process_name* is the same as what was defined by the --name argument when starting the server


### To check a list of processes running in docker
```
sudo docker ps -a
```

## Plugin Support
A volume exists to support plugins.  In your world directory create a new directory to hold all the plugins.
```
mkdir ServerPlugins
```

**WARNING**
If you want to maintain any of the plugins that ship with tshock, you will need to copy them into the ServerPlugins folder.  Mounting the plugins folder will override the plugins that ship with tshock.

To mount the server plugins add the after the -v switch that mounts the world directory
```
-v <path_to_your_ServerPlugins_folder>:/tshock/ServerPlugins
```


## Notes
* sudo may not be required if logged into your linux machine as the root user.

* Please check the [tshock instructions](https://tshock.atlassian.net/wiki/display/TSHOCKPLUGINS/Configuration+File+Docs) for properly installing and configuring your terraria server.  You can find your configuration files in the ```cd $HOME/terraria/world``` directory.

* Any [additional command-line instructions](https://tshock.atlassian.net/wiki/display/TSHOCKPLUGINS/Command+Line+Parameters) can be added to the end of either method for launching a server.  Docker maps the $HOME/terraria/world linux-host folder to the /tshock/world container-folder.

## Contributing

Email me rsheehan at gmail dot com if any of these instructions do not seem to work.  I am by far not very familiar with linux or docker, but I will do what I can to maintain this information.

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## TODO

* Commit container to docker hub
* Write instructions on how to pull a prebuilt image stored on docker hub and launch a terraria server
