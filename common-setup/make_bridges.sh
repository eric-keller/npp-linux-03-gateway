#!/bin/bash

sudo ip link add br-int type bridge
sudo ip link set dev br-int up
sudo ip link add br-ext type bridge
sudo ip link set dev br-ext up
