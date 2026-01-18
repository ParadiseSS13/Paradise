# Docker

Docker provides an alternative environment for developing, building, testing,
and running software like Paradise. Keep reading to learn more.

## Quickstart

You just want to jump right into the thick of things? Awesome...

    tools/docker/build
    tools/docker/init-db
    cp config/example/config.toml config/config.toml
    cat secret/db-ss13-password.txt
    nano config/config.toml
    # --- edit 4 fields in [database_configuration] ---
    # sql_enabled = true
    # sql_address = "paradise_db"
    # sql_username = "ss13"
    # sql_password = "<insert secret/db-ss13-password.txt here>"
    tools/docker/run
    # --- connect: byond://<your-ip>:6666/ ---

Welcome to the station crew, enjoy your stay.

## Helpful Background

In order to get the most benefit out of this, you should probably have a few
things already set up:

- You should be able to run commands in a terminal window
- You need Docker installed and permissions to run it

On many distros, you will need to add your user to the `docker` group, and
perhaps login again in order to pick up the permissions change. Check the
instructions for installing Docker on your platform to verify what is needed.

If you don't know this stuff yet, that's OK. Ask around if anybody has
experience with Linux and/or Docker. Look up some tutorials online. Everybody
starts somewhere, and this could be where you start.

### Motivation for Using Docker with Paradise

Paradise is a complex service with many moving parts. Database, NanoMaps, Rust
libraries, TGUI, and the DreamMaker binary. The maintainers do a good job of
providing pre-baked dependencies for most of these. Advanced developers need to
learn how to compile Rust libraries and TGUI for themselves. This involves
installing other software like Node.js and Rust, then learning the special
commands to make things build. It is a complex task to learn everything that
goes into it.

What if it could be simple? What if you could rebuild a Paradise server image
from scratch with just one command?

    tools/docker/build

Changed Rust libraries? Great, it'll recompile them. Changed TGUI stuff?
Great, it'll recompile that too. Changed the code? Great, it'll regenerate
the NanoMaps and build the game with DreamMaker. You'll create a new Docker
image for Paradise, complete and ready to test immediately.

    tools/docker/run

There is a little more to it in practice. If you want to actually play on your
new server, you'll have to point BYOND at your machine. This means you need to
discover the IP address of your Linux machine on your network (`hostname -I`)
and feed it to BYOND like: `byond://192.168.0.xxx:6666/`. My network assigned
my machine `192.168.0.104` but you'll need to find yours for yourself!

### Fantastic Scripts and Where To Run Them

This repository contains several scripts in the `tools/docker` folder. These
scripts are intended as basic tools to get you set up, initialized, building,
and running with a minimum of effort and hassle.

Some of the names `paradise`, `paradise_db`, `paradise_db_data`, `paradise_net`
are baked into the scripts. If you want to run more than one database and more
than one server on the same machine (and yes, this is possible!), you'll need
to make some modifications to the scripts to make that happen.

In all cases, you should be running the scripts from the root of the
repository. That is, if you unzipped the source code into a folder, or if you
cloned the source repository from GitHub, you'll probably have a folder called
`Paradise`. That's where you should be when you run the scripts.

You invoke a script like so:

    tools/docker/build

Don't change into subdirectories or run the scripts from other locations.

Most of the scripts have some checks built in, to make sure things that need to
be created have been created, and things that need to be running are running.
The only truly dangerous script is:

    tools/docker/zzz-destroy-everything-zzz

If you invoke that, you will delete everything these scripts have done. Any
changes or other hard work you did will be permanently gone! Be careful!

## Docker Utility Scripts

There are eight utility scripts provided in the `tools/docker` folder. They
are:

- `backup-db`: Create a backup file of a running database container
- `build`: Build the `paradise:latest` Docker image
- `debug-db`: Get a MariaDB shell into a running database container
- `debug-server`: Create a server container, but run a bash shell instead of DreamDaemon
- `init-db`: Create a `paradise_db` database container and initialize it
- `restore-db`: Restore from backup file into a running database container
- `run`: Create a server container and run DreamDaemon
- `zzz-destroy-everything-zzz`: Delete all Paradise containers, images, networks, and volumes

