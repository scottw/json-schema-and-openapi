#!/usr/bin/env perl
use strict;
use warnings;
use Mojo::File;
use Mojo::JSON 'decode_json';
use Mojo::JSON::Pointer;

my $file    = shift or die "usage: $0 file.json\n";
my $obj     = decode_json(Mojo::File->new($file)->slurp);
my $pointer = Mojo::JSON::Pointer->new($obj);

my @fields = qw(/id /url /body /user /user/login /user/id /user/url /user/type);

my @errors = ();

for my $field (@fields) {
    push @errors, "$field missing"
      unless $pointer->contains($field);
}

push @errors, "value for /user/type is invalid"
  unless $obj->{user}->{type} =~ /^(?:user|admin|passer-by)/i;

die join "\n" => @errors if @errors;
