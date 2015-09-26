#!/bin/bash

################################################################
#
# Usage: check-battery
#
# A tiny script to warn the user when the battery is
# low. It also puts the laptop to sleep when battery
# is critically low.
#
################################################################

status=$(cat /sys/class/power_supply/BAT1/status)
percent=$(cat /sys/class/power_supply/BAT1/capacity)
percent_low="99"
percent_crit="10"

nag(){
    for p in $(pgrep gconf-helper); do
        dbus=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$p/environ | sed 's/DBUS_SESSION_BUS_ADDRESS=//')
        user=$(grep -m 1 -z USER /proc/$p/environ | sed 's/USER=//')
        dply=$(grep -z DISPLAY /proc/$p/environ | sed 's/DISPLAY=//')
        sudo -u $user sh -c "DBUS_SESSION_BUS_ADDRESS=\"$dbus\" DISPLAY=\"$dply\" i3-nagbar $@"
    done
}

if [[ "$status" == "Charging" ]]; then
	if [[ -f /tmp/battery_warning ]]; then
		rm /tmp/battery_warning
	fi
	exit
fi

if [[ "$percent" -lt "$percent_crit" && "$status" == "Discharging" ]]; then
	systemctl suspend
fi

if [[ "$percent" -lt "$percent_low" ]]; then
	if [[ -f /tmp/battery_warning ]]; then
		exit
	fi
	touch /tmp/battery_warning
	nag -m 'Battery is almost empty!'
	# DISPLAY=:0.0 /usr/bin/notify-send "Battery is almost empty!"
else
	if [[ -f /tmp/battery_warning ]]; then
		rm /tmp/battery_warning
	fi
fi

