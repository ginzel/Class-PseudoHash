#!/usr/bin/perl

use strict;
use Test::More tests => 5;

my ($class, $phash);

BEGIN {
    use_ok($class = 'Class::PseudoIxHash');
}

$phash = $class->new;

@{$phash}{qw/Id Value Comment/} = qw/1 s string/;

#use Data::Dumper;
#warn Dumper $phash;

is($phash->[2],       's',      'array access');
is($phash->{Comment}, 'string', 'hash access');
is_deeply([keys %{$phash}], [qw/Id Value Comment/], 'keys');
cmp_ok($phash->index('Comment'), '==', 3, 'index' );
delete $phash->{Value};
#warn Dumper $phash;
