#!/usr/bin/perl -w

############################################################################
# Written by:     Ben Chou <bchou@suse.com>
# Case:           Initial case
# Description:    Use zypper to install banshee and then launch banshee.  
# This case is available when installing the banshee from default SUSE instllation.
############################################################################

use base "basetest";
use bmwqemu;

sub is_applicable()
{
	return $ENV{DESKTOP} eq "gnome";
} 


# this part contains the steps to run this test
sub run()
{
	my $self=shift;

        x11_start_program("gnome-terminal");       # Open a terminal
        sendautotype("su\n"); sleep 2;
        if ($password){                            # Send password to popup window  
              sendpassword;
               sendkeyw "ret";  
        }
        
        sendautotype("zypper -n in --no-rec banshee ; echo banshee finished > /dev/ttyS0\n");
        sleep 5;
        for(1..60) {
            my $tmp=waitserial("banshee finished", 30);        #wait 900s for the installation
            sendkey "ret"; sleep 1;
            next unless $tmp==1;
        }

    sendkey "alt-f4"; sleep 1;              #close the gnome-terminal
    sendkey "ret"; sleep 1;                 #confirm the close

        # Launch banshee
	x11_start_program("banshee");  
	sleep 10;
        $self->check_screen;

        sleep 3;
        sendkey "ctrl-q"; # really quit (alt-f4 just backgrounds)
	waitidle;
}

1;


