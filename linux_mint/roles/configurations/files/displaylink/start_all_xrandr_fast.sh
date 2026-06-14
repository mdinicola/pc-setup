#!/bin/sh

###
### enable that when only DisplayLink-connected monitors are present, lightdm-greeter displays something
###

###
### 1
###
### "run xrandr once", otherwise the following activation is not effective
###   -> this seems to nudge forward a combination of state that seems stuck,
###      unclear where to otherwise put this in boot sequence, below
###      analysis seems to indicate this is a sequencing problem with
###      lightdm starting Xorg not far enough that parallel-started
###      DisplayLinkManager would find it prepared for registering the
###      monitors attached to the DisplayLink hardware
###
###      -> evdi module is loaded during boot, adding 4 "unbound" evdi platform devices
###      -> lightdm.service (display-manager.service) starts, in turn starting Xorg server
###      -> .. Xorg starts, opening /dev/dri/cardX devices (the evdi devices)
###      -> displaylink-driver.service starts (After=display-manager.service)
###      ->
###      -> here, Xorg races with displaylink-driver.service, only when Xorg is done
###      ->   opening the cardX, with delaying DisplayLinkManager startup a second, will
###      ->   DisplayLinkManager DRM-"connect" [X] the monitors such that a "run xrandr once"
###      ->   is not needed -> we could add the delay in displaylink-driver.service,
###      ->                      but doing the "run xrandr once" here at least keeps the
###      ->                      hacks in one place
###      ->
###      -> [X]: DisplayLinkManager: - connects displaylink USB device
###      ->                          - finds connected monitors, reads edid
###      ->                          - registers monitors display pipe & EDID to the evdi DRM devices
###      ->                          - evdi device is now DRM-"connected" with monitor
###
sleep 1 # add 1s, not seen needed, but with the "run xrandr once" being needed, better add it...
xrandr 2>&1 | systemd-cat -t xrandr_once

###
### 2
###
### after "run xrandr once", the display pipes (DRM stuff plane->crtc->encoder->connector)
### are still "not started", no mode is set (choosen), the monitors are powered down,
### instead of the monitors being started with default mode, as Xorg would do for regular non DL hardware
###
### but at least at this point, we can start connected, but disabled ports with with "xrandr --auto" 
sleep 1
xrandr --auto 2>&1 | systemd-cat -t xrandr_once_auto

###
### 3
###
### profit,
### the xrandr calls registered/activated the monitors for Xorg output,
### subsequently started lightdm-greeter will show something


