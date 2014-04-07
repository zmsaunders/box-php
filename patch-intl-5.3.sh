#! /usr/bin/env sh

sed -i '/EXTRA_LIBS = /s|$| -lstdc++|' Makefile

