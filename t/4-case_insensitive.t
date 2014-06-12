#!/usr/bin/perl

use strict;
use Test::More tests => 4;

my ($class, $phash);

BEGIN {
    use_ok($class = 'Class::PseudoIHash');
}

$phash = $class->new;

$Class::PseudoIHash::FixedKeys = 0;
$phash->{Foo} = 'bar';

#use Data::Dumper;
#warn Dumper $phash;

is($phash->[1],   'bar', 'array access');
is($phash->{foo}, 'bar', 'hash access');
is_deeply([keys %{$phash}], [qw/Foo/], 'keys');
delete $phash->{foo};
#warn Dumper $phash;
