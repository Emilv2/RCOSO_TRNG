#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color

string_length=${#1}

nb_symbols_front=$(( ($(tput cols) - ($string_length))/ 2 ))
nb_symbols_back=$(( $(tput cols) - $string_length - $nb_symbols_front ))

symbols_front=$(printf %"$nb_symbols_front"s |tr " " "#")
symbols_back=$(printf %"$nb_symbols_back"s |tr " " "#")
echo -e ${RED}$symbols_front$1$symbols_back${NC}
