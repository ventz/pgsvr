#!/usr/bin/perl
# Puppet Git Sync via REST
# Ventz Petkov
# ventz@vpetkov.net

use Dancer;

my $serializer = 'XML'; # or 'JSON'
my $port = 8080; # used for stand-alone app (not via Apache)


set serializer => $serializer;
set port => $port;
set startup_info => 0;
set log => 'error';
set logger => 'file';
 
# One way to create a token: "md5sum" and concat some initial + username
# ex: for user 'ventz', you can do: echo 'tk123ventz' | md5sum
my %users = (
    user => "21305f46bfddd24bf1c1074ad4ce3837",
);

any ['get', 'post'] => '/' => sub {
    return {message => "PGSVR - Puppet Git Sync via REST"};
};

any ['get', 'post'] => '/sync/:user/:token' => sub {
    my $user = params->{user};
    my $token = params->{token};

    if($token eq $users{$user}) {
        my $os = `lsb_release -is`; chomp($os);
        my $os_version = `lsb_release -rs`; chomp($os_version);

        if($os =~ /Ubuntu/) {
            `sudo /usr/local/bin/r10k synchronize`;
        }
        elsif($os =~ /(RedHat|CentOS)/) {
            if($os_version =~ /^6/) {
                `sudo /usr/local/bin/r10k deploy environment -p`;
            }
            elsif($os_version =~ /^5/) {
                `sudo /usr/local/bin/r10k synchronize`;
            }
        }
	    return{message => "Synching r10k on $os running $os_version..."};
    }
    else {
        return{message => "ERROR: Invalid user"};
    }
};


# Stand alone app (comment out for apache)
#print "Starting PGSVR...on port $port\n";
dance;
