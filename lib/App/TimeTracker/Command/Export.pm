package App::TimeTracker::Command::Export;

# ABSTRACT: Export times worked as CSV
# VERSION

use strict;
use warnings;
use 5.010;

use Moose::Role;
use DateTime;
use Text::CSV_XS;
use Moose::Util::TypeConstraints;

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

    my $fields = $self->fields;
    if ($self->config->{export}{fields}) {
        $fields = $self->config->{export}{fields};
    }

    my $project_map = $self->config->{export}{project_map} || {};

    my $do_tmpl = sub {
        my ($f, $task) = @_;
        my $acc = $f;
        $acc =~ s/[^a-z0-9_]//g;
        my $val = $task->$acc;
        if ($val) {
            $f =~ s/$acc/$val/;
            return $f;
        };
        return '';
    };

    my @res;
    foreach my $file (@files) {
        my $task    = App::TimeTracker::Data::Task->load( $file->stringify );
        my @line;
        for my $fld (@$fields) {
            if (not defined $fld) {
                push(@line,'');
            }
            elsif ($fld =~/^strftime\((.*?),(.*)\)$/) {
                push(@line, $task->$1->strftime($2));
            }
            elsif ($fld eq 'billing') {
                my $p = $self->config->{billing}{prefix};
                my ($billing) = grep {  /^$p/ } $task->tags->@*;
                if ($billing) {
                    $billing =~ s/^$p//;
                    push(@line,$billing);
                }
                else {
                    push(@line, $self->config->{export}{billing_default} // '?');
                }
            }
            elsif ($fld =~ /^join\((?<def>.*?)\)$/) {
                my $definition = $+{def};
                $definition =~ s/{(.*?)}/$do_tmpl->($1, $task)/ge;
                push(@line, $definition);
            }
            elsif ($fld =~ /^duration/) {
                if (my $dur = $task->duration) {
                    if ($fld eq 'duration(H:M)') {
                        $dur = substr($dur,0,-3);
                    }
                    push(@line,$dur);
                }
                else {
                    push(@line, "current!");
                }
            }
            elsif ($fld =~ /^literal\((.*?)\)$/) {
                push(@line, $1);
            }
            elsif ($fld eq 'project') {
                push(@line, $project_map->{ $task->project} || $task->project);
            }
            else {
                push(@line, $task->$fld);
            }
        }
        push (@res, [map { $_ || '' } @line]);
    }

    say join("\n",map { join(';',@$_) } @res);

}

sub _load_attribs_export {
    my ( $class, $meta ) = @_;
    $class->_load_attribs_worked($meta);

    $meta->add_attribute(
        'group' => {
            isa           => enum( [qw(none hase)] ),
            is            => 'ro',
            default       => 'none',
            documentation => 'Generet a report by week or project.'
        }
    );

    $meta->add_attribute(
        'fields' => {
            isa           => 'ArrayRef',
            is            => 'ro',
            default       => sub {['strftime(start,%F)','duration(H:M)','project','join({#id} {description})']},
            documentation => 'Export format. Can also be stored in config (which wins!)'
        }
    );

}

no Moose::Role;
1;

__END__

=head1 DESCRIPTION

Export your time as CSV.

=head1 CONFIGURATION

=head1 NEW COMMANDS

=head2 export