## Creating a Local Paradise Server

This section will cover setting up a local Paradise server. You can use it to
test code that you're developing, practice making maxcap bombs that you could
never get away with on the real Paradise, or whatever you like.

### Building a Docker Image for Paradise

In order to create a Docker image, there must be a set of instructions for how
that image should be created. This blueprint for making an image is called a
`Dockerfile`. You can find the `Dockerfile` used to build the Paradise image
in the root (top level) of the codebase.

Docker uses a multi-stage build. This builds up each thing (NanoMaps, Rust
libraries, TGUI, the DreamMaker binary) in turn, then combines them all into a
final image. This image will be used to create server containers when you're
ready to run the software.

There is a script provided in the codebase to run this build command:

    tools/docker/build

The first time you build, it may take several minutes to finish building.
Future builds will not take nearly as long, because Docker will remember the
intermediate steps in a cache, and re-use the result if nothing has changed
since the last time.

After the command is done, you can see your new Docker image by issuing the
command:

    docker image ls

You should see something like this:

    tux@linuxbox:~/Paradise$ docker image ls
    IMAGE                            ID             DISK USAGE   CONTENT SIZE
    paradise:latest                  bee29cf62073        398MB             0B

Note that our server image is named `paradise:latest`.

### Creating the Database Container

This is a script provided in the codebase to create and initialize a database
container:

    tools/docker/init-db

That will grab the MariaDB image from Docker Hub, and use it to create a new
container with the MariaDB database software. It also does several other things
so we'll go over those one by one.

Here you can run a command to see the container in action:

    docker ps --all

You should see something like this:

    tux@linuxbox:~/Paradise$ docker ps --all
    CONTAINER ID   IMAGE        COMMAND                 CREATED       STATUS         PORTS      NAMES
    4aa9b04f056b   mariadb:12   "docker-entrypoint.s"   3 hours ago   Up 3 seconds   3306/tcp   paradise_db

Now we're ready to talk about the other things that `tools/docker/init-db` did
behind the scenes.

#### Paradise Database Data Volume

Docker containers are ephemeral things; they are meant to be created and
destroyed quite often, and not good or safe homes for things we want to keep.

A database stores information that we want to keep around for an indefinite
period of time. So instead of allowing the database files to live in the
database container, the `init-db` script will create a Docker volume named
`paradise_db_data`. The volume is attached to a database container when that
container is created.

You can see the new `paradise_db_data` volume with this command:

    docker volume ls

You should see something like:

    tux@linuxbox:~/Paradise$ docker volume ls
    DRIVER    VOLUME NAME
    local     paradise_db_data

If you want to know where those database files actually live on disk, you can
use the following command:

    docker volume inspect paradise_db_data

You should see something like:

    tux@linuxbox:~/Paradise$ docker volume inspect paradise_db_data
    [
        {
            "CreatedAt": "2026-01-16T21:39:10-06:00",
            "Driver": "local",
            "Labels": null,
            "Mountpoint": "/home/tux/.local/share/docker/volumes/paradise_db_data/_data",
            "Name": "paradise_db_data",
            "Options": null,
            "Scope": "local"
        }
    ]

Here we see `/home/tux/.local/share/docker/volumes/paradise_db_data/_data` is
where the data actually lives on disk. Most of the time we don't really care.
The data lives in the Docker volume, and that's usually all we need to know.

##### Database Credentials

