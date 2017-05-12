#! /bin/sh

BLUEZCARD=$(pactl list cards short | egrep -o 'bluez.*[[:space:]]')
pactl set-card-profile $BLUEZCARD a2dp_sink
pactl set-card-profile $BLUEZCARD off
pactl set-card-profile $BLUEZCARD a2dp_sink
