#!/usr/bin/perl

use strict;
use Test::More tests => 6;

my ($class, $phash);

BEGIN {
    use_ok($class = 'Class::PseudoHash');
}

my(%h) = (Id => 1, Value =>2);
$phash = $class->new(\%h);

#use Data::Dumper;
#warn Dumper $phash;

is(scalar $#$phash, 2,	   'count');

@{$phash}[1..$#$phash] = qw/1 foo/;

is($phash->[1],     1,     'array access Id');
is($phash->{Id},    1,     'hash access Id');
is($phash->[2],     'foo', 'array access Value');
is($phash->{Value}, 'foo', 'hash access Value');
