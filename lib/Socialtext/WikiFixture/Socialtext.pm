package Socialtext::WikiFixture::Socialtext;
use strict;
use warnings;
use base 'Socialtext::WikiFixture::Selenese';
use Test::More;

=head1 NAME

Socialtext::WikiFixture::Selenese - Executes wiki tables using Selenium RC

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

This module is a subclass of Socialtext::WikiFixture::Selenese and includes
extra commands specific for testing a Socialtext wiki.

=head1 FUNCTIONS

=head2 new( %opts )

Create a new fixture object.  The same options as
Socialtext::WikiFixture::Selenese are required, as well as:

=over 4

=item workspace

Mandatory - Specifies which Socialtext workspace will be tested.

=item username

Mandatory - username to login to the wiki with.

=item password

Mandatory - password to login to the wiki with.

=back

=head2 init()

Creates the Test::WWW::Selenium object, and logs into the Socialtext
workspace.

=cut

sub init {
    my ($self) = @_;
    for (qw(workspace username password)) {
        die "$_ is mandatory!" unless $self->{$_};
    }

    $self->SUPER::init;

    $self->log_in;
    $self->{selenium}->open('/' . $self->{workspace});
}

=head2 log_in()

Logs into the Socialtext wiki using supplied username and password.

=cut

sub log_in {
    my $self = shift;
    my $sel = $self->{selenium};

    $sel->open('/nlw/login.html');
    $sel->type('username', $self->{username});
    $sel->type('password', $self->{password});
    $sel->click(q{//input[@value='Log in']});
    $sel->wait_for_page_to_load($self->{selenium_timeout});
    ok 1, "logged in";
}

=head2 st_page_title( $expected_title )

Verifies that the page title (NOT HTML title) is correct.

=cut

sub st_page_title {
    my ($self, $expected_title) = @_;
    $self->{selenium}->text_like('id=st-page-title', qr/\Q$expected_title\E/);
}

=head2 st_logoutin()

Logs out of the workspace, then logs back in

=cut

sub st_logoutin {
    my ($self, $opt1, $opt2) = @_;
    $self->click_and_wait('link=Log out');
    $self->log_in;
    ok 1, 'logged in';
}

=head2 st_search( $search_term, $expected_result_title )

Performs a search, and then validates the result page has the correct title.

=cut

sub st_search {
    my ($self, $opt1, $opt2) = @_;
    my $sel = $self->{selenium};

    $sel->type_ok('st-search-term', $opt1);
    $sel->click_ok('link=Search');
    $sel->wait_for_page_to_load($self->{selenium_timeout});
    $sel->text_like('id=st-page-title', qr/\Q$opt2\E/);
}

=head2 st_result( $expected_result )

Validates that the search result content contains a correct result.

=cut

sub st_result {
    my ($self, $opt1, $opt2) = @_;

    $self->{selenium}->text_like('id=st-search-content', qr/\Q$opt1\E/);
}

=head2 st_watch_page( $watch_on, $page_name, $verify_only )

Adds/removes a page to the watchlist.

If the first argument is true, the page will be added to the watchlist.
If the first argument is false, it will be removed from the watchlist.

If the second argument is not specified, it is assumed that the browser
is already open to a wiki page, and the opened page should be watched.

If the second argument is supplied, it is assumed that the browser
is on the watchlist page, and only the given page name should be watched.

If the 3rd argument is true, only checks will be performed as to whether
the specified page is watched or not.

=cut

sub st_watch_page {
    my ($self, $watch_on, $page_name, $verify_only) = @_;
    my $expected_watch = $watch_on ? 'on' : 'off';
    my $watch_re = qr/watch-$expected_watch(?:-list)?\.gif$/;
    $page_name = '' if $page_name and $page_name =~ /^#/; # ignore comments
    $verify_only = '' if $verify_only and $verify_only =~ /^#/; # ignore comments

    unless ($page_name) {
        return $self->_watch_page_xpath("//img[\@id='st-watchlist-indicator']", 
                                        $watch_re, $verify_only);
    }

    # A page is specified, so assume we're on the watchlist page
    # We need to find which row the page we're interested in is in
    my $sel = $self->{selenium};
    my $row = 2; # starts at 1, which is the table header
    while (1) {
        my $xpath = qq{//table[\@id='st-watchlist-content']/tbody/tr[$row]/td[1]/img};
        my $alt;
        eval { $alt = $sel->get_attribute("$xpath/\@alt") };
        last unless $alt;
        if ($alt eq lc($page_name)) {
            $self->_watch_page_xpath($xpath, $watch_re);
            last;
        }
        $row++;
    }
}

sub _watch_page_xpath {
    my ($self, $xpath, $watch_re, $verify_only) = @_;
    my $sel = $self->{selenium};

    my $xpath_src = "$xpath/\@src";
    my $src = $sel->get_attribute($xpath_src);
    if ($verify_only or $src =~ $watch_re) {
        like $src, $watch_re, "$xpath - $watch_re";
        return;
    }

    $sel->click_ok($xpath, "clicking watch button");
    my $timeout = time + $self->{selenium_timeout} / 1000;
    while(1) {
        my $new_src = $sel->get_attribute($xpath_src);
        last if $new_src =~ $watch_re;
        select undef, undef, undef, 0.25; # sleep
        if ($timeout < time) {
            ok 0, 'Timeout waiting for watchlist icon to change';
            last;
        }
    }
}

=head2 st_is_watched( $watch_on, $page_name )

Validates that the current page is or is not on the watchlist.

The logic for the second argument are the same as for st_watch_page() above.

=cut

sub st_is_watched {
    my ($self, $watch_on, $page_name) = @_;
    return $self->st_watch_page($watch_on, $page_name, 'verify only');
}

=head1 AUTHOR

Luke Closs, C<< <luke.closs at socialtext.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-socialtext-editpage at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Socialtext-WikiTest>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Socialtext::WikiFixture::Socialtext

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Socialtext-WikiTest>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Socialtext-WikiTest>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Socialtext-WikiTest>

=item * Search CPAN

L<http://search.cpan.org/dist/Socialtext-WikiTest>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Luke Closs, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
