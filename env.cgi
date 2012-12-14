#!/usr/bin/env plackup

use Data::Dump qw(dump);
use Plack::Request;

my $app = sub {
    my ($env) = @_;
    my $req = Plack::Request->new($env);
    [
        200,
        ["Content-Type" => "text/plain"],
        [
            "PSGI environment:\n\n", dump($env),
            "\n\n",
            "ENV:\n\n", dump(\%ENV),
            "\n\n",
            "GET vars:\n\n", dump($req->query_parameters),
            "\n\n",
            "POST vars:\n\n", dump($req->body_parameters),
        ]
    ];
};
