package App::Plugin::Foo::Bar;

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

extends 'Gapp::App::Plugin';
with 'Gapp::App::Role::HasApp';

sub register {
    my ( $self ) = @_;
    
    my $app = $self->app;
    
    print "Registered plugin\n";
}



1;