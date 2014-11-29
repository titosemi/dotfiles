#!/bin/bash
killall -9 gpg-agent; gpg --card-status; gpg-agent --daemon