When the `init-db` script creates a new database volume, it generates secure
passwords for the newly created database. The MariaDB image includes some magic
to automatically create a user and set passwords. This is done through some
`MYSQL_*` environment variables; see the [Documentation for the MySQL Image](https://hub.docker.com/_/mysql#environment-variables).

MariaDB only applies the `MYSQL_*` environment variables the first time it
initializes an empty data directory. You can create and destroy the database
container as many times as you like. The passwords live in the database volume.

If you keep the `paradise_db_data` volume and recreate the container, the old
passwords remain. If you delete the volume, the "data" part of the database is
deleted. In that case `init-db` will create a new database volume, and generate
new passwords for this new database.

The `init-db` script will output the passwords to the `secret` directory. The
files are named:

    secret/db-ss13-password.txt
    secret/db-root-password.txt

The game server container uses the `ss13` user and password.  
The utility scripts use the `root` user and password.

#### Paradise Network

One of the neat things about Docker is that it has an internal network concept.
A Docker network indicates which containers are allowed to talk to one another.

This can be nice from an organizational standpoint. Instead of having to find
IP addresses and individual ports for every container, they can live in their
own network, and not interfere with one another.

This can also be nice from a security standpoint. The database container shows
`3306/tcp`, but that means it's listening to port 3306 at the container on the
network it is attached to. Only other containers on that same network can reach
out to contact the database. By default it isn't exposed on the host, so
`localhost:3306` won't work unless you explicitly publish the port.

The `init-db` script will create a Docker network called `paradise_net`. You
can see the new network with the following command:

    docker network ls

You should see something like:

    tux@linuxbox:~/Paradise$ docker network ls
    NETWORK ID     NAME           DRIVER    SCOPE
    760399a52cac   bridge         bridge    local
    0987646c9a0b   host           host      local
    f6aae2702134   none           null      local
    e06521af6993   paradise_net   bridge    local

Our scripts will create two containers on the `paradise_net` network; the
database container, and the game server container. This means only containers
attached to `paradise_net` can reach the database.

### Creating the Game Server Container

Now that the `init-db` script has done all the difficult setup work, we can
create a container that runs the game server. That is, the container will be
created using the `paradise:latest` image, run DreamDaemon, and make the game
server available to the host network for connecting.

#### Configuration Work

Before we can create the game server container, it's important to talk about
volume mounts. This is similar to the Docker volume that we talked about
earlier, but is different because we are attaching specific folders from the
file system to the game server container when we create it.

The Paradise game server needs two folders:

- `/config`: Configuration options are stored here
- `/data`: Logs and current game mode are stored here

The `/data` folder does not need to exist. The script to create the game server
container will create it, if it doesn't already exist.

The `/config` folder has some information that we need to adjust before our
game server can start running.

##### Configuring config.toml

The main configuration file for a Paradise server is `config.toml`. You can
find an example in the code repository at `config/example/config.toml`.

The first thing we want to do is make our own copy of the example, so we can
modify it with our own configuration:

    cp -v config/example/config.toml config/config.toml

You should see something like:

    tux@linuxbox:~/Paradise$ cp -v config/example/config.toml config/config.toml
    'config/example/config.toml' -> 'config/config.toml'

Before we get started on editing, we need the password to the database. When
`init-db` created the database container, it also generated a file to store
the database password: `secret/db-ss13-password.txt`

We need to see this password so we can copy-pasta it into our configuration
file. That is, tell the game server the secret password to talk to the
database. Run this command:

    cat secret/db-ss13-password.txt

You should see something like:

    tux@linuxbox:~/Paradise$ cat secret/db-ss13-password.txt
    QFHvl6hRjRGAQsH8b45fhpgeilB11PcO

**NOTE**: This is a *secret*. You can write it down on a piece of paper for
yourself, but you should NOT share it online, nor share any screenshots of
the password.

Now we need a text editor to edit `config/config.toml`. Common text editors
on Linux are `nano` and `vim`, but you can use your favorite. We'll assume you
use `nano` and run a command like this:

    nano config/config.toml

This will open the configuration file. If you scroll down, you'll find a
section under the heading `[database_configuration]`. This is what we want
to edit:

    [database_configuration]
    # This section contains all the settings for the ingame database
    # If you are running in production, you will want to be using a database

    # Enable/disable the database on a whole
    sql_enabled = false
    # SQL version. If this is a mismatch, round start will be delayed
    sql_version = 71
    # SQL server address. Can be an IP or DNS name
    sql_address = "127.0.0.1"
    # SQL server port
    sql_port = 3306
    # SQL server database name
    sql_database = "paradise_gamedb"
    # SQL server username
    sql_username = "root"
    # SQL server password
    sql_password = "please use something secure in a production environment"
    # Time in seconds for async queries to time out
    async_query_timeout = 10
    # How many threads is the async SQL engine allowed to open. 50 is normal. Trust me.
    async_thread_limit = 50

There are four fields that we need to change. The first field is
`sql_enabled`. By default it is set to `false`. We want to change that to
`true`:

    sql_enabled = true

The second field we need to change is `sql_address`. This identifies the
container that the game server will contact to reach the database. Our database
container is called `paradise_db`, so that's what we'll change it to:

    sql_address = "paradise_db"

The third field we need to change is `sql_username`. Our database uses a
regular user called `ss13`. So we'll change the field as follows:

    sql_username = "ss13"

The fourth field we need to change is `sql_password`. This is where we paste
in that secret password that we printed out before.

    sql_password = "QFHvl6hRjRGAQsH8b45fhpgeilB11PcO"

**NOTE**: This random password is just an example for this documentation. If
you try to use the password written here, you won't be able to connect to your
database. You'll need to see what the `init-db` script created for you. Run
that command `cat secret/db-ss13-password.txt` and see what *your* password is.

When you are all done editing the file, save it. In `nano`, you type Ctrl-X,
then Y for (Yes, I want to save my changes), then Enter. Other text editors
will have their own command to save the file.

#### All Systems Go!

Now that we are fully configured, we are ready to create a game server
container. To do so, run the following command:

    tools/docker/run

Unless you edit the script, this will run the container in the foreground.
You will see a long startup sequence, as DreamDaemon loads and initializes
the Paradise software.

In another terminal window, you can see the game server container running
with the following command:

    docker ps --all

You should see something like:

    tux@linuxbox:~/Paradise$ docker ps --all
    CONTAINER ID   IMAGE             COMMAND                 CREATED          STATUS          PORTS                                         NAMES
    62f9d7c37db7   paradise:latest   "DreamDaemon paradis"   14 seconds ago   Up 14 seconds   0.0.0.0:6666->6666/tcp, [::]:6666->6666/tcp   paradise

While the database container had `3306/tcp`, we see that the game server
container has a more complicated `0.0.0.0:6666->6666/tcp`. This means that
the Docker host is forwarding it's own port 6666 to the game server container's
port 6666.

That is to say, if somebody connects to the Linux machine that is running
Docker on port 6666, then that network traffic will be sent to the game server
container on port 6666. If you point BYOND's DreamSeeker at the Linux machine
to port 6666, it will reach the running game server!

To stop the game server, you can press Ctrl+C in the terminal where you started
the game server container. Or in another terminal window you can run the
command:

    docker stop paradise

You should see something like:

    tux@linuxbox:~/Paradise$ docker stop paradise
    paradise

You can use `tools/docker/run` whenever you want to create and run a new game
server container.

## Development with Docker

Development with Docker is pretty easy. Just edit your code in the repository,
(any editor is fine; VS Code works well) and then run the build script again:

    tools/docker/build

If the build is successful, you can start the server container and test your
changes:

    tools/docker/run

Do this repeatedly when you develop fun new features for the Paradise server.

## Advanced Database Administration

This section covers some of the more advanced tools for working with your
database.

### Database Backups

Everybody knows that important data needs to be backed up. In fact, you should
make it a habit to create a backup when you begin work. That way, no matter how
many mistakes you make or how badly you break the database, you'll have a
backup to undo all the mistakes and get back to the way things were when you
got started.

To ask your database container to create a backup of your database, run the
following command:

    tools/docker/backup-db

You should see something like:

    tux@linuxbox:~/Paradise$ tools/docker/backup-db
    Wrote backup: paradise_db.sql

Copy this `paradise_db.sql` file to a USB stick. Then, upload the
`paradise_db.sql` file to Google Drive, OneDrive, Dropbox, or some other cloud
service of your choice. If you do this, you'll have a 3-2-1 backup.

#### 3-2-1 Backups

The high-falutin' IT folks talk about 3-2-1 backups. You want at least THREE
(3) copies of your data, on at least TWO (2) different kinds of media, and at
least ONE (1) copy should be kept "off-site".

Here "off-site" means if the building where you regularly keep your data burns
down, you know that you will still have a copy of your data that didn't get
burned up in a fire.

When you generated the backup, you had two copies of your data; one in the
Docker volume, and one in the `paradise_db.sql` file. When you copied it to a
USB stick, you had three copies of your data, on two different kinds of media;
your hard drive and an external USB stick. When you uploaded to the cloud,
you had four copies, on three different kinds of media, and one is off-site;
on somebody else's machine somewhere out there in the internet tubes.

This is as good of a backup as anybody in the IT world can give you.

### Database Restores

Remember that a backup is only good if A) You still have the backup when you
need it, and B) You can restore the backup to create a working system!

