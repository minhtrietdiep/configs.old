#!/bin/bash
# a tiny script to warn the user when battery is low
# also puts the laptop to sleep when battery is crit

status=$(cat /sys/class/power_supply/BAT1/status)
percent=$(cat /sys/class/power_supply/BAT1/capacity)
percent_low="12"
percent_crit="7"

if [[ "$percent" -lt "$percent_crit" && "$status" == "Discharging" ]]; then
        /usr/sbin/pm-suspend
fi

if [[ "$status" == "Charging" ]]; then
	if [[ -f /tmp/battery_warning ]]; then
		rm /tmp/battery_warning
		exit
	fi
fi

if [[ "$percent" -lt "$percent_low" ]]; then
	if [[ -f /tmp/battery_warning ]]; then
		exit
	fi
	touch /tmp/battery_warning
	DISPLAY=:0.0 /usr/bin/i3-nagbar -m 'Battery is almost empty!'
else
	if [[ -f /tmp/battery_warning ]]; then
		rm /tmp/battery_warning
	fi
fi

