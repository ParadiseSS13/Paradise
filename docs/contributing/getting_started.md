# Getting Started

Whether you're looking to contribute code, mapping changes, or sprites to
Paradise Station, you will need to set up a development environment. This guide
provides all the necessary steps to do so.

![](./images/flowchart.png){: style="width:50%"}

## Development Environment Setup

This guide will walk you through the basic steps of installing Git, the program
that tracks changes to the Paradise codebase, as well as Visual Studio Code, the
recommended editor for working with Paradise.

### Setting Up Visual Studio Code

Visual Studio Code is the recommended editor for working with Paradise and other
SS13 codebases.

1. Go to VS Code's website: <https://code.visualstudio.com/>
2. Download the appropriate build for your system and install it.

### Setting Up Git

Git is the program that allows you to share your code changes with the Paradise
codebase. Git can be daunting to contributors unfamiliar with source control,
but is an incredibly powerful tool, and there are many resources online to learn
how to use it and understand its concepts.

To install git:

1. Go to the [Git][] website and download the installer for your operating system.
2. Run the installer, leaving all the default installation settings.

For a straightforward beginner's guide to git, see GitHub's [Git Guides][].

For more guidance on installing git, see the Git Guide for [Installing Git][].

GitHub also provides a graphical environment for working with git called [GitHub
Desktop][]. This is not necessary to contribute to Paradise Station, as Visual
Studio Code also has powerful git integration.

[Git]: https://git-scm.com/downloads
[Installing Git]: https://github.com/git-guides/install-git
[Git Guides]: https://github.com/git-guides
[GitHub Desktop]: https://github.com/apps/desktop

#### Additional Help

For instructional videos on Visual Studio Code's GitHub integration, see <https://vscode.github.com/>.

For a straightforward beginner's guide to git, see GitHub's [Git Guides][].

For more guidance on installing git, see the Git Guide for [Installing Git][].

For introductory videos on Git, see:

