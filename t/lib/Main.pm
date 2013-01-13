package Redmine::Auth::Test::Main;
use base Redmine::Auth::Test::AABase;
use Test::More;
use strict;
use warnings;
use Redmine::Auth;


sub auth : Test(2)
{
	my $self = shift;

	my $a = new Redmine::Auth;

	$self->initDsn($a);

	$a->login('fedor');
	$a->pass('badpass');
	is($a->auth, 0, 'Authnenticating with bad data');

	$a->pass('123');

	is($a->auth, 1, 'Authenticating with good data');
}
sub manager : Test(3)
{
	my $self = shift;

	my $a = new Redmine::Auth;

	$self->authenticate($a);

	is($a->managerOf->count, 14, 'Check getting project list');
	is($a->managerOf(1), 1, 'Check if user is manager of one project');
	is($a->managerOf(100500), 0, 'Check if user is not manager of project');
}
sub admin : Test(2)
{
	my $self = shift;
	
	my $a = new Redmine::Auth;

	$self->initDsn($a);

	$a->login('Alexey');
	$a->pass('123');
	$a->auth();

	is($a->managerOf->count, 107, 'Check getting full project list for admin user');
	is($a->managerOf(100501), 1, 'Admin is a manager if project even does not exist');
}

	
1;
