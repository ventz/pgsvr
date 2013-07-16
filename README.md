pgsvr - Puppet Git Sync via REST
================================
Version: 0.0.6

Ventz Petkov
ventz@vpetkov.net


PLEASE NOTE
-----------
* This is still a BETA - it works well, but it is FAR from complete.
* To use this "as is", it requires an r10k setup with Puppet (https://github.com/puppetlabs-operations/puppet-r10k)
* You can change one line and make it to work with just git or any other framework or custom written deploy/sync script.


Short Summary
-------------
PGSVR lets you configure a post-receive hook with your git
server/github/any other system, that signals over REST so that an r10k
run can happen.

It's a simply a fancy way to have a "git push" become "instant files" on your
puppet server.

When you have r10k (highly recommended), you also get dynamic environments
for free - so that each git branch becomes a puppet environment. You
also get the other features that r10k provides, like deploying modules
from github/puppet forge by just specifying a line in Puppetfile.

Don't have r10k? Not sure what it is, don't have time, or don't want to bother with it? No problem! By changing one line, you can have your "git push" simply end up mirroring a repo (syncing it) and then cloning it out into your puppet directory.

The goal of this is to provide you with a framework to translate a
REST call to a "something" on your puppet server.


Quick Setup and PGSVR Components
--------------------------------
This is rather simple. Don't let the length of this readme scare you!

* You need r10k - "dynamic puppet environments" tied into Git. Make sure that you disable CRON. We will run it only when there is a need. If you are not sure about this, look bellow for more details.

* Set a shell for your puppet user.

This is needed so that we can execute a "sudo" call for an r10k run:

    chsh -s /bin/bash puppet

* Edit your sudo-ers file (visudo)

For Ubuntu:

    Defaults env_keep = "http_proxy https_proxy"
    www-data    ALL= NOPASSWD: * /usr/local/bin/r10k

For RHEL/Centos:

    Defaults env_keep = "http_proxy https_proxy"
    apache2    ALL= NOPASSWD: * /usr/local/bin/r10k

* You need 2 perl modules (Dancer and Plack)
* An Apache server with a virtual config (I provide the site config - look through it)
* A cgi-root (I create it under /var/www/pgsvr with the apache config) to drop the app itself. Make sure it's owned by your web user.
* Create some "tokens" and configure the proxy variables. A token is a
unique string basically.


To get it working, you need to:
-------------------------------
* Have a "dynamic git puppet environment"
You commit to git, and it picks up the branch and then creates the
appropriate puppet environment

Something like this in /etc/puppet/puppet.conf on the master:

    environment = master
    manifest    = $confdir/environments/$environment/manifests/site.pp
    modulepath  = $confdir/modules:$confdir/environments/$environment/modules:$confdir/environments/$environment/dist:$confdir/environments/$environment/site

* Install r10k (https://github.com/puppetlabs-operations/puppet-r10k)

Make sure you install it with:

    class { 'r10k':
        configfile => 'puppet:///modules/some-module/r10k.yaml',
    }
    # Comment out since it HAS to run by the 'puppet' user
    # or -- modify the code to deploy cron for puppet user.
    #include r10k::cron

* Set a shell for your puppet user:

    chsh -s /bin/bash puppet

* Edit your sudo-ers file (visudo)

For Ubuntu:

    Defaults env_keep = "http_proxy https_proxy"
    www-data    ALL= NOPASSWD: * /usr/local/bin/r10k

For RHEL/Centos:

    Defaults env_keep = "http_proxy https_proxy"
    apache2    ALL= NOPASSWD: * /usr/local/bin/r10k

* /etc/puppet/environments need to be owned by 'puppet' and group by apache (www-data on ubuntu)

* Take the 'pgsvr' repo and grab the 'pgsvr' apache config, and
enable it as a virtual host.

* Take 'pgsvr' folder (inside the 'app' folder) and drop it in /var/www, and make sure everything is owned by your web user.

* You will need to install 2 Perl modules:
    * Dancer (ubuntu: libdancer-perl) -> REST framework in Perl
    * Plack (ubuntu: libplack-perl) -> Interface for Perl webapp to interface with Apache/other web servers

* Go into the /var/www/pgsvr/bin/app.pl and create yourself an 'user
and token' (see line about MD5 part). In reality, ANYTHING can be used
as a token. It's just used for a super rudimentary way of
"authenticating".

* If you use a proxy, please enter it in the apache virtual config file. The variables are passed through sudo to the app.


How to Test it:
---------------
* Make sure /etc/puppet/environments is empty
* You can 'curl' call your rest service: curl -i -H "Accept:
application/xml" http://puppet.domain.tld/sync/$user/$token

Where $user is the 'user' you created

* Now check if /etc/puppet/environments filled up -- that is, assuming you have checked in a git repo ;)


Background - What is this/How did it come about?
------------------------------------------------
If you are using puppet with git (github or your own server/repo), you
have realized really quickly that there are two 'hacky' ways to do it:
keep the git server/repo on the puppet server or glue some magic in
via SSH from the git server to the puppet server

####Partial Solution:
Use r10k. You push your code to your git server, and the
r10k module on on your puppet master grabs it every X minutes (20 by
default, but you can configure cron down to 1).

Still, that's NOT good enough! Can you imagine having to tell people
to wait a whole minute!

####Solution: PGSVR
You set it up on your puppet server, and you configure github (or any
git server) to have a post-receive hook that simply signals your
puppet server. This will initialize a r10k run (or anything else). Simple huh? Yep - simple but effective.



TODO:
-----
* Create a rest call to read a file of users/tokens
* Create a config file for the http(s)-proxy variables
* Create real authentication, and add to config