We covered the making sure you still have a copy when you need it. In this
section, we'll cover restoring the backup to create a new database container.

#### The Easy Database Restore Scenario

Scenario: You've got a running setup and you've been working on some code that
requires database changes. After a bad run, you realize it messed up the data
in the database, and you need some rows back for further testing.

This is an easy scenario. Your database container is still running. Your
database volume is present and healthy. And you've got your backup file.

To restore our database from the backup file, just run this command:

    tools/docker/restore-db

You should see something like:

    tux@linuxbox:~/Paradise$ tools/docker/restore-db
    Restored backup: paradise_db.sql

And that's it! Your database is restored back to when the backup was created.
That was easy, because this is the easy scenario.

#### The Hard Database Restore Scenario

Scenario: Your hard drive died. You had to replace the hard drive and download
all the stuff again. Fortunately you had a copy of `config.toml` and
`paradise_db.sql` up in the cloud. So you're ready to restore your system back
to working condition.

First, we follow the directions to create a new database container and volume:

    tools/docker/init-db

Next, we realize, this is a *brand new* database volume, which means it will
have a *brand new* password. We need to see what that new password is:

    cat secret/db-ss13-password.txt

Then we need to update `config/config.toml` and copy-pasta the new password
in to the `sql_password` field:

    nano config/config.toml

