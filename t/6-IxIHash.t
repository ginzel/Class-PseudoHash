#!/usr/bin/perl

use strict;
use Test::More tests => 4;

my ($class, $phash);

BEGIN {
    use_ok($class = 'Class::PseudoIxIHash');
}

$phash = $class->new;

@{$phash}{qw/Id Value Comment/} = qw/1 s string/;

#use Data::Dumper;
#warn Dumper $phash;

is($phash->[2],       's',      'array access');
is($phash->{comment}, 'string', 'hash access');
is_deeply([keys %{$phash}], [qw/Id Value Comment/], 'keys');
delete $phash->{value};
#warn Dumper $phash;
