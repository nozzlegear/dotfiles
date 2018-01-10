#!/bin/bash

# This will attempt to fix the resolution and dpi differences when using the surface book with a lower resolution external display.
# The formula is as follows:
# xrandr --output SURFACE_ID --auto --output MONITOR_ID --auto --panning [C*E]x[D*F]+[A]+0 --scale [E]x[F] --right-of SURFACE_ID
# where
# A=Surface resolution width (3000)
# B=Surface resolution height (2000)
# C=Monitor resolution width (1920)
# D=Monitor resolution height (1080)
# E=Width scaling (2) (higher the number, more zoomed out the low DPI monitor becomes)
# F=Height scaling (2)

xrandr --output eDP1 --auto --output DP1-1 --auto --panning 3840x2160+3000+0 --scale 2x2 --right-of eDP1

echo
echo "WARNING: You may also need to tell Xorg which device driver to use, or else the cursor may flicker and disappear on the Surface."
echo "https://wiki.archlinux.org/index.php/intel_graphics#Xorg_configuration"
echo
