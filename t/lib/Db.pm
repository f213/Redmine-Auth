package Redmine::Auth::Test::Db;
use base Redmine::Auth::Test::AABase;
use Test::More;
use strict;
use warnings;
use Redmine::Auth;

sub init_db_test : Test(3)
{
	my $self = shift;

	my $a = new Redmine::Auth;

	$self->initDsn($a);

	is($a->dsn, $self->{dsn}, 'Check setting DSN');
	is($a->dbUser, $self->{user}, 'Check setting user');
	is($a->dbPass, $self->{pass}, 'Check setting pass');
}
1;
