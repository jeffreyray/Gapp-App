package Gapp::App::Roles::HasComponents;

use Moose::Role;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

use Gapp::App::Hook;

use MooseX::Types::Moose qw( Str Object );

has '_components' => (
    is => 'ro',
    isa => 'HashRef',
    traits => [qw( Hash )],
    default => sub { { } },
    handles => {
        com => 'get',
    },
    lazy => 1,
);


sub register_component {
    my ( $self, $name, $com ) = @_;
    
    $self->meta->throw_error( 'usage $app->register_component( $name, $com )' ) if ! $name || ! $com;
    
    $com->set_app( $self );
    
    $com->register;
    
    $self->_components->{ $name } = $com;
    
    return $com;
}


1;

__END__

=pod

=head1 NAME

Gapp::App::Roles::HasComponents - Role for app with components

=head1 SYNOPSIS

  package Foo::App;
  
  use Moose;

  extends 'Gapp::App';

  with 'Gapp::App::Roles::HasComponents';

  sub BUILD {

    ( $self ) = @_;
    
    $com = .... ; # your custom component here

    $self->register_component( 'foo', $com );

  }

  package main;

  $app = Foo::App->new;
  
  $app->com('foo')->browser->show_all;

  
=head1 DESCRIPTION

Applications built using components are highly extensible. 

=head1 PROVIDED METHODS

=over 4

=item B<com $name>

Returns the component object registered with the given C<$name>.

=item B<register_component $name, $com>

Register the component with the application.

=head1 AUTHORS

Jeffrey Ray Hallock E<lt>jeffrey.hallock at gmail dot comE<gt>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2012 Jeffrey Ray Hallock.
    
    This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)
    
=cut

