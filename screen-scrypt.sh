#!/bin/bash
screen -dmS main bash /var/web/main.sh
screen -dmS loop2 bash /var/web/loop2.sh
screen -dmS blocks bash /var/web/blocks.sh
screen -dmS debug tail -f /var/log/debug.log
