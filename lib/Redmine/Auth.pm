package Redmine::Auth;
use Badger::Class
	base		=> 'Badger::Base',
	mutators	=> 'dsn dbUser dbPass login pass authIsOk user',
	config    	=> '',
;

use DBI;
use Digest::SHA qw/sha1_hex/;
use Redmine::KPI::Config;
use Redmine::KPI::Element::User;
use Redmine::KPI::Query::Projects;

use warnings;
use strict;

our $MANAGER_ROLE = 3;

=head1 NAME

Redmine::Auth - Авторизуй своих юзеров через редмайн! This is a private ad-hoc module, tested againts Redmine 1.4

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Модуль нужен для авторизации пользователей на основе данных из редмайна. Используются данные о логинах\паролях и о членстве в проектах. Модуль тесно работает с Redmine::KPI, используя такие элементы как Element::User или как Query::Project. Поддерживает точно такую же инициализацию как и Redmine::KPI, то есть если ему скормить настройки доступа к Redmine, то дальше в коде можо плясать от него так же, как и от Redmine::KPI. Можно и не скармливать, тогда он будет просто работать, но при любой попытке получить данные, которые получает User или Query::Project, он упадет.
TODO - отвязать от Redmine::KPI если кому-то понадобится


    use Redmine::Auth;

    my $auth	= new Redmine::Auth;
    $auth->dsn('DBI:mysql:dbname=redmine_test;host=localhost');
    $auth->dbUser('user');
    $auth->dbPass('pass');

    $auth->login('fedor');
    $auth->pass('123');

    say "fedor:123 works!' if $auth->auth;

    say "fedor's name is " $auth->user->param('name');

    say "fedor is manager of " . $auth->managerOf->count . 'projects';
    say "end especialy of project with id 1" if $auth->managerOf(1);


=head1 EXPORT

none

=head1 SUBROUTINES/METHODS


=head2 init

Method needed for Badger::Base. Pod::Coverage - не ругайся пожалуйста!

=cut

sub init
{
	(my $self, my $config) = @_;

	$self->{config} = $self->configure($config);
	
	$self->authIsOk(0);

	$self;
}

=head2 auth

Check user credentials. Returns 0 if they are bad.

=cut

sub auth
{
	my $self = shift;

	return 1 if $self->authIsOk;
	
	my $res = $self->_dbh->prepare('SELECT id, login, firstname, lastname, mail, hashed_password, salt FROM users WHERE login = ?');

	$res->execute($self->login);

	return 0 if not $res->rows;

	my $userData = $res->fetchrow_hashref;
	
	if ($userData->{hashed_password} eq sha1_hex($userData->{salt} . sha1_hex($self->pass)))
	{
		$self->authIsOk(1);
		$self->user(Redmine::KPI::Element::User->new(
				id		=> $userData->{id},
				name		=> $userData->{firstname} . ' ' . $userData->{lastname},
				firstName	=> $userData->{firstname},
				lastName	=> $userData->{lastname},
				login		=> $userData->{login},
				mail		=> $userData->{mail},
				dryRun		=> 1,
				passConfigParams($self->{config}), 
			)
		);
		return 1;
	}
	return 0;
}

=head2 managerOf

	say 'User is manager of project with id 1' if($auth->managerOf(1));
	say 'User is manager of ' . $auth->managerOf->count . ' projects';
	
Returns bool if a numeric project id is given. 

Otherwise, returns list of projects, in wich users role is 'manager'.

Setting Redmine::KPI fetch parameters like 'authKey' and 'url' during class config will give one the ability to search by project names and other params. Lurk for Redmine::KPI::Query::Projects documentation.

=cut


sub managerOf
{
	my $self = shift;
	
	return $self->_projectListAsManager unless @_;

	return $self->_isManagerOf(@_);
}

sub _isManagerOf
{
	my $self = shift;

	return 1 if $self->_projectListAsManager->find(shift);
	0;
}


sub _projectListAsManager { shift->_projectList('manager', $MANAGER_ROLE) }


sub _projectList
{
	my $self 	= shift;
	my $listName 	= shift;
	my $roleId	= shift;

	return if not $self->authIsOk;

	return $self->{prjLists}{$listName} if exists $self->{lists}{$listName};

	my @prjIds;
	
	my $res = $self->_dbh->prepare('SELECT DISTINCT (members.project_id) AS prj_id
		FROM `members` , `member_roles`
		WHERE members.user_id = ?
		AND member_roles.role_id = ?
		AND member_roles.member_id = members.id;
	');
	
	$res->execute($self->user->param('id'), $roleId);

	while (my $row = $res->fetchrow_hashref)
	{
		push @prjIds, $row->{prj_id};
	}

	@prjIds = sort { $a <=> $b } @prjIds;

	$self->{prjLists}{$listName} = Redmine::KPI::Query::Projects->new(
		project	=> \@prjIds,
		passConfigParams($self->{config}), 
	);
}
sub _dbh
{
	
	my $self = shift;

	return $self->{dbh} if exists $self->{dbh};

	$self->{dbh} = DBI->connect($self->dsn, $self->dbUser, $self->dbPass);

}


=head1 AUTHOR

Fedor A Borshev, C<< <fedor at shogo.ru> >>

=head1 BUGS

Please report any bugs or feature requests to C<< <fedor at shogo.ru> >>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Redmine::Auth



=head1 LICENSE AND COPYRIGHT

Copyright 2013 Fedor A Borshev, shogo.ru


=cut

1; # End of Redmine::Auth
