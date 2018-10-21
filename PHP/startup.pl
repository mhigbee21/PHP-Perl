#!/usr/bin/perl
use strict;
use lib qw( /usr/local/apache/libs );
# Make sure we are in a sane environment.
$ENV{MOD_PERL} or die "not running under mod_perl!";

# copy the dir PHP-Perl and startup.pl to /usr/local/apache/libs
# You will most likely need to create the dir
# OR change the dir in use lib to the dir where you copied PHP-Perl

use PHP::Perl();

1;
