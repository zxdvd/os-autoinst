#!/usr/bin/perl -w
use strict;
use base "installstep";
use bmwqemu;

sub is_applicable()
{
  	my $self=shift;
	return $self->SUPER::is_applicable && !$ENV{LIVECD} && $ENV{ADDONURL};
}

sub run()
{
	my $self=shift;
	if($ENV{VIDEOMODE} && $ENV{VIDEOMODE} eq "text") {$cmd{xnext}="alt-x"}
	if(!$ENV{NET} && !$ENV{DUD}) {
		waitstillimage();
		sleep 5; # try
		sendkey $cmd{"next"}; # use network
		waitstillimage(20);
		sendkeyw "alt-o"; # OK DHCP network
	}
	my $repo=0;
	$repo++ if $ENV{DUD};
	foreach my $url (split(/\+/, $ENV{ADDONURL})) {
		if($repo++) {sendkeyw "alt-a"; } # Add another
		sendkeyw $cmd{"xnext"}; # Specify URL (default)
		sendautotype($url);
		sendkeyw $cmd{"next"};
		if($ENV{ADDONURL}!~m{/update/}) { # update is already trusted, so would trigger "delete"
			sendkey "alt-i";sendkeyw "alt-t"; # confirm import (trust) key
		}
	}
	$self->check_screen;
	sendkeyw $cmd{"next"}; # done
}

1;