And now that we've got a running database container and our configuration file
all straightened out, we'll restore from the backup:

    tools/docker/restore-db

You should see something like:

    tux@linuxbox:~/Paradise$ tools/docker/restore-db
    Restored backup: paradise_db.sql

And that's it! Your database is restored back to when the backup was created.
That was harder, because that was the hard scenario where we needed to edit
the password in the configuration file, because we lost our old one.

### Database Queries

Once you get to advanced development, you may need to make changes to the
structure of the database. You may need to add or remove columns, or create
a brand new table. And you'll need to query to see if your changes are working
as you intended.

In order to get a shell into the database, run the following command:

    tools/docker/debug-db

You should see something like:

    tux@linuxbox:~/Paradise$ tools/docker/debug-db
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A

    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MariaDB connection id is 4
    Server version: 12.1.2-MariaDB-ubu2404 mariadb.org binary distribution

    Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    MariaDB [paradise_gamedb]> 

Here you are in a MariaDB shell and can execute a query like:

    SELECT count(*) AS num_rounds FROM round;

You should see something like:

    MariaDB [paradise_gamedb]> SELECT count(*) AS num_rounds FROM round;
    +------------+
    | num_rounds |
    +------------+
    |          2 |
    +------------+
    1 row in set (0.001 sec)

Teaching the ins and outs of writing and executing SQL queries is beyond the
scope of this document. However, there are lots of resources online, and AI are
surprisingly good tutors if you have questions about SQL databases and queries.

### Custom Database Container Creation

Earlier, we mentioned that the MariaDB image will use some environment
variables to do special initialization when the database container is first
created. This is not the only magic trick embedded in that MariaDB image.

Another useful feature is mounting some directory from the repository at
`/docker-entrypoint-initdb.d` in the container. On the first run, when the
database container is being created, all the SQL scripts found in that
directory will be applied to the database in alphabetical order.

The script `tools/docker/init-db` mounts the `SQL` directory from the
repository into the database container at `/docker-entrypoint-initdb.d`.
By doing so, the SQL script that creates the Paradise database schema
`paradise_schema.sql` is automatically applied when the volume is first
created.

