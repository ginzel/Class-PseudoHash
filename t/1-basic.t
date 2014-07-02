#!/usr/bin/perl

use strict;
use Test::More tests => 8;

my ($class, $phash);

BEGIN {
    use_ok($class = 'Class::PseudoHash');
}

$phash = $class->new;
my(@keys)= qw/hello hay hoo aiph/;
@{$phash}{@keys} = (1..@keys);

isa_ok($phash, $class, 'new()');

$phash->{hello} = 'hi';
$phash->{hay}   = 'hay';

is($phash->[1], 'hi', 'array access');
is($phash->{aiph}, 4, 'hash access');
eq_set([ keys(%$phash) ], \@keys, 'keys()');
is($#{$phash}, 4, 'fetchsize');
like("$phash", qr/^$class=ARRAY\(0x[0-9a-f]+\)$/, 'stringification');
is($phash ? 1 : 0, 1, 'bool context');
cmp_ok(10 + $phash, '!=', 10, 'numeric context');
