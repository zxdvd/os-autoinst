#!/usr/bin/perl -w

package backend::vnc;
use strict;
use Cwd 'abs_path';
use Time::HiRes qw(sleep gettimeofday);
use Net::VNC;

#use FindBin;
#use lib "$FindBin::Bin/backend";
#use lib "$FindBin::Bin/backend/helper";
#use lib "$FindBin::Bin/helper";
use base ('backend::helper::scancodes', 'backend::baseclass');

our $scriptdir = $bmwqemu::scriptdir || '.';

sub init() {
	my $self = shift;
	$self->{'pid'} = undef;
	$self->backend::helper::scancodes::init();
}

sub sendkey($) {
    my $self = shift;
    my $keys = shift;
    my $keycode;

    sleep 0.2;
    foreach my $key (split ("-", $keys)) {
        $keycode = $key;
        if (length($key) > 1) {
            bmwqemu::diag "sendkey-keydown".$key;
            $keycode = $self->{ 'keymaps' }->{'vnc'}->{$key};
        } else {
            $keycode = ord($keycode);
        }
        $self->{vnc}->send_key_event_down($keycode);
    }
    foreach my $key (split ("-", $keys)) {
        $keycode = $key;
        if (length($key) > 1) {
            $keycode = $self->{ 'keymaps' }->{'vnc'}->{$key};
        } else {
            $keycode = ord($keycode);
        }
        $self->{vnc}->send_key_event_up($keycode);
    }
}

sub mouse_set($$) {
    my $self = shift;
    my ($x, $y) = @_;
    $self->{vnc}->mouse_move_to($x, $y);
}

sub mouse_hide(;$) {
	my $self = shift;
	my $border_offset = shift || 0;
	unless($border_offset) {
        $self->{vnc}->mouse_move_to(1024, 768);
	}
	else {
		# not completely in the corner to not trigger hover actions
        $self->{vnc}->mouse_move_to(1010, 720);
	}
}

sub screendump() {
	my $self = shift;
	my ($seconds, $microseconds) = gettimeofday;
	my $tmp = "ppm.$seconds.$microseconds.png";
	$self->{screen}->capture()->save($tmp);
    wait_for_img($tmp);
    my $img = tinycv::read($tmp);
	unlink $tmp;
	return $img;
}

sub wait_for_img($)
{
       my $tmp = shift;

       my $ret;
       while (!defined $ret) {
         sleep(0.1);
         my $fs = -s $tmp;
         # if qemu did not even start writing out
         # after 0.1s, it's most likely dead. In case
         # this is not true on slow machines, we may
         # need to scale this - because sleeping longer
         # doesn't make sense
         return unless ($fs);
         next if ($fs < 70);
         my $header;
         next if (!open(PPM, $tmp));
         if (read(PPM, $header, 70) < 70) {
           close(PPM);
           next;
         }
#         close(PPM);
#         my ($xres,$yres) = ($header=~m/\AP6\n(?:#.*\n)?(\d+) (\d+)\n255\n/);
#         next if(!$xres);
#         my $d=$xres*$yres*3+length($&);
#         next if ($fs != $d);
	 return;
      }

}

sub raw_alive($) {
	my $self = shift;
	return 0 unless $self->{'pid'};
	#return kill(0, $self->{'pid'});
    return 1;
}

sub do_start_vm {
    my $self = shift;

    $ENV{VNCHOST}||="localhost:5990";
    $ENV{VNCPASSWD}||="";
    bmwqemu::diag("begin start vnc backend");
# open two vnc connect, the "screen" is used by screendump to get screenshot    
# the "vnc" is used to send keys or mouse move
    for my $i (qw/screen vnc/) {
    my $vnc = Net::VNC->new({hostname => $ENV{VNCHOST}, password => $ENV{VNCPASSWD}});
    $vnc->login;
    bmwqemu::diag $vnc->name.":  ".$vnc->width."x".$vnc->height."\n";
    $self->{$i} = $vnc;
    }
    $self->{'pid'} = 3000;
    sleep 3;
}

sub do_stop_vm($) {
    my $self = shift;
    $self->{vnc} = undef;
    $self->{screen} = undef;
    printf STDERR "drop VNC connect, will auto disconnect after 15s\n";
}

sub do_loadvm($) {

}

1;
