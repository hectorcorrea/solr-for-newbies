## == Installing Solr for the first time

### === Prerequisites

To run Solr on your machine you need to have the Java Development Kit (JDK)
installed. To verify if that the JDK is installed run the following command
from the Terminal (aka Command Prompt if you are on Windows):

```
$ java --version

  #
  # java version "9.0.1"
  # Java(TM) SE Runtime Environment (build 9.0.1+11)
  # Java HotSpot(TM) 64-Bit Server VM (build 9.0.1+11, mixed mode)
  #
```

If the JDK is installed on your machine you'll see the text indicating
the version that you have (e.g. "9.0.1" above). The specific Java version
does not matter much as long as the previous command displays a version
of Java, you should be OK.

If you don't have the JDK installed you'll see something like

```
  #
  # -bash: java: command not found
  #
```

**Note for Mac users:** After running the `java -version` command above if the JDK is not installed the Mac might give a prompt to install Java. If you follow the prompt's instructions you will be installing the Java Runtime Environment (JRE) which *it is not what you need to run Solr*. It won't hurt to install the JRE but you it won't help you either. You can ignore that prompt.

If Java *is installed* on your machine skip the "Installing Java" section below and jump to the "Installing Solr" section. If Java *is not installed* on your machine follow the steps below to install it.


### === Installing Java

To install the Java Development Kit (JDK) go to  http://www.oracle.com/technetwork/java/javase/downloads/index.html and select the option to download the "Java Platform (JDK) 9".

From there, under the "Java SE Development Kit 9.0.1" select the file appropriated for your operating system, accept the license agreement, and download it. For example, for the Mac the file would be `jdk-9.0.1_osx-x64_bin.dmg`.

Run the installer that you downloaded. Once it has completed, go back to the Terminal and run the `java -version` command again. You should see the text with the Java version number this time.


### === Installing Solr

You can find download links for Solr at the [Apache Solr](https://lucene.apache.org/solr/) site. To make it easy, below are the steps to download and install version 7.1 which is the one that we will be using.

First, download Solr and save it to a file.

```
$ cd
$ curl http://mirror.cc.columbia.edu/pub/software/apache/lucene/solr/7.1.0/solr-7.1.0.zip > solr-7.1.0.zip

  #
  # You'll see something like this...
  # % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
  #                                Dload  Upload   Total   Spent    Left  Speed
  # 100  146M  100  146M    0     0  7081k      0  0:00:21  0:00:21 --:--:-- 8597k
  #
```

Then unzip the downloaded file with the following command:

```
$ unzip solr-7.1.0.zip

  #
  # A ton of information will be displayed here as Solr is being
  # decompressed/unzipped. Most of the lines will say something like
  # "inflating: solr-7.1.0/the-name-of-a-file"
  #
```

Now that Solr has been installed on your machine you will have a folder named `solr-7.1.0`. This folder has the files to run and configure Solr. The Solr binaries (i.e. the Java JAR files) are under `solr-7.1.0/dist` but for the most part we will use the utilities under `solr-7.1.0/bin` to start and stop Solr.

First, let's make sure we can run Solr by executing the `solr` shell script with the `status` parameter:

```
$ cd ~/solr-7.1.0/bin
$ ./solr status

  #
  # No Solr nodes are running.
  #
```

The "No Solr nodes are running" message is a bit anticlimactic but it's exactly what we want since it indicates that Solr is ready to be run.

**Note for Windows users:** In Windows use the `solr.cmd` batch file instead of the `solr` shell script, in other words, use `solr.cmd status` instead of `./solr status`.


### === Let's get Solr started

To start Solr run the `solr` script again but with the `start` parameter:

```
$ cd ~/solr-7.1.0/bin
$ ./solr start

  #
  # Waiting up to 180 seconds to see Solr running on port 8983 [-]  
  # Started Solr server on port 8983 (pid=85830). Happy searching!
  #
```

Notice that the message says that Solr is now running on port `8983`.

You can validate this by opening your browser and going to http://localhost:8983/. This will display the Solr Admin page from where you can perform administrative tasks as well as add, update, and query data from Solr.

You can also issue the `status` command again from the Terminal and Solr will report something like this:

```
$ cd ~/solr-7.1.0/bin
$ ./solr status

  # Found 1 Solr nodes:
  #
  # Solr process 86348 running on port 8983
  # {
  # "solr_home":"/some/path/solr-7.1.0/server/solr",
  # "version":"7.1.0 84..0659 - ubuntu - 2017-10-13 16:15:59",
  # "startTime":"2017-11-11T22:12:15.497Z",
  # "uptime":"0 days, 0 hours, 0 minutes, 12 seconds",
  # "memory":"26.4 MB (%5.4) of 490.7 MB"}
  #
```

Notice how Solr now reports that it has "Found 1 Solr node". Yay!


### === Adding Solr to your path (optional)

In the previous examples we always made sure we were at the Solr `bin` folder in order to run the Solr commands. You can eliminate this step by making sure Solr is in your PATH. For example if Solr is installed on your home folder (`~/solr-7.1.0`) you can run the following commands:

```  
$ cd
$ PATH=~/solr-7.1.0/bin:$PATH
$ which solr

  #
  # /your-home-folder/solr-7.1.0/bin/solr
  #  
```

If you don't do this you will need to make sure that you always refer to Solr with the full path, for example `~/solr-7.1.0/bin/solr`.
