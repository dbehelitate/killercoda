#!/bin/bash
while [ ! -f /tmp/banner.txt ]; do sleep 0.1; done; clear; echo -e "\e[1;32m"; cat /tmp/banner.txt; echo -e "\n⚡Env Ready⚡\e[0m\n"
