package Gapp::App::Role::HasPluginManager;

use Moose::Role;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

with 'Gapp::App::Role::HasPlugins';

use Gapp::App::Plugin::Manager;

has 'plugin_manager' => (
    is => 'rw',
    isa => 'Gapp::App::Plugin::Manager',
    default => sub { Gapp::App::Plugin::Manager->new( app => $_[0] )  },
    lazy => 1,
);



1;

__END__

=pod

=head1 NAME

Gapp::App::Role::HasPluginManager - Role for app with managed plugins

=head1 SYNOPSIS

  package Foo::App;
  
  use Moose;

  extends 'Gapp::App';

  with 'Gapp::App::Role::HasPluginManager';

  sub BUILD {

    $self->plugin_manager->add_search_path( 'plugins/directory' );
    
    $self->plugin_manager->register_plugins;

  }

  
=head1 DESCRIPTION

A plugin manager object will scan a list of directories for plugins and register
them with the application.

=head1 PROVIDED ATTRIBUTES

=over 4

=item b<plugin_manager>

=over 4

=item is rw

=item isa Gapp::App::Plugin::Manager

=back

Plugin manager object.

=back

=head1 AUTHORS

Jeffrey Ray Hallock E<lt>jeffrey.hallock at gmail dot comE<gt>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2012 Jeffrey Ray Hallock.
    
    This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)
    
=cut

