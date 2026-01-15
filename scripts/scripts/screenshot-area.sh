#!/bin/bash
mkdir -p ~/Pictures
slurp | grim -g - ~/Pictures/$(date "+%Y-%m-%d_%H-%M-%S").png
