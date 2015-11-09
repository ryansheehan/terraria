# Terraria

This project is a Dockerfile to containerize [TShock](https://tshock.co/xf/index.php) and [Terraria](https://terraria.org/) TerrariaServer.exe to run on linux.  [Docker](https://www.docker.com/) will remove the need for someone to worry about how to setup a server in linux with all the right dependencies to run.  The installation and usage instructions are written with complete beginners in mind.

## *Quickstart Guide (no need to pull this repository from git!)*

Get a debian/ubuntu based machine.  From the command line:
```
sudo apt-get update
sudo apt-get install docker.io
```

Create a directory for your world file, configuration, and logs
```
mkdir -p $HOME/terraria/world
```

Assuming the docker service is running after the install (you may need to start the service).  Now run docker against the prebuilt image stored on dockerhub

Starting a new world in interactive mode:
```
sudo docker run -it -p 7777:7777 -v $HOME/terraria/world:/world --name="terraria" ryshe/terraria:latest
```
You should have been prompted for what to name your world, and your world should have started.  The world file, configuration files, and logs will all be dropped in your ~/terraria/world folder.  At this point you can type ```exit``` to shut down your server, and change any settings.  If you're happy with the default settings press ctrl-p ctrl-q and it will leave the process running in the background.

Starting your server with a preexisting world:
```
sudo docker run -dit -p 7777:7777 -v $HOME/terraria/world:/world --name="terraria" ryshe/terraria:latest -world /world/<world_file_name>.wld
```
Any configuration file in the directory will automatically be loaded.  The <world_file_name>.wld should be the name of your wld file in your $HOME/terraria/world directory.  This command will launch the docker in the background.  No need to press ctrl-p ctrl-q to escape the server process.

If you get an error from docker saying the container name already exists, it means you need to remove your old docker container process.

you can see the list of docker processes with
```
sudo docker ps -a
```
If you used the same name as the instructions above you should see a process with the name "terraria".  To kill the process:
```
sudo docker rm terraria
```
Now you should be free to run any of the ```sudo docker run``` commands from above.

If you want to reattach to any running containers:
```
sudo docker attach terraria
```
Now you can execute any commands to the terraria server.  Ctrl-p Ctrl-q will detatch you from the process.


Command breakdown:

tell docker you want to run a container
```
sudo docker run
```

tell docker how you want to run the process
```
-dit or -it

d: daemon mode (run the server process in the background so killing your terminal connection wont stop the server)
i: interactive mode (so you can type commands)
t: tty so you can see text from your terminal
```

tell docker how to foward ports from the server to the docker container
```
-p 7777:7777

7777 is the default port terraria works on.

You could run multiple containers with different ports.
for example you could run the docker command with -p 7778:7777 which forwards your server port 7778 to the containers 7777 port.  No need to change your terraria-server's port information
```

tell docker how to map files from your server into docker.  For all intents and purposes you can think of docker as a machine running inside of your server.
```
-v $HOME/terraria/world:/world

v: means "volume"

$HOME is your home directory.  It is a shortcut for /users/<your_user_name>

$HOME/terraria/world  is your server directory
:/world  means map to a folder inside docker at "/world"
```

give docker a name for your process, otherwise docker will give one for you
```
--name="terraria"

gives the container process the name "terraria".  Feel free to change this, and you will need to if running multiple containers.
```

tell docker you want to run the prebuilt container
```
ryshe/terraria:latest

ryshe/terraria is the container
:latest is the tag

there is also the :dev tag which contains a dev build.  Usually this is useful when Re-Logic updates the game and TShock has had a chance to get the new production build ready yet, but they have started work on it.  Use at your own risk, as it can be unstable.  But for those who can't get enough terraria, this might get your server running.
```

tell docker what world file to use.  Just because you mapped the directory, the container doesnt know where to find your file automatically.
```
-world /world/<your_world_file>.wld

because of how the volumes are mapped, your world file in the docker container will always be at /world.  Remember this is the folder inside the docker container.
```

Any additional TerrariaServer.exe command-line commands can be passed at this point.  But your server should be up and running at this point! Enjoy!



## *Installation*
### Setting up your linux machine, and building the docker container from the dockerfile

Provision a linux machine that can support docker and containerization.  For more information visit [docker](https://www.docker.com/).  For a small or medium world with no more than 8 users a linux machine with 1-1.5GB of ram should suffice.  **If you are running a vm in the cloud, make sure to expose tcp port 7777 and udp port 7777.**

These instructions will work for a debian based distro like [ubuntu](http://www.ubuntu.com/).

Before starting the build process make sure the [lastest tshock version](https://github.com/NyxStudios/TShock/releases) is specified in the Dockerfile under
```Dockerfile
ENV TSHOCK_VERSION 4.3.6
ENV TSHOCK_FILE_POSTFIX -pre2
```

1. SSH into your linux machine. Windows users can use [putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)
2. Update your machine ```sudo apt-get update```
3. Install docker and git ```sudo apt-get install docker.io git```
4. Pull this repository ```cd $HOME && git clone https://github.com/ryansheehan/terraria.git```
5. Change to the terraria directory ```cd terraria```
6. Build the docker container ```sudo docker build -t your_name_here/terraria .```
7. Confirm your docker container exists ```sudo docker images```, you should see your_name_here/terraria under the Repository column.

Note: *your_name_here* can be any name you want

## *Usage*

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


## *Notes*
* sudo may not be required if logged into your linux machine as the root user.

* Please check the [tshock instructions](https://tshock.atlassian.net/wiki/display/TSHOCKPLUGINS/Configuration+File+Docs) for properly installing and configuring your terraria server.  You can find your configuration files in the ```cd $HOME/terraria/world``` directory.

* Any [additional command-line instructions](https://tshock.atlassian.net/wiki/display/TSHOCKPLUGINS/Command+Line+Parameters) can be added to the end of either method for launching a server.  Docker maps the $HOME/terraria/world linux-host folder to the /tshock/world container-folder.

## *Contributing*

Email me rsheehan at gmail dot com if any of these instructions do not seem to work.  I am by far not very familiar with linux or docker, but I will do what I can to maintain this information.

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## *TODO*

* Fork TShock and create a Dockerfile to build the project
