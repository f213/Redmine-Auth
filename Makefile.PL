use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Redmine::Auth',
    AUTHOR              => q{Fedor A Borshev <fedor@shogo.ru>},
    VERSION_FROM        => 'lib/Redmine/Auth.pm',
    ABSTRACT_FROM       => 'lib/Redmine/Auth.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'	=> 0,
	'Test::Class'	=> 0,
	'Digest::SHA'	=> 0,
	'DBI'		=> 0,

    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Redmine-Auth-*' },
);