This is already incredibly useful, giving you a database with the correct
tables and columns straight away. However, it can also be used to populate
your database with extra data. Simply create a SQL script in the `SQL`
directory before you create the database:

    nano SQL/zzz_001_my_cool_data.sql

And you can put whatever queries you want to be run against the database when
it is first created. For example, if you'd like to pre-populate your database
with your favorite characters, give yourself and your friends admin rights, and
that sort of thing; all of these are possible.

In order to leverage this, you will need to know how to write SQL queries, or
at least find a SQL script that you want to apply to your database.

## Advanced Game Server Image Building and Debugging

### Customizing Game Server Image Builds

One of the magic powers hidden in the `tools/docker/build` script, is that
additional arguments are supplied to the `docker build` command:

    # build the docker image
    docker build "$@" \
        --build-arg "NODE_VERSION=${NODE_VERSION}" \
        --build-arg "RUST_VERSION=${RUST_VERSION}" \
        --build-arg "STABLE_BYOND_MAJOR=${STABLE_BYOND_MAJOR}" \
        --build-arg "STABLE_BYOND_MINOR=${STABLE_BYOND_MINOR}" \
        --tag "${SERVER_IMAGE}" \
        .

That little `"$@"` doesn't look like it's doing much, but if means you can
supply any extra argument. Let's say you want Docker to skip it's internal
cache and rebuild everything from absolute scratch:

    tools/docker/build --no-cache

