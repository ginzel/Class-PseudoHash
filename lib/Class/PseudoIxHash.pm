package Class::PseudoIxHash;

# ordered case-sensitive hash keys
# based on Class::PseudoHash and Hash::Case::Preserve
# http://cpansearch.perl.org/src/MARKOV/Hash-Case-1.02/lib/Hash/Case/Preserve.pm

#use 5.10.0;	# //=
use 5.12;	# each @array
use strict;
our $VERSION = '0.1';

# Study perldoc perltie and perldoc overload ('%{}') to understand internals of this modul.

our($Obj, $Proxy);
use constant NO_SUCH_INDEX => 'Bad index while coercing array into hash';
use overload (
    '%{}'  => sub { $Obj = $_[0]; return $Proxy },
    '""'   => sub { overload::AddrRef($_[0]) },
    '0+'   => sub {
	my $str = overload::AddrRef($_[0]);
	hex(substr($str, index($str, '(') + 1, -1));
    },
    'bool' => sub { 1 },
    'cmp'  => sub { "$_[0]" cmp "$_[1]" },
    '<=>'  => sub { "$_[0]" cmp "$_[1]" }, # for completeness' sake
    'fallback' => 1,
);

sub import { tie %{$Proxy}, shift; }

sub new {
    my $class = shift;
    my(@array) = ([{}, []], );	# keys => #, order of keys

    if (UNIVERSAL::isa($_[0], 'HASH')) {
	_croak('%s', "Ordered (Pseudo)Hash cannot be initialised from an unordered hash.\n"); # or sort keys?
    }
    elsif (UNIVERSAL::isa($_[0], 'ARRAY')) {
	foreach my $k (@{$_[0]}) {
	    $array[
		push(@{$array[0][1]}, $k),
		$array[0][0]{$k} = @array
	    ] = $_[1][$#array];
	}
    }
    else {
	while (my($k, $v) = splice(@_, 0, 2)) {
	    $array[
		push(@{$array[0][1]}, $k),
		$array[0][0]{$k} = @array
	    ] = $v;
	}
    }
    bless(\@array, $class);
}

sub array() : lvalue { @{$_[0]}[1..$#{$_[0]}]; }

sub FETCH($) {
    my $self = shift;
    my $key =  shift;

    $self = $$self;
    return $self->[
	$self->[0][0]{$key} >= 1	? $self->[0][0]{$key} :
	defined($self->[0][0]{$key})	? _croak(NO_SUCH_INDEX) : @$self
    ];
}

sub STORE($$) {
    my($self, $key, $value) = @_;

    $self = $$self;
    $self->[
	$self->[0][0]{$key} >= 1	? $self->[0][0]{$key} :
	defined($self->[0][0]{$key})	? _croak(NO_SUCH_INDEX) :
	(push(@{$self->[0][1]}, $key), $self->[0][0]{$key} = @$self)
    ] = $value;
}

sub _croak { require Carp; Carp::croak(sprintf(shift, @_)); }

sub TIEHASH(@) { bless \$Obj => shift; }

sub FIRSTKEY() {
    scalar @{${$_[0]}->[0][1]};
    $_[0]->NEXTKEY;
}

sub NEXTKEY($) {
    my $self = shift;
    $self = $$self;
    if (my($k) = each @{$self->[0][1]}) {
	return wantarray ? ($k, $self->[$self->[0][0]{$k}]) : $k;
    } else { return () }
}

sub EXISTS($) { exists ${$_[0]}->[0][0]{$_[1]} }

sub DELETE($) {
    my $self = shift;
    my $key = shift;
    $self = $$self;
    undef $self->{$key};
    splice @{$self->[0][1]}, $self->[0][0]{$key}-1, 1;
    delete $self->[0][0]{$key};
}

sub CLEAR() { @{${$_[0]}} = (); }

1;

__END__

=head1 NAME

Class::PseudoIxHash - Emulates Pseudo-Hash behaviour with case insensitive keys

=head1 VERSION

This document describes version 1.0 of Class::PseudoIHash, released
June 14, 2014.

=head1 SYNOPSIS

    use Class::PseudoIHash;

    my(@args)= ([qw/key1 key2 key3 key4/], [1..10]);
    my $ref2 = Class::PseudoIHash->new(@args);	# constructor syntax

    my(%hash)= (Id => 1, Value => 2);		# existing mapping
    my $ref3 = Class::PseudoIHash->new(\%hash);	# another constructor syntax
    ($ref3->array) = qw/1 foo/;			# array assignment
    $ref3->{Comment} = 'new key';		# == $ref3->[3]
    warn $ref3->{comment};			# 'new_key'

=head1 DESCRIPTION

Due to its impact on overall performance of ordinary hashes, pseudo-hashes
are deprecated in Perl 5.8.

As of Perl 5.10, pseudo-hashes have been removed from Perl, replaced by
restricted hashes provided by L<Hash::Util>.  Additionally, Perl 5.10 no
longer supports the C<fields::phash()> API.

Although L<perlref/Pseudo-hashes: Using an array as a hash> recommends
against depending on the underlying implementation (i.e. using the first
array element as hash indice), there are undoubtly many legacy codebase
still depending on pseudohashes; elimination of pseudo-hashes would
therefore require a massive rewrite of their programs.

Back in 2002, as one of the primary victims, I tried to devise a drop-in
solution that could emulate exactly the same semantic of pseudo-hashes, thus
keeping all my legacy code intact.  So C<Class::PseudoHash> was born.

Hence, if your code use the preferred C<fields::phash()> function, just write:

    use fields;
    use Class::PseudoHash;

then everything will work like before.  If you are creating pseudo-hashes
by hand (C<[{}]> anyone?), just write this instead:

    $ref = Class::PseudoHash->new;

and use the returned object in whatever way you like.

=head1 SEE ALSO

L<fields>, L<perlref/Pseudo-hashes: Using an array as a hash>

=head1 AUTHORS

Audrey Tang E<lt>cpan@audreyt.orgE<gt>
Hans Ginzel E<lt>hans@matfyz.cz<gt>

=head1 COPYRIGHT

Copyright 2001, 2002, 2007 by Audrey Tang E<lt>cpan@audreyt.orgE<gt>.

This software is released under the MIT license cited below.

=head2 The "MIT" License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

=cut

# vi: set ts=8 sw=4 nowrap:
