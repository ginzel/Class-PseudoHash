#!/usr/bin/perl

use strict;
use Test::More tests => 5;

my ($class, $phash);

BEGIN {
    use_ok($class = 'Class::PseudoHash');
}

$phash = $class->new;

$Class::PseudoHash::FixedKeys = 0;
$phash->{foo} = 'bar';

#use Data::Dumper;
#warn Dumper $phash;

is($phash->[1],   'bar', 'array access');
is($phash->{foo}, 'bar', 'hash access');
is_deeply([keys %{$phash}], [qw/foo/], 'keys');
cmp_ok($phash->index('foo'), '==', 1, 'index' );

#delete $phash->{foo};
#warn Dumper $phash;
