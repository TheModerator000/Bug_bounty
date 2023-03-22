#!/bin/bash
nmap $1
dirsearch -u $1 -e php
