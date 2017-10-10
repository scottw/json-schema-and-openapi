#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use JSON::Validator;
use Mojo::File;
use Mojo::JSON 'decode_json';

my $validator = JSON::Validator->new;
$validator->schema('address-schema.json');

my $data = Mojo::File->new('address.json')->slurp;
my $document = decode_json $data;

my @errors = $validator->validate($document);

die "@errors" if @errors;

say "lgtm";
