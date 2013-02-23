use strict;
use warnings;

use Net::DBus;

use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "0.1";
%IRSSI = (
  authors     => 'Arnaud Berthmier',
  contact     => 'oz@cyprio.net',
  name        => 'dbus_away.pl',
  description => 'Sets you away when your screensaver is activated.',
  license     => 'GPL v3',
  url         => 'https://github.com/oz/dbus_away'
);

Irssi::settings_add_str('dbus_away', 'away_message', 'AFK');
Irssi::settings_add_int('dbus_away', 'poll_interval', 5);

# Set away on all servers with the received $reason, unless the user is already
# marked away on this server.
sub set_away {
  my ($reason) = @_;

  foreach my $server (Irssi::servers()) {
    if ( ! $server->{usermode_away} ) {
      $server->command("AWAY -one $reason");
      Irssi::print("set away on " . $server->{'chatnet'});
    }
  }
}

# Set online on all servers.
sub set_online {
  foreach my $server (Irssi::servers()) {
    if ( $server->{usermode_away} ) {
      $server->command("AWAY -one");
      Irssi::print("set online on " . $server->{'chatnet'});
    }
  }
}

# Poll DBus to get screensaver status.
sub get_screensaver_status {
  my ($screensaver) = @_;

  return $screensaver->GetActive();
}

# Callback triggered by Irssi::timeout_add, check screensaver state, and set
# away or online accordingly.
sub poll_screensaver_status {
  my ($screensaver) = @_;
  my $active = get_screensaver_status($screensaver);

  if ( $active ) {
    set_away(Irssi::settings_get_str('away_message'));
  } else {
    set_online();
  }
}

# Net::DBus initialization stuff.
sub initialize_screensaver {
  my $bus = Net::DBus->session;
  return unless $bus;

  my $svc = $bus->get_service("org.gnome.ScreenSaver");
  return unless $svc;

  my $obj = $svc->get_object("/org/gnome/ScreenSaver", "org.gnome.ScreenSaver");
  return unless $obj;

  return $obj;
}

my $screensaver = initialize_screensaver();
if (!$screensaver) {
  Irssi::print("dbus_away error: can't read screensaver status. Deactivating.");
} else {
  Irssi::timeout_add(1000 * Irssi::settings_get_int('poll_interval'),
                     'poll_screensaver_status', $screensaver);
}
