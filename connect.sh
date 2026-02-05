#!/bin/bash
# qssh Demo Client
# Connects using Falcon-512 user key to SPHINCS+ server
#
# Prerequisites: cargo install qssh

qssh -p 4242 --verbose $USER@localhost
