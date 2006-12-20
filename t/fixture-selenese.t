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

Simple_selenese: {
    $rester->put_page('Test Plan', <<EOT);
* Fixture: Selenese
| *Command* | *Option 1* | *Option 2* |
| open | / |
| verifyTitle | monkey |
| verifyTextPresent | water |
| verifyText | //body | pen? |
| verifyText | //body | qr/pen?/ |
| confirmation_like | pen? |
| confirmation_like | qr/pen?/ |
| clickAndWait | foo | |
EOT
    my $plan = Socialtext::WikiObject::TestPlan->new(
        rester => $rester,
        page => 'Test Plan',
        fixture_args => {
            host => 'selenium-server',
            browser_url => 'http://server',
            workspace => 'foo',
        },
    );
    $plan->run_tests;
    is shift @{$SEL->{open}}, '/';
    is shift @{$SEL->{title_like}}, qr/\Qmonkey\E/;
    is_deeply shift @{$SEL->{text_like}}, ['//body', qr/\Qwater\E/];
    is_deeply shift @{$SEL->{text_like}}, ['//body', qr/\Qpen?\E/];
    is_deeply shift @{$SEL->{text_like}}, ['//body', qr/pen?/];
    is shift @{$SEL->{confirmation_like}}, qr/\Qpen?\E/;
    is shift @{$SEL->{confirmation_like}}, qr/pen?/;
    is shift @{$SEL->{click_ok}}, 'foo';
    is shift @{$SEL->{wait_for_page_to_load}}, 10000;
    ok delete $SEL->{stop};
}

Specific_timeout: {
    $rester->put_page('Test Plan', <<EOT);
* Fixture: Selenese
| clickAndWait | foo | |
EOT
    my $plan = Socialtext::WikiObject::TestPlan->new(
        rester => $rester,
        page => 'Test Plan',
        fixture_args => {
            host => 'selenium-server',
            browser_url => 'http://server',
            workspace => 'foo',
            selenium_timeout => 9,
        },
    );
    $plan->run_tests;
    is shift @{$SEL->{click_ok}}, 'foo';
    is shift @{$SEL->{wait_for_page_to_load}}, 9;
    ok delete $SEL->{stop};
}