- [Introduction to Git with Scott Chacon of GitHub](https://www.youtube.com/watch?v=ZDR433b0HJY)
- [Git From Bits Up](https://www.youtube.com/watch?v=MYP56QJpDr4)
- [Linus Torvalds (inventor of Linux and Git) on Git](https://www.youtube.com/watch?v=4XpnKHJAok8)

### Registering a GitHub Account

GitHub is the service where the Paradise codebase is stored. You'll need a
GitHub account to contribute to Paradise. Go to the [GitHub signup page][] and
register with a username and e-mail account.

[GitHub signup page]: https://github.com/signup

### Hiding Your Email Address

Changes to Git repositories include the e-mail address of the person who made
the change. If you don't wish your email address to be associated with your
development on Paradise, you can choose to hide your email when interacting with
repositories on GitHub:

1. Log into your GitHub account.
2. Go to <https://github.com/settings/emails>.
3. Select the _Keep my email addresses private_ checkbox.

This means that while your e-mail address is associated with your GitHub
account, any changes you make will only be keyed to a generic e-mail address
with your username.

## Installation for Linux Users

The code is fully able to run on Linux, however Windows is still the recommended
platform. The libraries we use for external functions (rust-g and MILLA) require
some extra dependencies.

### Building rust-g for Debian-based Distributions

1. Download the latest release from <https://github.com/ParadiseSS13/rust-g>
2. Run the following command:

   ```sh
   apt-get install libssl-dev:i386 pkg-config:i386 zlib1g-dev:i386
   ```

3. After installing these packages, rust-g should be able to build and function
   as intended. Build instructions are on the rust-g GitHub. We assume that if
   you are hosting on Linux, you know what you are doing.
4. Once you've built rust-g, you can build MILLA similarly. Change into the
   `milla/` directory and run:

   ```sh
   cargo build --release --target=i686-unknown-linux-gnu
   ```

## Cloning the Repository

Cloning the Paradise repository only has to be done once.

1. Visit the [repository][] and press the _Fork_ button in the upper right corner.

   ![](./images/fork_repository.png)

[repository]: https://github.com/ParadiseSS13/Paradise

2. Launch Visual Studio Code. Select the Source Control panel on the sidebar,
   and click _Clone Repository_.

   ![](./images/vsc_clone_repository.png)

   If that’s not there, you can press `Ctrl`+`Shift`+`P` to open the command
   palette, then type `Git: Clone` and then press `Enter`.

3. Paste the URL of the repository you created in the last step. It should look
   like this: `https://github.com/YOURNAME/Paradise`. Then, select a folder to
   keep your local repository. The process of downloading might take a while.
   Once it’s downloaded, open the folder in Visual Studio Code.

## Installing Recommended Visual Studio Code Extensions

When you first open the Paradise repository in Visual Studio Code, you will also
get a notification to install some recommended extensions. These plugins are
extremely useful for programming with BYOND and should be considered essential.
If you don't see the prompt to install the recommended extensions, they can be
found by searching for `@recommended` in the Extensions panel, or installed from
the list below.

- [DreamMaker Syntax Highlighting](https://marketplace.visualstudio.com/items?itemName=gbasood.byond-dm-language-support)
- [BYOND Language Support](https://marketplace.visualstudio.com/items?itemName=platymuus.dm-langclient)
- [EditorConfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
- [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [ErrorLens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens)
- [DreamMaker Icon Editor](https://marketplace.visualstudio.com/items?itemName=anturk.dmi-editor)
- [Prettier Code Formatter](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
- [ZipFS](https://marketplace.visualstudio.com/items?itemName=arcanis.vscode-zipfs)

## Adding Paracode as an Upstream Repository

We need to add the main Paradise repository as a remote now.

1. Open the command palette (`Ctrl`+`Shift`+`P`), type `Git: Add Remote`, and
   press `Enter`. You'll be prompted for the URL of the remote, and then the name
   of the remote.

2. Enter `https://github.com/ParadiseSS13/Paradise` for the URL, and `upstream`
   for the name. After you've done that, you’ll have the main Paradise
   repository as a remote named `upstream`. This will let you easily send your
   pull requests there later.

## Configuring a Local Database

While configuring a local database is not required, it is recommended because it
tracks local round IDs, stores local player characters, and allows you to verify
the output of blackbox entries.

### Initial setup and Installation

1. Download and install [MariaDB](https://mariadb.com/downloads/mariadb-tx) for
   your operating system. The default installation settings should work. You
   need TCP enabled and to set a root password. If it offers, do _not_ set it up
   to use Windows authentication. If you've ticked Install as a Windows Service
   (should be ticked by default), it will run whenever you boot up your
   computer, so there's no need to worry about starting it manually.

2. Open HeidiSQL (comes with MariaDB) and connect it to the database. Click on
   _New_ to create a new session, check _prompt for credentials_ and leave the
   rest as default.

3. Click _Save_, then click open and enter in `root` for the username and the
   password you set up during the installation.

4. Select the database you just created and then select _File -> Load SQL File_,
   and open the `paradise_schema.sql` file found in the `SQL/` directory of the
   game.

5. Press the blue "play" icon in the topic bar of icons. If the schema imported
   correctly you should have no errors in the message box on the bottom.

6. Refresh the panel on the left by right clicking it and ensure there's a new
   database called `paradise_gamedb` created.

7. Create a new user account for the server by going to _Tools -> User Manager_.
   'From Host' should be `127.0.0.1`, not `localhost` if hosted locally.
   Otherwise, use the IP of the game server. For permissions, do not give it any
   global permissions. Instead click _Add Object_, select the database you
   created for the server, click _OK_, then give it `SELECT`, `DELETE`,
   `INSERT`, and `UPDATE` permissions on that database.

8. You can click the arrow on the password field to get a randomly generated
   password of certain lengths. copy the password before saving as it will be
   cleared the moment you hit _Save_.

9. Open the file `config/config.toml` in your text editor (such as VS Code)
   scroll down to the `[database_configuration]` section. You should've copied
   the file over from the `config/example` folder beforehand.

10. Make sure that these settings are changed:

    - `sql_enabled` is set to `true`.
    - `sql_version` to the correct version. By starting the server with a
      mismatched version here and all the other settings set up, the chat box
      will tell you the current version in red text, between the messages for
      all the subsystems initializing. Set this to the current version.
    - `sql_address` is set to `"127.0.0.1"`. (Replace with the database server's
      IP if not hosted locally)
    - `sql_port` is set to whatever port was selected during the MariaDB
      install, usually `3306`.
    - `sql_database` is set to the name of your database, usually
      `"paradise_gamedb"`.
    - `sql_username` is set to the 'User name' of the user you created above.
    - `sql_password` is set to the randomly generated 'Password' of the user you
      created above.

The database is now set up for death logging, population logging, polls,
library, privacy poll, connection logging and player logging. There are two more
features which you should consider. And it's best to do so now, since adopting
them later can be a pain.

### Database based administration

Offers a changelog for changes done to admins, which increases
accountability (adding/removing admins, adding/removing permissions,
changing ranks); allows admins with `+PERMISSIONS` to edit other admins'
permissions ingame, meaning they don't need remote desktop access to
edit admins; Allows for custom ranks, with permissions not being tied to
ranks, offering a better ability for the removal or addition of
permissions to certain admins, if they need to be punished, or need
extra permissions. Enabling this can be done any time, it's just a bit
tedious the first time you do it, if you don't have direct access to
the database.

To enable database based administration:

- Open `\config\config.toml` and scroll to the `[admin_configuration]`
  section.
- Set `use_database_admins` to `true`.
- Add a database entry for the first administrator (likely yourself).
- Done! Note that anyone set in the `admin_assignments` list will no
  longer be counted.
- If your database ever dies, your server will revert to the old admin
  system, so it is a good idea to have `admin_assignments` and
  `admin_ranks` set up with some admins too, just so that the loss of
  the database doesn't completely destroy everything.

## Working with `config.toml`

Paradise relies on a configuration file for many key aspects of its operation.
That file is `config\config.toml`, and it contains many setting that are useful
when developing locally. When you first clone the Paradise repository,
that file will not exist; that is because it is ignored by git so that people's
individual configurations do not get uploaded to the master repository.

In order to modify the settings in it, you must copy the file
`config\example\config.toml` to its parent directory.

Some helpful uses of `config.toml` follow.

### Overriding the next map

If you are testing a specific map, the `override_map` setting under the
`system_configuration` setting can be set to any map datum listed in
[`code/modules/mapping/station_datums.dm`][datums]. If you are testing something
that doesn't require a station map, such as ruins, you can avoid loading a large
map altogether and save yourself some time starting the server by setting
`override_map` to `"/datum/map/test_tiny"`.

[datums]: https://github.com/ParadiseSS13/Paradise/blob/master/code/modules/mapping/station_datums.dm

### Enabling or disabling Lavaland and Space levels

If you do not need to load Lavaland, any of its ruins, or any space ruins, you
can change these settings under `ruin_configuration`:

- `enable_lavaland`: whether to load Lavaland.
- `enable_space`: Whether to load space sectors.
- `enable_space_ruins`: despite its name, this controls whether ruins are
  spawned for both space _and_ Lavaland.
- `minimum_space_zlevels`/`maximum_space_zlevels` and
  `minimum_lavaland_zlevels`/`maximum_lavaland_zlevels` control the number of
  z-levels generated for space and Lavaland, respectively. If you don't need
  any, set both to `0`.

### Enabling or disabling station traits

You can control whether roundstart station traits roll with the
`add_random_station_traits` setting under the `gamemode_configuration` section.

## Publishing Changes

First, let's talk about **branches**. First thing to do is to make a new
branch on your fork. This is important because you should never make
changes to the default(master) branch of your fork. It should remain as
a clean copy of the main Paradise repository.

**For every PR you make, make a new branch.** This way, each of your
individual projects have their own branch. A commit you make to one
branch will not affect the other branches, so you can work on multiple
projects at once.

### Branching

To make a new branch, open up the source control sidebar. Navigate to
the Branches section and open it. You should only have the master
branch. You can create a new branch by going and clicking on the Create
Branch button.

![](./images/VSCodeBranching.png)

It will then prompt you at the top of your screen to name your new
branch, then select Create Branch and Switch. For this guide, I'll be
creating a new hat, so I'll name my branch `hat-landia`. If you look at
the bottom left hand corner, you'll see that VS Code has automatically
checked out our
branch:

![](./images/VSCodeBranchExample.png)

Remember, **never commit changes to your master branch!** You can work
on any branch as much as you want, as long as you commit the changes to
the proper branch.

Go wild! Make your code changes! This is a guide on how to contribute,
not what to contribute. So, I won't tell you how to code, make sprites,
or map changes. If you need help, try asking in the `#spriting` or the
`#coding_chat` Discord channels.

### Changing Code

You'll find your code to edit in the Explorer sidebar of VS Code; if you need to
find something, the Search sidebar is just below that.

If you want to use DreamMaker instead, go ahead and edit your files there - once
you save them, VS Code will detect what you’ve done and you’ll be able to follow
the guide from there.

If you do anything mapping related, it is highly recommended you use
StrongDMM and check out the [Mapping Quickstart](../mapping/quickstart.md).

Now, save your changes. If we look at the Source Control tab, we'll see
that we have some new changes. Git has found every change you made to
your fork's repo on your computer! Even if you change a single space in
a single line of code, Git will find that change. Just make sure you
save your files.

### Testing Your Code

The easiest way to test your changes is to press `F5`. This compiles your code,
runs the server and connects you to it, as well as automatically giving you
admin permissions. It also starts a debugger that will let you examine what went
wrong when a runtime error happens. If you want to avoid the debugger press
`Ctrl` + `F5` instead.

If `F5` does not automatically start a local server, you might have installed
BYOND on a custom path and VSC did not find it. In this case, try the following:

1.  Press `Ctrl` + `,` to open VSC settings.
2.  Type "DreamMaker", select "DreamMaker language client
    configuration".
3.  Under "DreamMaker: Byond Path", add your path to BYOND (for
    example, `D:\Program Files (x86)\BYOND`).
4.  Press OK and close the tab.
5.  Press `F5` to run the server.

If that does not work, you can compile it into a dmb file and run it in
Dream Daemon. To do so, select the dmb file, set security to Trusted and
hit GO to run the server. After the server starts you can press the
button above the GO / STOP button (now red) to connect.

Do note that if you compile the game this way, you need to manually make
yourself an admin. For this, you will need to copy everything from
`/config/example` into `/config`. Then you will need to edit the
`/config/config.toml` file by adding a
`{ckey = "Your Name Here", rank = "Hosting Provider"}` line to the
`admin_assignments` list.

![](./images/DreamDaemon.png)

Be sure to always test not only if your changes work, but also if you
didn't actually break something else that might be related.

### Committing to Your Branch

Hover over the word **Changes** and press the plus sign to stage all
modified files. It should look like this:

![](./images/VSCodeStageChanges.png)

Or, pick each file you want to change individually. Staged files are the
changes you are going to be submitting in commit, and then in your pull
request. Once you've done that, they'll appear in a new tab called
Staged Changes.

![](./images/VSCodeStagedChanges.png)

Click on one of the code files you've changed now! You'll see a compare
of the original file versus your new file pop up. Here you can see, line
by line, every change that you made. Red lines are lines you removed or
changed, and green lines are the lines you added or updated. You can
even stage or unstage individual lines, by using the More Actions
`(...)` menu in the top right.

Now that you've staged your changes, you're ready to make a commit. At
the top of the panel, you'll see the Message section. Type a descriptive
name for you commit, and a description if necessary. Be concise!

Make sure you're checked out on the new branch you created earlier, and
click the checkmark! This will make your commit and add it to your
branch. It should look like this:

![](./images/VSCodeCommit.png)

There you go! You have successfully made a commit to your branch. This
is still 'unpublished', and only on your local computer, as indicated by
the little cloud and arrow icon in the bottom left corner.

![](./images/VSCodePublishBranch.png)

Once you have it committed, you'll need to push/publish to your GitHub.
You can do that by pressing the small cloud icon called "publish
branch".

### Publishing to GitHub

Go to the [Main repository](https://github.com/ParadiseSS13/Paradise/)
once your branch is published, GitHub should then prompt you to create a
pull request. This should automatically select the branch you just
published and should look something like this.

![](./images/GithubCreatePR.png)

If not, you'll need to open a Pull Request manually. You'll need to select
_Compare across forks_, then select the upstream repo and target the master
branch.

Then, you'll be able to select the title of your PR. The extension will make
your PR with your selected title and a default description. **Before
submitting**, ensure that you have properly created your PR summary and followed
the description template.

#### Changelogs

Changelogs should be player focused, meaning they should be understandable and
applicable to your general player. Keep it simple:

    fix: fixed a bug with X when you Y
    tweak: buffed X to do Y more damage.

Avoid coding-lingo heavy changelogs and internal code changes that don't visibly
affect player gameplay. These are all examples of what you shouldn't add:

    tweak: added the NO_DROP flag to X item.
    tweak: refactored DNA to be more CPU friendly

If the only changes you're making are internal, and will not have any effect on
players, you can replace the changelog section with _NPFC_, meaning "No
Player-Facing Changes".

ShareX is a super useful tool for contributing as it allows you to make GIFs to
display your changes. you can download it [here](https://getsharex.com/).

If all goes well, your PR should look like this:

![](./images/ExamplePR.png)

If you want to add more commits to your PR, all you need to do is just push
those commits to the branch.
