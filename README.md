pgsvr - Puppet Git Sync via REST
================================
Version: 0.0.1

Ventz Petkov
ventz@vpetkov.net

This is a BETA - it works well currently, but it is FAR from complete.

NOTE: This requires r10k setup
(https://github.com/puppetlabs-operations/puppet-r10k)

Short Summary: This lets you configure a post-receive hook with your
git server/github that signals over REST so that an r10k run can
happen.


What is this?
-------------
If you are using puppet with git (github or your own server/repo), you
have realized really quickly that there are two 'hacky' ways to do it:
* keep the git server/repo on the puppet server
or
* glue some magic in via SSH from the git server to the puppet server

Partial Solutions: use r10k. You push your code to your git server, and the
r10k module on on your puppet master grabs it every X minutes (20 by
default, but you can configure it down to 1).

Still, that's NOT good enough! Can you imagine having to tell people
to wait a whole minute!

SOLUTION: PGSVR - you set it up on your puppet server, and you
configure github (or any git server) to have a post-receive hook that
simply signals your puppet server. This will initialize a r10k run.
Simple huh? Yep - simple but effective.


PGSVR Components and Quick Summary:
-----------------------------------
This is rather simple.

* You need r10k - "dynamic puppet environments" tied into Git 
* You need 2 perl modules (Dancer and Plack)
* An Apache server with a virtual config (I provide the site config)
* A cgi-root (I create it under /var/www/pgsvr with the apache config)
to drop the app itself.
* Other than that, you need to unfortunately
change all of the r10k files to be owned by the 'puppet' user.


To get it working, you need to:
-------------------------------
1. Have a "dynamic git puppet environment"
You commit to git, and it picks up the branch and then creates the
appropriate puppet environment

Something like this in /etc/puppet/puppet.conf on the master:

    environment = master
    manifest    = $confdir/environments/$environment/manifests/site.pp
    modulepath  = $confdir/modules:$confdir/environments/$environment/modules:$confdir/environments/$environment/dist:$confdir/environments/$environment/site

2. install r10k
(https://github.com/puppetlabs-operations/puppet-r10k)

3. Locate every r10k file and chown to 'puppet':
locate r10k | grep -v 'etc' | xargs -L1 chown puppet

4. Then chown of just /etc/r10k.yaml to 'puppet'

5. /etc/puppet/environments need to be owned by 'puppet' and group by apache (www-data on ubuntu)

6. Take the 'pgsvr' repo and grab the 'pgsvr' apache config, and
enable it as a virtual host. You will need 2 Perl modules:
Dancer (ubuntu: libdancer-perl) -> REST framework in Perl
Plack (ubuntu: libplack-perl) -> Interface for Perl webapp to interface with Apache/other web servers

7. Take 'pgsvr' folder (inside the 'app' folder) and drop it in /var/www

8. Go into the /var/www/pgsvr/bin/app.pl and create yourself an 'user
and token' (see line about MD5 part). In reality, ANYTHING can be used
as a token. It's just used for a super rudimentary way of
"authenticating".


How to Test it:
---------------

1. Make sure /etc/puppet/environments is empty

2. You can 'curl' call your rest service: curl -i -H "Accept:
application/xml" http://puppet.domain.tld/sync/$user/$token

Where $user is the 'user' you created


TODO:
-----

* Create a rest call to read a file of users/tokens
* Create real authentication

