package Gapp::App::Roles::HasHooks;

use Moose::Role;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

has 'hooks' => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { { } },
    lazy => 1,
);

# call a hook
sub call_hook {
    my ( $self, $hook_name, @params ) = @_;
    return if ! $self->_hooks->{$hook_name};
    
    my $hook = $self->_hooks->{$hook_name};
    return if ! $hook;
    
    $hook->call( @params );
}

# define behavior of a hook
sub register_hook {
    my ( $self, $hook_name, %opts ) = @_;
   
    my $hook = Gapp::App::Plugin::Hook->new( name => $hook_name, %opts );
    $self->_hooks->{$hook_name} = $hook;
}

# register a callback to a hook
sub hook {
    my ( $self, $hook_name, $plugin, $function, $data ) = @_;
    
    # create a hook if it does not exist already
    $self->_hooks->{$hook_name} = $self->register_hook( $hook_name ) if ! $self->_hooks->{$hook_name};
    
    my $hook = $self->_hooks->{$hook_name};
    $hook->push( $plugin, $function, $data );
}
