use strict;
use warnings;

use Net::DBus;

use Irssi;
our($VERSION, %IRSSI, $plugin_can_change_status);

$VERSION = "0.1";
%IRSSI = (
  authors     => 'Arnaud Berthmier',
  contact     => 'oz@cyprio.net',
  name        => 'dbus_away.pl',
  description => 'Sets you away when your screensaver is activated.',
  license     => 'GPL v3',
  url         => 'https://github.com/oz/dbus_away'
);

# Wether the plugin can switch between away/online status.
$plugin_can_change_status = 0;

Irssi::settings_add_str('dbus_away', 'away_message', 'AFK');
Irssi::settings_add_int('dbus_away', 'poll_interval', 5);

# Set away on all servers with the received $reason, unless the user is already
# marked away on this server.
sub set_away {
  my ($reason) = @_;

  foreach my $server (Irssi::servers()) {
    if ( ! $server->{'usermode_away'} ) {
      $server->command("AWAY -one $reason");
      $plugin_can_change_status = 1;
    }
  }
}

# Set online on all servers.
sub set_online {
  $plugin_can_change_status = 0;
  foreach my $server (Irssi::servers()) {
    if ( $server->{'usermode_away'} ) {
      $server->command("AWAY -one");
    }
  }
}

# Callback triggered by Irssi::timeout_add, check screensaver state, and set
# away or online accordingly.
sub poll_screensaver_status {
  my ($screensaver) = @_;

  if ( $screensaver->GetActive() ) {
    set_away(Irssi::settings_get_str('away_message'));
  } else {
    set_online() if ( $plugin_can_change_status );
  }
}

# Net::DBus initialization stuff.
sub get_dbus_screensaver {
  my $bus = Net::DBus->session;
  return unless $bus;

  my $svc = $bus->get_service("org.gnome.ScreenSaver");
  return unless $svc;

  my $obj = $svc->get_object("/org/gnome/ScreenSaver", "org.gnome.ScreenSaver");
  return unless $obj;

  return $obj;
}

my $screensaver = get_dbus_screensaver();
if ( ! $screensaver ) {
  Irssi::print("dbus_away error: can't read screensaver status. Deactivating.");
} else {
  Irssi::timeout_add(1000 * Irssi::settings_get_int('poll_interval'),
                     'poll_screensaver_status', $screensaver);
}