The `--no-cache` flag [disables the build cache](https://docs.docker.com/build/building/best-practices/#use---no-cache-for-clean-builds).
You feed that flag to the utility script, and the `"$@"` passes it along to the
`docker build` command that gets executed to build the game server image.

Maybe you don't like how often the NanoMaps are being rendered? You could add
a flag `--build-arg "SKIP_NANOMAPS=TRUE"`. Now, if you modify the `Dockerfile`
in the right way:

    # Render NanoMaps
    FROM base AS nanomap-build
    ARG SKIP_NANOMAPS
    COPY _maps _maps
    COPY code code
    COPY icons icons
    COPY tools/github-actions tools/github-actions
    COPY paradise.dme paradise.dme
    RUN bash -lc '[ -n "${SKIP_NANOMAPS:-}" ] || tools/github-actions/nanomap-renderer-invoker.sh'

Now you can build and force it to skip rendering the NanoMaps:

    tools/docker/build --build-arg "SKIP_NANOMAPS=TRUE"

Doing things like this are left as an exercise for the Expert Level reader.

### Debugging Game Server Images

If you modify the `Dockerfile` at some point, you'll end up changing what
things end up in the final `paradise:latest` image. If things are missing, or
out of place, or not what you expect, it can lead to strange errors.

If you ever wonder, "What all is in this image anyway?" then the command you
want to run is:

    tools/docker/debug-server

This will create a game server container. However, instead of running
DreamDaemon, it will run a bash shell. You should see something like:

    tux@linuxbox:~/Paradise$ tools/docker/debug-server
    root@28cac9c76c8a:/# 

This is your opportunity to run shell commands like `ls -l` to see what the
DreamDaemon software running in the container will see. For example:

    root@28cac9c76c8a:/# ls -l
    total 184276
    drwxr-xr-x   3 root   root         4096 Jan  4 16:56 _maps
    lrwxrwxrwx   1 root   root            7 Sep 29 00:00 bin -> usr/bin
    drwxr-xr-x   2 root   root         4096 Aug 24 16:05 boot
    drwxr-xr-x   2 root   root         4096 Jan 17 07:47 config
    drwxr-xr-x   2 root   root         4096 Jan 17 07:47 data
    drwxr-xr-x   5 root   root          360 Jan 17 07:47 dev
    drwxr-xr-x   1 root   root         4096 Jan 17 07:47 etc
    drwxr-xr-x   2 root   root         4096 Aug 24 16:05 home
    drwxr-xr-x   1 root   root         4096 Jan  4 16:56 icons
    lrwxrwxrwx   1 root   root            7 Sep 29 00:00 lib -> usr/lib
    lrwxrwxrwx   1 root   root            9 Sep 29 00:00 lib64 -> usr/lib64
    -rwxr-xr-x   1 root   root     10426480 Jan 17 03:00 librustlibs.so
    drwxr-xr-x   2 root   root         4096 Sep 29 00:00 media
    drwxr-xr-x   2 root   root         4096 Sep 29 00:00 mnt
    drwxr-xr-x   2 root   root         4096 Sep 29 00:00 opt
    -rw-r--r--   1 root   root     31268364 Jan 17 02:57 paradise.dmb
    -rw-r--r--   1 root   root    146923054 Jan 17 06:02 paradise.rsc
    dr-xr-xr-x 426 nobody nogroup         0 Jan 17 07:47 proc
    drwx------   2 root   root         4096 Sep 29 00:00 root
    drwxr-xr-x   3 root   root         4096 Sep 29 00:00 run
    lrwxrwxrwx   1 root   root            8 Sep 29 00:00 sbin -> usr/sbin
    drwxr-xr-x   2 root   root         4096 Sep 29 00:00 srv
    drwxr-xr-x   3 root   root         4096 Jan  4 16:56 strings
    dr-xr-xr-x  13 nobody nogroup         0 Jan 17 07:47 sys
    drwxr-xr-x   3 root   root         4096 Jan 17 06:03 tgui
    drwxrwxrwt   2 root   root         4096 Sep 29 00:00 tmp
    drwxr-xr-x   1 root   root         4096 Sep 29 00:00 usr
    drwxr-xr-x   1 root   root         4096 Sep 29 00:00 var

Wow! There's a whole Linux system in there, along with some Paradise stuff
like `librustlibs.so`, `paradise.dmb`, and `paradise.rsc`. Have fun exploring!

## Uninstall Docker Changes

And now we've reached the end of the line. The last script we can talk about
is `tools/docker/zzz-destroy-everything-zzz`. This script does what it says on
the tin. It will destroy EVERYTHING created by the other scripts.

    #
    # !!! This script will destroy everything !!!
    #
    # Your database and server containers will be stopped and deleted.
    # The database volume containing all the data in your database will be deleted.
    # The server image you last built will be deleted.
    # The docker network the database container and server container used to talk to each other will be deleted.
    # The entire secret/ directory, and the database credentials kept there, will be deleted.
    # The backup file for your database will be deleted.
    #
    # NOTE: Destroys all of the things. !! EVERYTHING !! You have been warned!
    #

It has an odd name `zzz-destroy-everything-zzz` and even refuses to run unless
you provide the secret password:

    tux@linuxbox:~/Paradise$ zzz-destroy-everything-zzz
    Error: If you *really* want to do this:

    tools/docker/zzz-destroy-everything-zzz honk-honk-honk

    There is NO way to UNDO this! If you do this, you destroy *everything*, PERMANENTLY!

Don't run it unless you're absolutely sure that you want that data to take a
one-way trip to the bit bucket.

    tools/docker/zzz-destroy-everything-zzz honk-honk-honk

If you followed my instructions about the 3-2-1 Backup, you can probably
re-create it all in a few minutes. If you didn't save yourself a 3-2-1 Backup,
then you really did destroy everything. 仕方がない。

## Expert Level

You've learned about all the utility scripts that have been provided to you.
Note that all of the scripts follow the same basic pattern:

- Bind some bespoke names; `paradise_db`, `paradise:latest`, etc.
- Run some basic sanity checks
- Run a `docker $COMMAND` command, like `docker build` or `docker run`

The scripts use a common set of names between them, which is why they
interoperate together so well. That is, you can run `tools/docker/backup-db`
and later run `tools/docker/restore-db` because both scripts agree on what
the database container is called, what the backup file is called, etc.

If you want to call your game server image `paradise:20260117`, there is
nothing to stop you from editing the utilty script, or creating your own!

You will have to learn about bash shell script.  
You will have to learn about Docker commands.  
You might need to learn about SQL queries.

However, the utility scripts can guide you. Take a look at what docker command
they are running under the hood, and what flags and names they give to the
docker command.

You're a black belt now, so your real training can finally begin.
