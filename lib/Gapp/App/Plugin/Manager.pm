package Gapp::App::Plugin::Manager;

use Moose;
use MooseX::StrictConstructor;
use MooseX::SemiAffordanceAccessor;


use Gapp::App::Plugin::MetaFile;


has 'app' => (
    is => 'rw',
    isa => 'Gapp::App',
    weak_ref => 1,
    required => 1,
);

has 'index' => (
    is => 'ro',
    isa => 'HashRef', 
    traits => [qw( Hash )], 
    writer => '_set_index',
    init_arg => undef,
    default => sub { { } },   
    handles => {
        plugin_ids => 'keys',
    },
);

has 'meta_file_class' => (
    is => 'rw',
    isa => 'Str',
    default => 'Gapp::App::Plugin::MetaFile',
);

has 'search_paths' => (
    writer => '_set_search_paths',
    isa => 'ArrayRef',
    default => sub { [ 'res/plugins'] },
    traits => [qw( Array )],
    handles => {
        add_search_path => 'push',
        search_paths => 'elements',
    }
);


sub disable {
    my ( $self, $id ) = @_;

    $self->index->{$id}{disabled} = 1;
}
sub enable {
    my ( $self, $id ) = @_;
    $self->index->{$id}{disabled} = 0;
}

sub is_disabled {
    my ( $self, $id ) = @_;
    $self->index->{$id}{disabled}; 
}

sub meta_files {
    my ( $self ) = @_;
    return map { $self->index->{$_}{meta_object} } $self->plugin_ids;
}

sub plugin {
    my ( $self, $id ) = @_;
    $self->index->{$id}{plugin}; 
}

sub set_search_paths {
    my ( $self, @paths ) = @_;
    $self->_set_search_paths( \@paths );
}

sub scan {
    my ( $self ) = @_;
    
    my $index = $self->index;
    
    # parse the meta file
    my $meta_class = $self->meta_file_class;
    
    for my $path ( $self->search_paths ) {
        
        my $rxpath = quotemeta $path;
        
        
        for my $f ( <$path/*> ) {
            next if ! -d $f;              # skip regular files
            
            $f =~ s/^$rxpath(\\?\/)?//;   # remove the path name from the begininng of the file
            
            my $xml_path = "$path/$f/$f.xml";
            
            # if the plugin xml file exists
            if ( -e $xml_path ) {
                
                # if the meta object has not been loaded, do it now
                if ( $index->{$f} || ! $index->{$f}->{ meta_object } ) {
                    
                    my $meta = $meta_class->new;
                    $meta->load_file( $xml_path );
                    
                    $index->{$f}->{ meta_object } = $meta;
                }
              
            }
            
            
        }
    }
    
    return $index;
}

sub register_plugin {
    my ( $self, $id ) = @_;
    
    # don't register the plugin if it is disabled
    return if $self->index->{$id}->{disabled};
    
    my $meta = $self->index->{$id}->{ meta_object };
    
    return if ! $meta;
    
    # add path to lib
    unshift @INC, $meta->dir . '/lib' if -d $meta->dir . '/lib';
    
    my $class = $meta->class;
    
    use Module::Load qw( load );
    load "$class";
    
    my $plugin = $class->new;
    
    $self->index->{$id}->{ plugin } = $plugin;
    
    $self->app->register_plugin( $id, $plugin );
}

sub register_plugins {
    my ( $self ) = @_;
    
    $self->scan;
    
    for ( $self->plugin_ids ) {
        
        # register the plugin if it is not already and is not disabled
        if ( ! $self->index->{$_}->{plugin} && ! $self->index->{$_}->{disabled} ) {
            
            $self->register_plugin( $_ );
            
        }
        
    }
}





1;
