#!/usr/local/bin/plackup

use lib '../lib';
use Web::Paste::Simple;
Web::Paste::Simple->new->app;
