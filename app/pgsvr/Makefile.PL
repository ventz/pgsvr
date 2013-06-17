use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'pgsvr',
    AUTHOR              => q{Ventz Petkov <ventz@vpetkov.net>},
    VERSION_FROM        => 'lib/pgsvr.pm',
    ABSTRACT            => 'PGSVR - Puppet GIT Sync via REST',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'YAML'       => 0,
        'Dancer'     => 1.3091,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'pgsvr-*' },
);
