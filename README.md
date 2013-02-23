DBus Away
=========

A simple Irssi script that sets your IRC status away when your computer's
screensaver is activated (and resets that once your back).

This could be prettier if Irssi would let me use `Net::DBus::Reactor` to attach
code to DBus events. Instead of that, I'm polling every N seconds. That's what
you get for using a modern IRC client, and a modern chat protocol. :)

Requirements
============

  * Irssi compiled with perl support,
  * Perl's Net::DBus, and an active DBUS session,
  * GNOME's screensaver.

Don't worry, you should be able to get all of it from ports, or APT, or... Be
smart.

Installation
============

Grab the source:

```
curl https://raw.github.com/oz/dbus_away/master/dbus_away.pl > ~/.irssi/scripts/dbus_away.pl
```

Optionally, symlink it into irssi's `autorun` directory if you want the script
automatically loaded  when irssi starts:

```
cd ~/.irssi/scripts/autorun
ln -s ../dbus_away.pl
```

Load the script, from irssi:

```
/script load dbus_away.pl
```

Configuration
=============

Only two settings are configurable:

  * `poll_interval` sets how often we poll DBus (in seconds). Defaults to 5.
  * `away_message` changes the default away message, which is "AFK".

Author and License
==================

This script is licensed under the GPL v3.

Blame:

  * Arnaud Berthomier - I did Perl a long time ago when you were not born.
    Now, it's quite rusty. Sorry. :)
