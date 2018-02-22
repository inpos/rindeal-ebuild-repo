#!/bin/bash

cat "$( dirname "${BASH_SOURCE[0]}" )"/repoman | "$( dirname "${BASH_SOURCE[0]}" )"/repoman_format.py
