#!/bin/bash

set -e
source /opt/ros/kinetic/setup.bash
source /root/catkin_ws/devel/setup.bash

exec "$@"