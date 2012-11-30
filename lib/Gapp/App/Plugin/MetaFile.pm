package Gapp::App::Plugin::MetaFile;


use Moose;
use MooseX::StrictConstructor;
use MooseX::SemiAffordanceAccessor;

use File::Basename;

use XML::LibXML;

# remember where file is located

has 'path' => (
    is => 'rw',
    isa => 'Str',
    default => '',
    trigger => sub { $_[0]->_clear_dir; },
);

has 'dir' => (
    is => 'rw',
    isa => 'Str',
    clearer => '_clear_dir',
    default => sub {
        my $dir = ( fileparse ( $_[0]->path ) )[1];
        chop $dir;
        return $dir;
    },
    lazy => 1,
);




# meta file attributes

has  [qw(author author_email author_url)] => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

has  [qw(copyright)] => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

has 'creation_date' => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

has  'description' => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

has 'id' => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

has 'license' => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

has 'name' => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

has 'version' => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

has 'class' => (
    is => 'rw',
    isa => 'Str',
    default => '',
);


# read an xml file

sub load_file {
    my ( $self, $path ) = @_;
    
    $self->set_path( $path );
   
    # load the document with LibXML
    my $doc = XML::LibXML->load_xml( location => $path );
    
    my $root = $doc->documentElement;
    
    for ( qw(id author author_email author_url class copyright creation_date description license name version ) ) {
        my $node = ($root->getChildrenByTagName( $_ ))[0];
        next if ! $node;
        
        my $value = $node->textContent;
        my $writer = 'set_' . $_;
        $self->$writer( $value );
    }
    
}

1;
