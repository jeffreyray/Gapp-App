#!/usr/bin/perl -w
use strict;
use warnings;


# create test application package

package App;

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

extends 'Gapp::App';

with 'Gapp::App::Role::HasPlugins';


# start testing


package main;
use Test::More tests => 3;

use Gapp;
use Gapp::App;

use_ok 'Gapp::App::Plugin';
use_ok 'Gapp::App::Plugin::MetaFile';
use_ok 'Gapp::App::Plugin::Manager';
use_ok 'Gapp::App::Plugin::Browser';

use Data::Dumper;


my $app = App->new;
ok $app, 'created application object';

my $pm = Gapp::App::Plugin::Manager->new( app => $app );
ok $pm, 'created plugin manager';

$pm->set_search_paths( 't/plugins' );

ok $pm->scan, 'scanned folders';

$pm->register_plugins;


my $browser = Gapp::App::Plugin::Browser->new( manager => $pm );
$browser->show_all;
$browser->refresh;

Gapp->main;


1;