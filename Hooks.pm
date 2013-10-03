
package GD::Graph::Hooks;

use strict;
use Carp;
use GD::Graph::axestype;
use constant {
    POST_INIT => 0,
    PRE_TEXT  => 0,

    POST_TEXT  => 1,
    PRE_AXIS   => 1,

    POST_AXIS  => 2,
    PRE_DATA   => 2,

    POST_DATA  => 3,
    PRE_VALUES => 3,

    POST_VALUES => 4,
    PRE_LEGEND  => 4,

    POST_LEGEND  => 5,
    PRE_RETURN   => 5,
};

sub validate {
    my $slot = shift;
    $slot >= 0 and $slot <= 5;
}

our $VERSION = "1.0000";

{
    no warnings; # hackery below, no warnings in here thanks

    *GD::Graph::axestype::add_hook = sub {
        my $this = shift;
        my $slot = int shift; croak "slot unknown" unless validate($slot);
        my $code = shift;
        my $hook = ref($code) eq "CODE" ? $code : sub { eval $code };

        push @{$this->{_hooks}{$slot}}, $hook;
    };

    *GD::Graph::axestype::call_hooks = sub {
        my $this = shift;
        my $slot = shift;

        return unless exists $this->{_hooks}{$slot};

        for my $f (@{$this->{_hooks}{$slot}}) {
            $f->( $this, @$this{qw(graph left right top bottom gdta_x_axis gdta_y_axis)} );
        }
    };

    *GD::Graph::axestype::plot = sub {
        my $self = shift;
        my $data = shift;

        $self->check_data($data)            or return;
        $self->init_graph()                 or return;
        $self->setup_text()                 or return;
        $self->setup_legend();
        $self->setup_coords()               or return;
        $self->call_hooks(POST_INIT);
        $self->draw_text();
        $self->call_hooks(POST_TEXT);
        unless (defined $self->{no_axes}) {
            $self->draw_axes();
            $self->draw_ticks()             or return;
        }
        $self->call_hooks(POST_AXIS);
        $self->draw_data()                  or return;
        $self->call_hooks(POST_DATA);
        $self->draw_values()                or return;
        $self->call_hooks(POST_VALUES);
        $self->draw_legend();
        $self->call_hooks(POST_LEGEND);

        return $self->{graph}
    };
}

1;
