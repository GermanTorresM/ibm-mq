
## Prerequisites


## Steps

### Step 1. Create a user and group for running MQ client applications

Before we start the installation, we need to create a group called "mqclient" and a user account called "app" in this group. These names allow us to configure the MQ objects we'll work with, such as queues and channels.

We never need to actually log in as the user "app". After it's been created, please stay logged in to your own account.

Create the group mqclient from the terminal with the command:

```bash
sudo addgroup mqclient
```

Show more
You should see a confirmation that this was successful. Next, we create the user "app" and add this user to the group mqclient:

```bash
sudo adduser app
```

Show more
This prompts you to create a password for the account "app", which you must do. You are then asked about other account details, which you can leave blank – just press ENTER until the account is created.

Now we need to add the user "app" to the "mqclient" group, and check this was successful.

```bash
sudo adduser app mqclient
groups app
```

Show more
We should get the following output:

Output from adding user and group

Now the account is set up correctly, we can move on to the actual install and configuration.

You now have 2 options for installing MQ on Ubuntu:

If you'd like to go through each step of the installation and configuration, work through steps 2 through 5 of this tutorial and input the commands yourself. Then, continue with Step 6.

If you just want to get something working quickly, you can use this handy bash script that will install MQ and set up your development environment. If you use this script, make sure that you come back to this tutorial and continue with Step 6 to put and get your first message.

Made your choice? Definitely don't want to use the bash script? Read on to install MQ and get your configuration set up.

### Step 2. Download IBM MQ
We're going to install MQ Advanced for Developers, then configure it so that you can develop using MQ. Download the tar.gz file from here.

### Step 3. Install IBM MQ
Unzip the folder you downloaded. The contents extract to a folder named "MQServer". This contains many Debian packages that need to be installed. Note the location of this folder, e.g. /home/username/Downloads/MQServer. Open a terminal and type:

```
sudo ./mqlicense.sh -text_only
```

Show more
This opens up the license in the terminal. Read the license and then press 1 to accept the terms. If you get an error and java isn't in your path, do this:

```
sudo ./mqlicense.sh -text_only -jre $(which java)
```

Next, we want to make sure that the apt installer can find package dependencies and install MQ properly. To do this, we need to add the folder to the apt cache.

Navigate to the /etc/apt/sources.list.d directory.
Create a .list file named ibmmq-install.list for example.
Inside this file, put this line:

deb [trusted=yes] file:/home/username/Downloads/MQServer ./

Show more
then add the packages to the apt cache with:

```
sudo apt update
```

Show more
Now, we're ready to install MQ. Install all the packages with the single command:

```
sudo apt install "ibmmq-*"
```

Show more
Now we've installed IBM MQ, let's check that the installation was successful. Do this with the command /opt/mqm/bin/dspmqver. You should see output like this:

Output after installing IBM MQ

Success!

### Step 4. Set up your MQ environment
Once the installation is complete, we need to add the user to the admin group mqm so that you have MQ admin privileges such as the ability to create and start a queue manager. Important: This is not the user "app", it's your user account. You're acting as the admin, and the user "app" is using the MQ setup that you have created. Add your user account with this command:

sudo adduser $(whoami) mqm

Show more
Now your user account (not the account called "app") has been added to the group, we want to use these privileges to set up a queue manager. However, we need to make sure our MQ environment is set up. Do this by entering:

```
cd /opt/mqm/bin
. setmqenv -s
```

Show more
This means you can now enter MQ commands to do a variety of tasks, e.g. create and start a queue manager. The environment is now set up, but only for the current shell. You will need to repeat this step if you use another shell or terminal.

### Step 5. Create and configure a queue manager
Let's create and start a queue manager. Use the command crtmqm to create a queue manager called QM1:

```
crtmqm QM1
```

Show more
Start our new queue manager with:

```
strmqm QM1
```

Show more
Now we've got a queue manager, it's time to configure it and give it some MQ objects. We do this via a config script. Move to a folder you can download a file into and type:

```
wget mq-dev-config.mqsc https://raw.githubusercontent.com/ibm-messaging/mq-dev-samples/master/gettingStarted/mqsc/mq-dev-config.mqsc
```

Show more
Once the script has downloaded, run it:

```
runmqsc QM1 < "./mq-dev-config.mqsc"
```

Show more
This command runs the queue manager QM1 with input commands from the .mqsc script. You should see output like this:

Output from running the queue manager

Finally, to finish the process off, you need to add the authority to the mqclient group so that its members (i.e. the user "app") have the permission necessary to connect to a queue manager to put and get messages. Do this with the commands:

```
setmqaut -m QM1 -t qmgr -g mqclient +connect +inq
setmqaut -m QM1 -n DEV.** -t queue -g mqclient +put +get +browse +inq
```

Show more
Now, everything should be set up for you to use MQ! We'll test this below by sending our first message.

### Step 6. Put and get messages to and from a queue
So we've now got an installation of MQ that lets us connect to our preset queues and send messages.

If you're joining us again after using the bash script, welcome back! If you used the bash script, you'll need to do an extra step here, to allow your account to use the MQ commands. If you used the script, simply enter:

```
. /opt/mqm/bin/setmqenv -s
```

Show more
This will set your MQ environment for the current shell. This will need to be redone if you use a different shell or terminal. Done? Great, let's get on with sending messages.

In order to use a sample message putting program, amqsputc, we need to export a couple of environment variables.

```
export MQSERVER='DEV.APP.SVRCONN/TCP/localhost(1414)'
export MQSAMP_USER_ID='app'
```

Show more
MQSERVER specifies the endpoint of the queue manager. MQSAMP_USER_ID specifies the account that has permission to run the sample programs included with the MQ installation.

Remember, there's no need to log in as the user "app". Just run this terminal command to execute the message putting script:

```
cd /opt/mqm/samp/bin
./amqsputc DEV.QUEUE.1 QM1
```

Show more
This should prompt you for the password for user account "app". Enter this, then you will have the option to put one or more messages, separated by hitting ENTER, onto the queue DEV.QUEUE.1. When you're done putting messages, hit ENTER twice to commit them to the queue.

Finally, we can get the messages from our queue. Run:

```
./amqsgetc DEV.QUEUE.1 QM1
```

Show more
Enter the password for the user "app" and your messages should be returned. The program waits for 15 seconds, in case new messages arrive, then exits. The returned message should look something like this:

Output showing returned message

To learn how to install, access, and put and get a message on the queue using the MQ Console, follow the steps in this tutorial.

