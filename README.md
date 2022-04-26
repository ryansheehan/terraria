# Terraria

**[UPDATE]** I know a lot of people are excited for Terraria v1.4 Journey's End!  This source code is built around the pre-release
of [TShock][TShock].  Will continue to update as new releases come out.

This project is a Dockerfile to containerize [TShock][TShock] and [Terraria](https://terraria.org/) TerrariaServer.exe to run on linux.  [Docker][Docker] will remove the need for someone to worry about how to setup a server in linux with all the right dependencies to run.  The installation and usage instructions are written with complete beginners in mind.

## Quick start guide

First you need a linux machine with [Docker][Docker] installed. Everything from here on out assumes the docker service is running _(you may need to start the service after install)_.

### Create directory to save your world to

Next create a directory for your world file, configuration, and logs

```bash
mkdir -p $HOME/terraria/world
```

### Creating a fresh world

For the first run you will need to generate a new world with a size where: _1=Small, 2=Medium, 3=Large_

```bash
sudo docker run -it -p 7777:7777 --rm -v $HOME/terraria/world:/root/.local/share/Terraria/Worlds ryshe/terraria:latest -world /root/.local/share/Terraria/Worlds/<world_name_here>.wld -autocreate <world_size_number_here>
```

**Note:** If you close the the terminal, the server will stop running.  You will need to restart with a preexisting world. It may
be worth while to close after creation anyway to update the initial `config.json` settings.

To create a world with a few more initial options, you can do so in an interactive mode.

```bash
sudo docker run -it -p 7777:7777 --rm -v $HOME/terraria/world:/root/.local/share/Terraria/Worlds ryshe/terraria:latest
```

### To start with a preexisting world

```bash
sudo docker run -d --rm -p 7777:7777 -v $HOME/terraria/world:/root/.local/share/Terraria/Worlds --name="terraria" -e WORLD_FILENAME=<.wld world_filename_here> ryshe/terraria:latest
```

**Note:** This command is designed to run in the background, and it is safe to close the terminal window.

Any `config.json` in the directory will automatically be loaded.  The `<world_file_name>.wld` should be the name of your wld file in your $HOME/terraria/world directory.

## Updating your container

Updating is easy!

1. Grab the latest terraria container

    ```bash
    docker pull ryshe/terraria:latest
    ```

2. First we need to find our running container to stop, so we can later restart with the latest

    ```bash
    docker container ls | grep ryshe/terraria
    ```

    The first few numbers and letters, on a line, are the container hash.  Remember the first 3 or so letters or numbers

    Example:

    ```bash
    f25261ac55a4        ryshe/terraria:latest   "/bin/sh bootstrap.s…"   3 minutes ago       Up 3 minutes        0.0.0.0:7777->7777/tcp, 7878/tcp   reverent_solomon
    ```

    `f25` would be the first few letters/numbers of the container hash

    **NOTE:** If you see multiple lines, find the one that still has an `up` status.

3. Stop and remove the container

    ```bash
    docker container rm -f xxx # xxx is the letters/numbers from the last step
    ```

4. Start your container again with your world _(see the [Quick start](#Quick-start-guide))_

## [Virtual] Machine Setup

Provision a linux machine that can support docker and containerization.  For more information visit [docker][Docker].  For a small or medium world with no more than 8 users a linux machine with 1-1.5GB of ram should suffice.  **If you are running a vm in the cloud, make sure to expose tcp port 7777 and udp port 7777.**

Before starting the build process make sure the [latest tshock version][TShock] is specified in the [Dockerfile](https://github.com/ryansheehan/terraria/blob/master/Dockerfile) under

```Dockerfile
ADD https://github.com/Pryaxis/TShock/releases/download/v4.4.0-pre1/TShock_4.4.0_226_Pre1_Terraria1.4.0.2.zip /
```

## Building from source

Assuming [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [docker][Docker] are installed..

1. Clone this repository

    ```bash
    git clone https://github.com/ryansheehan/terraria.git
    ```

2. Open a terminal window into the directory downloaded by the git
3. Build the container

    ```bash
    docker build -t <name_here> .
    ```

## Running a container image

Whether you build your own container, or use [my container](https://hub.docker.com/r/ryshe/terraria) published to docker hub,
we are ready to run our terraria server!

**Note:** For a full set of docker run options go [here](https://docs.docker.com/engine/reference/run/)

### First run

The first run of the server will give you the opportunity to create a world, and it will generate
the server's config file.  You may wish to add the config file for many reasons, but one of which is to
add a password to your server.

```bash
docker run -it --rm -p 7777:7777 -v $HOME/terraria/world:/root/.local/share/Terraria/Worlds ryshe/terraria:latest
```

Let's break down this command:

| Command Part | Description |
| ------------ | ----------- |
| `docker run` | tells linux to run a docker image |
| `-it` | run interactively and output the text to terminal |
| `--rm` | remove docker container when the container stops or fails |
| `-p 7777:7777` | exposes terraria port &lt;host machine side>:&lt;container side> |
| `-v $HOME/terraria/world:/root/.local/share/Terraria/Worlds` | maps a folder on the host machine into the container for saving the .wld file.  This does not have to be `$HOME/terraria/world`.  Anything left of the `:` is host machine directory |
| `ryshe/terraria` | the name of the image. This could be your image if you build from source |
| `:latest` | the tag, which defaults to `latest` if not specified.  `latest` is the most recently published container |

* The config file can be found in the directory specified by the `-v` volume.
* If the terminal window is shut down, that will exit the process.  Make sure to do so after the world is created!

### Running with an existing generated world

After a world has been generated, you may want to load directly into it.

```bash
docker run -d --rm -p 7777:7777 -v $HOME/terraria/world:/root/.local/share/Terraria/Worlds ryshe/terraria:latest -world /root/.local/share/Terraria/Worlds/<world_filename_here>.wld
```

Let's break down the command:

| Command Part | Description |
| ------------ | ----------- |
| `-d` | run this in the background.  It is okay to close the terminal window, the container will continue to run |
| `-world /root/.local/share/Terraria/Worlds/<world_filename_here>.wld` | specifies the world file name you wish to immediately load into |

* for the other parts check out the [First run](#First-run) section
* check out additional server startup flags [here](https://tshock.readme.io/docs/command-line-parameters).  They go on
after the `ryshe/terraria:latest` portion of the line

## Plugin support

A volume exists to support plugins.  Create a folder, not inside your `/world` folder, for your plugins

```bash
mkdir ServerPlugins
```

Mount the plugins directory with an additional -v switch on your `docker run ...` command

```bash
-v <path_to_your_ServerPlugins_folder>:/plugins
```

## Environment variables

**Vanilla**

Ability to overwrite file locations and file names

```bash
ENV LOGPATH=/terraria-server/logs
ENV WORLDPATH=/root/.local/share/Terraria/Worlds
ENV WORLD_FILENAME=""
ENV CONFIGPATH=/config
ENV CONFIG_FILENAME="serverconfig.txt"
```

## Logs

A separate directory can be volumed in for storing logs outside of the image

```bash
-v <path_to_store_logs>:/tshock/logs
```

## *Notes*

* `sudo` may be required to run docker commands.

* Please post to the [TShock](https://github.com/Pryaxis/TShock/discussions) team with questions on how to run a server.

* Any [additional command-line instructions](https://tshock.readme.io/docs/command-line-parameters) can be added to the end of either method for launching a server.  Docker maps the $HOME/terraria/world linux-host folder to the /tshock/world container-folder.

* Expecting your server to run for a while?  Add `--log-opt max-size=200k` to limit your log file size.  Otherwise one day you will wake up to see all your hdd space chewed up for a terraria docker setup!

## *Contributing*

Email me rsheehan at gmail dot com if any of these instructions do not seem to work.

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## *TODO*

* Fork TShock and create a Dockerfile to build the project

[TShock]: https://github.com/Pryaxis/TShock/releases
[Docker]: https://docs.docker.com/get-docker/
