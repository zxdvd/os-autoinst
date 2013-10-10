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

sub screendump() {
	my $self = shift;
	my ($seconds, $microseconds) = gettimeofday;
	my $tmp = "ppm.$seconds.$microseconds.png";
	$self->{vnc}->capture()->save($tmp);
    my $img = tinycv::read($tmp);
	unlink $tmp;
	return $img;
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
    my $vnc = Net::VNC->new({hostname => $ENV{VNCHOST}, password => $ENV{VNCPASSWD}});
    $vnc->login;
    bmwqemu::diag $vnc->name.":  ".$vnc->width."x".$vnc->height."\n";
    $self->{vnc} = $vnc;
    $self->{'pid'} = 3000;
    $vnc->capture()->save("vnc.png");
    sleep 3;
}

sub do_stop_vm($) {
    my $self = shift;
    $self->{vnc} = undef;
    printf STDERR "drop VNC connect, will auto disconnect after 15s\n";
}

1;
