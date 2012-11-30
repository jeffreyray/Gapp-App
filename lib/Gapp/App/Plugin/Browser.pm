package Gapp::App::Plugin::Browser;

use Moose;

use Gapp::Moose;

use MooseX::StrictConstructor;
use MooseX::SemiAffordanceAccessor;

extends 'Gapp::Window';
with 'Gapp::App::Role::HasApp';


has 'manager' => (
    is => 'rw',
    isa => 'Gapp::App::Plugin::Manager',
    required => 1,
    weak_ref => 1,
);

has '+content' => (
    is => 'rw',
    default => sub {
        my ( $self ) = @_;
        [
            $self->vbox,
        ],
    },
    lazy => 1,
);

widget 'hbox' => (
    is => 'rw',
    traits => [qw( GappHBox )],
    construct => sub {
        my ( $self ) = @_;
        content => [
            Gapp::ScrolledWindow->new(
                content => [ $self->view ],
                policy => [qw(automatic automatic )],
                fill => 1,
                expand => 1,
            ),
            Gapp::Toolbar->new(
                orientation => 'vertical',
                content => [
                    Gapp::ToolButton->new(
                        label => 'Configure',
                        icon => 'gtk-preferences',
                    ),
                    Gapp::SeparatorToolItem->new,
                    Gapp::ToolButton->new(
                        label => 'Enable',
                        icon => 'gtk-apply',
                    ),
                    Gapp::ToolButton->new(
                        label => 'Disable',
                        icon => 'gtk-cancel',
                    ),
                    Gapp::SeparatorToolItem->new,
                    Gapp::ToolButton->new(
                        label => 'Install',
                        icon => 'gtk-connect',
                    ),
                    Gapp::ToolButton->new(
                        label => 'Uninstall',
                        icon => 'gtk-disconnect',
                    )
                ],
                expand => 0,
            ),
        ]
    }
);

widget 'vbox' => (
    is => 'rw',
    traits => [qw( GappVBox )],
    construct => sub {
        my ( $self ) = @_;
        spacing => 6,
        content => [
            Gapp::HBox->new(
                content => [
                    Gapp::Entry->new( fill => 0, expand => 0 ),
                ],
                fill => 1,
                expand => 0,
            ),
            $self->hbox,
            
            
            #Gapp::HBox->new(
            #    content => [
            #        Gapp::HButtonBox->new(
            #            content => [
            #                Gapp::Button->new( action => InstallPlugin ),
            #            ],
            #            fill => 0,
            #            expand => 0,
            #        ),
            #        Gapp::HButtonBox->new(
            #            content => [
            #                Gapp::Button->new( action => ConfigurePlugin ),
            #                Gapp::Button->new( action => DisablePlugin ),
            #                Gapp::Button->new( action => EnablePlugin ),
            #            ],
            #            fill => 1,
            #            expand => 1,
            #        ),
            #    ],
            #    fill => 1,
            #    expand => 0,
            #),

        ]
    },
    lazy => 1,
);

widget 'view' => (
    is => 'rw',
    traits => [qw( GappTreeView )],
    construct => sub {
        my ( $self ) = @_;
        model => $self->model,
        headers_visible => 0,
        columns => [
            [qw( icon Icon pixbuf 1 )],
            [qw( plugin Plugin markup 0), sub {
                my $text = '<b>' . $_->name . '</b>';
                $text .= "\n";
                $text .= $_->description;
                return $text;
            },
            {expand => 1}],
            [qw( active Active markup 3), sub {
                ! $_ ? '<b>Enabled</b>' : 'Disabled';
            }],
        ]
    },
    lazy => 1,
);

widget 'model' => (
    is => 'rw',
    gclass => 'Gapp::Model::List',
    construct => sub { },
    lazy => 1,
);


sub refresh {
    my ( $self ) = @_;
    
    my $pman = $self->manager;
    
    my $model = $self->view->model;
    $model->clear;

    for ( sort { lc $a->name cmp lc $b->name } $pman->meta_files ) {
        my $img = $_->dir . '/icon.png';
        
        my $pixbuf;
        
        if ( -e $img ) {
            $pixbuf = Gtk2::Gdk::Pixbuf->new_from_file_at_size ( $img, 48, 48 );
        }
        else {
            $pixbuf = $self->gobject->render_icon( 'gtk-about', 'dnd' );
        }
        
        
        $model->append_record( $_, $pixbuf, $pman->plugin( $_->id ), $pman->is_disabled( $_->id ) );
        
    }
}




1;
