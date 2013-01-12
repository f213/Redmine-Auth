package Redmine::Auth::Test::AABase;
use base Test::Class;
use strict;
use warnings;
use Test::More;
use File::Slurp qw /read_file/;

sub init : Test(setup)
{
	my $self = shift;

	my($dsn, $user, $pass);
	
	eval
	{
		$dsn	= read_file ('./t/db_data/dsn');
		$user	= read_file ('./t/db_data/user');
		$pass	= read_file ('./t/db_data/pass');

	};
	$self->SKIP_ALL('This tests need real db data in t/db_data/[dsn, user, pass]. And a redmine DB copy of course') if not $dsn or not $user or not $pass;

	chomp $dsn;
	chomp $user;
	chomp $pass;

	$self->{dsn}	= $dsn;
	$self->{user}	= $user;
	$self->{pass}	= $pass;

}
sub initDsn
{
        my $self = shift;
	my $a = shift;
	
	$self->BAIL_OUT('Bad initDsn param - need instance of Redmine::Auth') if not $a->isa('Redmine::Auth');
	$a->dsn         ($self->{dsn});
	$a->dbUser      ($self->{user});
	$a->dbPass      ($self->{pass});

	$a;
}

sub authenticate
{
	my $self = shift;
	my $a = shift;
	$self->BAIL_OUT('Bad initDsn param - need instance of Redmine::Auth') if not $a->isa('Redmine::Auth');
	$self->initDsn($a);
	$a->login('fedor');
	$a->pass('123');
	$a->auth;
}

1;
