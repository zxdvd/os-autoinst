use base "basetest";
use bmwqemu;

sub is_applicable()
{
	return 0;
}

sub run()
{
	my $self=shift;
	script_run("cd /tmp ; wget -q openqa.opensuse.org/opensuse/tools/recentchanges2.pl");
	script_run("rpm -qa | perl recentchanges2.pl > /dev/ttyS0");
	script_run("echo 'recentchanges_ok' >  /dev/ttyS0");
	waitserial('recentchanges_ok', 200);
}

1;
