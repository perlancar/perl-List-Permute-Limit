package List::Permute::Limit;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(
                    permute
                    permute_iter
            );

our %SPEC;

my %args_common = (
    items => {
        'x.name.is_plural' => 1,
        'x.name.singular' => 'item',
        schema => ['array*', min_len=>1],
        req => 1,
        pos => 0,
        greedy => 1,
    },
    nitems => {
        summary => 'Number of items of each permutation result',
        schema => 'posint*',
    },
);

$SPEC{permute_iter} = {
    v => 1.1,
    args => {
        %args_common,
    },
    result_naked => 1,
    result => {
        stream => 1,
    },
};
sub permute_iter {
    my %args = @_;
    my $items = $args{items};
    die "Please supply some items" unless $items && @$items;
    my $nitems = int($args{nitems} // @$items);
    die "Please supply a positive number of items (nitems)"
        unless $nitems > 0;

    my $state = [(0) x $nitems];
    my $state2 = 0; # 0,1,2
    my $iter = sub {
        if (!$state2) { # starting the first time, don't increment state yet
            $state2 = 1;
            goto L2;
        } elsif ($state2 == 2) { # all permutation exhausted
            return undef;
        }
        my $i = $#{$state};
      L1:
        while ($i >= 0) {
            if ($state->[$i] >= $#{$items}) {
                if ($i == 0) {
                    $state2 = 2;
                    return undef;
                }
                $state->[$i] = 0;
                my $j = $i-1;
                while ($j >= 0) {
                    if ($state->[$j] >= $#{$items}) {
                        if ($j == 0) { # all permutation exhausted
                            $state2 = 2;
                            return undef;
                        }
                        $state->[$j] = 0;
                        $j--;
                    } else {
                        $state->[$j]++;
                        last L1;
                    }
                }
                $i--;
            } else {
                $state->[$i]++;
                last;
            }
        }
      L2:
        return [map { $items->[ $state->[$_] ] } 0..$#{$state}];
    };
    $iter;
}

$SPEC{permute} = {
    v => 1.1,
    args => {
        %args_common,
    },
    result_naked => 1,
};
sub permute {
    my $p = permute_iter(@_);
    my @res;
    while (my $r = $p->()) { push @res, $r }
    @res;
}

1;
# ABSTRACT: Permute all items list, with limit of number of items per result item

=head1 SYNOPSIS

 use List::Permute::Limit qw(permute_iter permute);

 # iterator interface
 my $iter = permute_iter(items=>["zero","one","two","three"], nitems=>2);
 while (my $ary = $iter->()) {
     print "@{$ary}\n";
 }

will print:

 zero zero
 zero one
 zero two
 zero three
 one zero
 one one
 one two
 one three
 two zero
 two one
 two two
 two three
 three zero
 three one
 three two
 three three

To return the whole permutation in a list:

 # array interface
 my @res = permute(items=>["zero","one","two","three"], nitems=>2);
 # => (
 #   ["zero", "zero"],
 #   ["zero", "one"],
 #   ["zero", "two"],
 #   ["zero", "three"],
 #   ["one", "zero"],
 #   ["one", "one"],
 #   ["one", "two"],
 #   ["one", "three"],
 #   ["two", "zero"],
 #   ["two", "one"],
 #   ["two", "two"],
 #   ["two", "three"],
 #   ["three", "zero"],
 #   ["three", "one"],
 #   ["three", "two"],
 #   ["three", "three"],
 # )


=head1 DESCRIPTION

This is just yet another list permutor module, with a limit on the number of
items per result.


=head1 SEE ALSO

L<List::Permutor>, L<Math::Permute::List>

L<Algorithm::Permute> and variants.

L<Permute::Named>, L<Permute::Named::Iter>

=cut
