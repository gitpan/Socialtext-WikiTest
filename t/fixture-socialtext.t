#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw/no_plan/;
use lib 't/lib';
use Mock::Rester; # mocked
use Test::WWW::Selenium qw/$SEL/; # mocked

BEGIN {
    use lib 'lib';
    use_ok 'Socialtext::WikiObject::TestPlan';
}

my $rester = Mock::Rester->new;

Socialtext_fixture_tests: {
    st_fixture_ok(
        plan => <<EOT,
| st-page-title | monkey |
EOT
        tests => [
            [ 'text_like' => ['id=st-page-title', qr/\Qmonkey\E/]],
        ],
    );

    st_fixture_ok(
        plan => <<EOT,
| st-logoutin |
EOT
        tests => [
            [ 'click_ok' => 'link=Log out' ],
            [ 'wait_for_page_to_load' => 10000 ],
            [ 'open', '/nlw/login.html' ],
            [ 'type', ['username' => 'testuser']],
            [ 'type', ['password' => 'password']],
            [ 'click', q{//input[@value='Log in']}],
            [ 'wait_for_page_to_load' => 10000 ],
        ],
    );

    # Turn off watching, page already not watched
    st_fixture_ok(
        plan => <<EOT,
| st-watch-page | 0 |
EOT
        sel_setup => [
            [ 'get_attribute' => 'foo/watch-off.gif'],
        ],
        tests => [
            [ 'get_attribute' => q{//img[@id='st-watchlist-indicator']/@src} ]
        ],
    );

    # Turn on watching, page already watched
    st_fixture_ok(
        plan => <<EOT,
| st-watch-page | 1 |
EOT
        sel_setup => [
            [ 'get_attribute' => 'foo/watch-on.gif'],
        ],
        tests => [
            [ 'get_attribute' => q{//img[@id='st-watchlist-indicator']/@src} ]
        ],
    );

    # Turn on watching, page not watched
    st_fixture_ok(
        plan => <<EOT,
| st-watch-page | 1 |
EOT
        sel_setup => [
            [ 'get_attribute' => 'foo/watch-off.gif'],
            [ 'get_attribute' => 'foo/watch-off.gif'],
            [ 'get_attribute' => 'foo/watch-on.gif'],
        ],
        tests => [
            [ 'get_attribute' => q{//img[@id='st-watchlist-indicator']/@src} ],
            [ 'click_ok' => [q{//img[@id='st-watchlist-indicator']}, 
                             'clicking watch button'] ],
            [ 'get_attribute' => q{//img[@id='st-watchlist-indicator']/@src} ],
            [ 'get_attribute' => q{//img[@id='st-watchlist-indicator']/@src} ],
        ],
    );

    # Watchlist page: Turn on watching, page not watched
    st_fixture_ok(
        plan => <<EOT,
| st-watch-page | 1 | jabber |
EOT
        sel_setup => [
            [ 'get_attribute' => 'monkey'],
            [ 'get_attribute' => 'jabber'],
            [ 'get_attribute' => 'foo/watch-off.gif'],
            [ 'get_attribute' => 'foo/watch-off.gif'],
            [ 'get_attribute' => 'foo/watch-on.gif'],
        ],
        tests => [
            [ 'get_attribute' => 
              q{//table[@id='st-watchlist-content']/tbody/tr[2]/td[1]/img/@alt} ],
            [ 'get_attribute' => 
              q{//table[@id='st-watchlist-content']/tbody/tr[3]/td[1]/img/@alt} ],
            [ 'click_ok' => 
              [ q{//table[@id='st-watchlist-content']/tbody/tr[3]/td[1]/img},
                'clicking watch button'] ],
            [ 'get_attribute' => 
              q{//table[@id='st-watchlist-content']/tbody/tr[3]/td[1]/img/@src}],
            [ 'get_attribute' => 
              q{//table[@id='st-watchlist-content']/tbody/tr[3]/td[1]/img/@src}],
            [ 'get_attribute' => 
              q{//table[@id='st-watchlist-content']/tbody/tr[3]/td[1]/img/@src}],
        ],
    );

    # Watchlist page: Turn off watching, page watched
    st_fixture_ok(
        plan => <<EOT,
| st-watch-page | 0 | jabber |
EOT
        sel_setup => [
            [ 'get_attribute' => 'jabber'],
            [ 'get_attribute' => 'foo/watch-on.gif'],
            [ 'get_attribute' => 'foo/watch-off.gif'],
        ],
        tests => [
            [ 'get_attribute' => 
              q{//table[@id='st-watchlist-content']/tbody/tr[2]/td[1]/img/@alt} ],
            [ 'click_ok' => 
              [ q{//table[@id='st-watchlist-content']/tbody/tr[2]/td[1]/img},
                'clicking watch button'] ],
            [ 'get_attribute' => 
              q{//table[@id='st-watchlist-content']/tbody/tr[2]/td[1]/img/@src}],
            [ 'get_attribute' => 
              q{//table[@id='st-watchlist-content']/tbody/tr[2]/td[1]/img/@src}],
        ],
    );

    # Turn off watching, page watched
    st_fixture_ok(
        plan => <<EOT,
| st-watch-page | 0 |
EOT
        sel_setup => [
            [ 'get_attribute' => 'foo/watch-on.gif'],
            [ 'get_attribute' => 'foo/watch-off.gif'],
        ],
        tests => [
            [ 'get_attribute' => q{//img[@id='st-watchlist-indicator']/@src} ],
            [ 'click_ok' => [q{//img[@id='st-watchlist-indicator']}, 
                             'clicking watch button'] ],
            [ 'get_attribute' => q{//img[@id='st-watchlist-indicator']/@src} ],
        ],
    );

    # Check a page IS watched
    st_fixture_ok(
        plan => <<EOT,
| st-is-watched | 1 |
EOT
        sel_setup => [
            [ 'get_attribute' => 'foo/watch-on.gif'],
        ],
        tests => [
            [ 'get_attribute' => q{//img[@id='st-watchlist-indicator']/@src} ],
        ],
    );

    # Check a page is NOT watched
    st_fixture_ok(
        plan => <<EOT,
| st-is-watched | 0 |
EOT
        sel_setup => [
            [ 'get_attribute' => 'foo/watch-off.gif'],
        ],
        tests => [
            [ 'get_attribute' => q{//img[@id='st-watchlist-indicator']/@src} ],
        ],
    );

    # Search
    st_fixture_ok(
        plan => <<EOT,
| st-search | foo | bar |
EOT
        tests => [
            [ 'type_ok' => [ q{st-search-term}, 'foo' ] ],
            [ 'click_ok' => 'link=Search' ],
            [ 'wait_for_page_to_load' => 10000 ],
            [ 'text_like' => ['id=st-page-title', qr/\Qbar\E/] ],
        ],
    );

    # Search results
    st_fixture_ok(
        plan => <<EOT,
| st-result | foo |
EOT
        tests => [
            [ 'text_like' => ['id=st-search-content', qr/\Qfoo\E/] ],
        ],
    );

}

sub st_fixture_ok {
    my %args = @_;

    $rester->put_page('Test Plan', $args{plan});
    my $plan = Socialtext::WikiObject::TestPlan->new(
        rester => $rester,
        page => 'Test Plan',
        default_fixture => 'Socialtext',
        fixture_args => {
            host => 'selenium-server',
            username => 'testuser',
            password => 'password',
            browser_url => 'http://server',
            workspace => 'foo',
        },
    );

    if ($args{sel_setup}) {
        for my $s (@{$args{sel_setup}}) {
            push @{$SEL->{return}{$s->[0]}}, $s->[1];
        }
    }

    $plan->run_tests;

    is shift @{$SEL->{open}}, '/nlw/login.html';
    is_deeply shift @{$SEL->{type}}, ['username', 'testuser'];
    is_deeply shift @{$SEL->{type}}, ['password', 'password'];
    is shift @{$SEL->{click}}, q{//input[@value='Log in']};
    is shift @{$SEL->{wait_for_page_to_load}}, 10000;
    is shift @{$SEL->{open}}, '/foo';

    for my $t (@{$args{tests}}) {
        is_deeply shift @{$SEL->{$t->[0]}}, $t->[1];
    }

    ok delete $SEL->{stop};
}
