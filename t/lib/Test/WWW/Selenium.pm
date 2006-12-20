package Test::WWW::Selenium;
use strict;
use warnings;
use base 'Exporter';

our @EXPORT_OK = '$SEL';

our $SEL; # singleton

sub new {
    my ($class, %opts) = @_;
    return $SEL if $SEL;
    $SEL = { %opts };
    bless $SEL, $class;
    return $SEL;
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $name = $AUTOLOAD;
    $name =~ s/.+:://;
    return if $name eq 'DESTROY';

    my ($self, $opt1, $opt2) = @_;
    if ($opt2) {
        push @{$self->{$name}}, [$opt1, $opt2];
    }
    else {
        push @{$self->{$name}}, $opt1;
    }

    if ($self->{return}{$name}) {
        return shift @{$self->{return}{$name}};
    }
    return;
}

1;
