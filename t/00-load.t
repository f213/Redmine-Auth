#!perl -T

use Test::More tests => 2;

BEGIN {
    use_ok( 'Redmine::Auth' ) || print "Bail out!\n";
    new_ok( 'Redmine::Auth' ) || print "Bail out!\n";
}

diag( "Testing Redmine::Auth $Redmine::Auth::VERSION, Perl $], $^X" );
