#!/usr/bin/perl
# Puppet Git Sync via REST
# Ventz Petkov
# ventz_petkov@harvard.edu

# Version: 0.0.1 - BETA

use Dancer;

my $serializer = 'XML'; # or 'JSON'
my $port = 8080;


set serializer => $serializer;
set port => $port;
set startup_info => 0;
set log => 'error';
set logger => 'file';
 
# One way to create a token: "md5sum" and concat some initial + username
# ex: for user 'ventz', you can do: echo 'tk123ventz' | md5sum
my %users = (
    ventz => "21305f46bfddd24bf1c1074ad4ce3837",
);

get '/' => sub {
    return {message => "PGSVR - Puppet Git Sync via REST"};
};

get '/sync/:user/:token' => sub {
    my $user = params->{user};
    my $token = params->{token};

    if($token eq $users{$user}) {
        `/usr/local/bin/r10k synchronize`;
	    return{message => "Synching r10k..."};
    }
    else {
        return{message => "ERROR: Invalid user"};
    }
};


# Stand alone app (comment out for apache)
#print "Starting PGSVR...on port $port\n";
dance;
