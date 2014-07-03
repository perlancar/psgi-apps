#!/usr/bin/env plackup

my $app = sub {
    my ($env) = @_;
    [
        200,
        ["Content-Type" => "text/plain"],
        ["hello, world"],
    ];
};
