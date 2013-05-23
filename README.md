pgsvr - Puppet Git Sync via REST
================================
Version: 0.0.1

Ventz Petkov
ventz@vpetkov.net

This is a BETA - it seems to work currently. It is FAR from complete.


To get it working, you need to:
-------------------------------

1.) Have a "dynamic git puppet environment"
You commit to git, and it picks up the branch and then creates the
appropriate puppet environment

Something like this in /etc/puppet/puppet.conf on the master:

environment = master

manifest    = $confdir/environments/$environment/manifests/site.pp

modulepath  = $confdir/modules:$confdir/environments/$environment/modules:$confdir/environments/$environment/dist:$confdir/environments/$environment/site


2.) install r10k
(https://github.com/puppetlabs-operations/puppet-r10k)


3.) Locate every r10k file and chown to 'puppet':
locate r10k | grep -v 'etc' | xargs -L1 chown puppet


4.) Then chown of just /etc/r10k.yaml to 'puppet'


5.) /etc/puppet/environments need to be owned by 'puppet' and group by apache (www-data on ubuntu)

6.) Take the 'pgsvr' repo and grab the 'pgsvr' apache config, and
enable it as a virtual host

7.) Take 'pgsvr' folder (inside the 'app' folder) and drop it in /var/www

8.) Go into the /var/www/pgsvr/bin/app.pl and create yourself an 'user
+ token' (see line about MD5 part). In reality, ANYTHING can be used
as a token.


How to Test it:
---------------

1.) Make sure /etc/puppet/environments is empty

2.) You can 'curl' call your rest service: curl -i -H "Accept:
application/xml" http://puppet.domain.tld/sync/$user/$token

Where $user is the 'user' you created
