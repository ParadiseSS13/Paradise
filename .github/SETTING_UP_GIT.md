# Setting Up Git (Windows/Mac Only)

## Linux users

You will want to install the `git` package from your distribution's respective
package manager, whatever that may be.

---

## Windows user
## Git-SCM
So you want to start contributing to Paradise? Where, well do you start?
First off, you will need some tools to work with Git, the
[Version Control System](https://en.wikipedia.org/wiki/Version_control)
that we operate off. There are many choices out there for dealing with Git,
including GitHub for Desktop- However, all of them are based off of the same
command-line tools. As such, we advise, rather than using a GUI Program, you
learn how to use the command line.

An important note here is that the Git-SCM package for Windows includes
some GUI-based software in it. This can be used for easily monitoring the
state of your current branch, without downloading multiple different tools.

## Installing
The version of Git that we will be using is available at https://git-scm.com/.
There should be four big orange buttons on the front page of the site when you
go there. You will want to click on the one labeled "Downloads".
![https://i.imgur.com/a6tX7IV.png](https://i.imgur.com/a6tX7IV.png)

From here, you will want to select your operating system in this box.  
![https://i.imgur.com/Ee4wVsF.png](https://i.imgur.com/Ee4wVsF.png)

Download the `setup` version, which should automatically start downloading when
you select your operating system. Place it wherever you prefer to store your
downloaded files. You should end up with a file that looks like
`Git-version.number.here-32/64-bit.exe`. You should run this executable file.  
![https://i.imgur.com/jnbodzV.png](https://i.imgur.com/jnbodzV.png)

Click Next, after reading the GNU-GPL license if you wish to do so, which will
bring you to this screen.  
![https://i.imgur.com/cl9RodU.png](https://i.imgur.com/cl9RodU.png)

Your default options may be different than this- You'll want to amend them to
match this screenshot. (Future proofing: `Windows Explorer integration` partially
selected, just for `Git Bash Here`, `Git LFS (Large File Support)` checked,
and `Associate .git* configuration files with the default text editor` checked.
All other boxes should be left unchecked). Click next. The next screen is very
important.  
![https://i.imgur.com/6ii7aRO.png](https://i.imgur.com/6ii7aRO.png)

The screen should say `Adjusting your PATH environment`. You will definitely want
to select `Use Git from Git Bash only`- This is the safest option, and will not
change your PATH variables at all. The disadvantage of this is that any future
terminal emulators will be unable to use Git, as will the windows command prompt.

Select `Use the OpenSSL library` for `Choosing HTTPS transport backend`.

For Windows, you will also get the following screen:  
![https://i.imgur.com/jOZJWvO.png](https://i.imgur.com/jOZJWvO.png)

You will want to select "Checkout Windows-style, commit Unix-style line endings"
for working with our repository.

If you get the choice between MinTTY and Windows' default console window, select
MinTTY.  
![https://i.imgur.com/ZdZU0NB.png](https://i.imgur.com/ZdZU0NB.png)

For `configuring extra options`, select `Enable file system caching` and
`Enable Git Credential Manager`, leaving `Enable symbolic links` disabled.  
![https://i.imgur.com/6gspQAL.png](https://i.imgur.com/6gspQAL.png)

From there, just hit `Install`.

## Configuring

We are going to configure Git for password-less SSH authentication for GitHub.
There is a simple way to make this require that you instead just enter your
password once upon opening a terminal for the first time running the program
after a restart, which we will cover when it is applicable.

This guide is mostly copy-pasted from
`https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/`,
 So you can view that for further instruction.

As we are working with a completely fresh install of Git, we can skip over some
steps. You will want to open Git Bash, then use the text below, changing the email
to the one you use for GitHub.
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```
This will create a new SSH private/public key, using the email as a label.
```bash
Generating public/private rsa key pair.
```

When you're prompted to `Enter a file in which to save the key`, you will want
to just press enter, to accept the default file location. We will rename the key
later.

Remember that I mentioned you could either do password-less SSH authentication,
or require a password one time per session? This is the point at which you
choose this, with the `Enter passphrase (empty for no passphrase):` prompt. If
you do not care about having a password on the private key (which you should
never ever distribute beyond your own computers on secure mediums), you can just
hit enter twice to completely skip setting a password on the key. Otherwise, enter
your desired password.

You will now want to go to your home directory `C:/Users/YourName` and open the
`.ssh` folder. You should see two files in here, `id_rsa` and `id_rsa.pub`. Rename
them both to `your_github_username_rsa` and `your_github_username_rsa.pub`.
You'll then want to create two new folders, `public` and `private`. Put the `.pub`
file into `public`, then put the other one into `private`.

As we are not using GitHub for Desktop, we will need to now setup SSH-agent.
Start by typing the command `vim ~/.bashrc`. This will open the Vi IMproved text
editor, which is one of the ones that comes with Git by default. It is entirely
built into the shell, and the interface will take a bit of getting used to.
You will want to hit `i`, to go into `Insert Mode`. This will produce a blinking
cursor on the top section, what you would expect for a text editor. You may now
type what you like, or right click and paste to paste from your clipboard.
Paste the following into the file:
```bash
#!/bin/bash

SSH_ENV=$HOME/.ssh/environment

function add_keys {
	ssh-add ~/.ssh/private/*
}

function start_agent {
	echo "Initializing new SSH agent..."
	/usr/bin/ssh-agent | sed 's/^echo/#echo' > ${SSH_ENV}
	echo Suceeded
	chmod 600 ${SSH_ENV}
	. ${SSH_ENV} > /dev/null
	add_keys;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
	. ${SSH_ENV} > /dev/null
	ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
		start_agent;
	}
else
	start_agent;
fi
```

Hit escape, then hit `:` followed by `wq` and enter. This is, to Vi, Insert Mode
to command mode (`ESC`), Command start `:`, and `w`rite `q`uit `ENTER` submit.

Restart Git Bash- If you set a password on your SSH key, it will ask it for you
when it starts. Otherwise, it should just say `Identity added: ...`. You can see
all of the identities you have by running `ssh-add -l` in the shell at any time.

You will now want to follow the instructions in this article to add the SSH key
to your GitHub profile:
https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

Obviously, for the first step, use the key we renamed and put into the `public`
folder, not the one in the `private` folder.

To test that this all worked, you should run `ssh -T git@github.com`. If there
are any warning messages about authenticity, type `yes` followed by enter. You
should then see:
```
Hi username! You've successfully authenticated, but GitHub does not
provide shell access.
```

If not, follow the troubleshooting directions in this article:
https://help.github.com/articles/error-permission-denied-publickey/


Congratulations, you have now setup Git for Windows.