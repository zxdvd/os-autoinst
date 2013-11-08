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
	return $ENV{DESKTOP} eq "gnome" && !$ENV{LIVECD};
} 


# this part contains the steps to run this test
sub run()
{
	my $self=shift;

        x11_start_program("gnome-terminal");       # Open a terminal
        sendautotype("xdg-su -c 'zypper ref'\n");  # Refresh the repository.
        if ($password){                            # Send password to popup window  
              sendpassword;
               sendkeyw "ret";  
        }
        
        # Waiting the zypper ref time
        sleep 150;                                
        sendkey "ret";
        sleep 50;

        # Close Terminal 
        sendkey "alt-f4";
        sleep 3;
        sendkey "ret";
        sleep 3;
 
        # Open terminal         
        x11_start_program("gnome-terminal");             
        sleep 6;

        # Run the banshee installation via zypper
        sendautotype("xdg-su -c 'zypper in banshee'\n");  
        sleep 3;
        if ($password){
               sendpassword;
               sendkeyw "ret";  
        }
   
        sleep 3; 
        sendkey "y";            
        sendkey "ret"; sleep 3;

        # Waiting the zypper in banshee time 
        for (0..2) {
           sleep 60;
        }
        sendkey "ret";
        sleep 150;
        sendkey "ret";

        # Close the terminal
        sendkey "alt-f4";
        sendkey "ret";

        # Launch banshee
	x11_start_program("banshee");  
	sleep 10;
        $self->check_screen;

        sleep 3;
        sendkey "ctrl-q"; # really quit (alt-f4 just backgrounds)
	waitidle;
}

1;


