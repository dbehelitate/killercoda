#!/bin/bash
while [ ! -f /tmp/banner.txt ]; do sleep 0.1; done; clear; echo -e "\e[1;32m"; cat /tmp/banner.txt; echo -e "\n⚡ Ambiente pronto. Premi Invio per iniziare.\e[0m\n"
