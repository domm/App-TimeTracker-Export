package App::TimeTracker::Command::Export;

# ABSTRACT: Export times worked as CSV
# VERSION

use strict;
use warnings;
use 5.010;

use Moose::Role;
use DateTime;

sub cmd_export {
    my $self = shift;

    my @files = $self->find_task_files(
        {   from     => $self->from,
            to       => $self->to,
            projects => $self->fprojects,
            tags     => $self->ftags,
            parent   => $self->fparent,
        }
    );
    foreach my $file (@files) {
        my $task    = App::TimeTracker::Data::Task->load( $file->stringify );
        say join(';',$task->start, $task->stop, $task->seconds, $task->duration, $task->project, $task->description);
    }
}

sub _load_attribs_export {
    my ( $class, $meta ) = @_;
    $class->_load_attribs_worked($meta);
}

no Moose::Role;
1;

__END__

=head1 DESCRIPTION

Export your time as CSV.

=head1 CONFIGURATION

=head1 NEW COMMANDS

=head2 export

