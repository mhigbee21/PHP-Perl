#!/usr/bin/perl
use strict;
use lib qw( /usr/local/apache/libs );
# Make sure we are in a sane environment.
$ENV{MOD_PERL} or die "not running under mod_perl!";

# Directions
# copy the dir PHP and startup.pl to /usr/local/apache/libs
# You will most likely need to create the dir
# OR change the dir in use lib to the dir where you copied PHP-Perl
#
# Add this to httpd.conf file
# PerlRequire /usr/local/apache/libs/startup.pl
# or use the dir where you coppied startup.pl too...
#


use PHP::Perl();

1;
