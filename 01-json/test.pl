#!/usr/bin/env perl
use strict;
use warnings;
use Mojo::File;
use Mojo::JSON 'decode_json';

my $file = shift or die "usage: $0 file.json\n";
my $obj = decode_json(Mojo::File->new($file)->slurp);

my @errors = ();
push @errors, "/id missing"   unless exists $obj->{id};
push @errors, "/url missing"  unless exists $obj->{url};
push @errors, "/body missing" unless exists $obj->{body};
push @errors, "/user missing" unless exists $obj->{user};

if (exists $obj->{user}) {
    push @errors, "/user/login missing" unless exists $obj->{user}->{login};
    push @errors, "/user/id missing"    unless exists $obj->{user}->{id};
    push @errors, "/user/url missing"   unless exists $obj->{user}->{url};
    push @errors, "/user/type missing"  unless exists $obj->{user}->{type};

    push @errors, "value for /user/type is invalid"
      unless $obj->{user}->{type} =~ /^(?:user|admin|passer-by)/i;
}

die join "\n" => @errors if @errors;
