#!perl

use strict;
use warnings;

use Test::NeedsDisplay ':skip_all';
use Test::More;

plan tests => 1;

use_ok('Padre::Plugin::HTML');
diag("Testing Padre::Plugin::HTML $Padre::Plugin::HTML::VERSION, Perl $], $^X");
