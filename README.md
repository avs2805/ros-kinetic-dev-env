## Package Details
| **Package** | **Version** |
|:-------:|:-------:|
|   gcc   |    9    |
|   g++   |    9    |
|  CMake  |  3.19.5 |
|  Ubuntu |  16.04  |
|   ROS   | Kinetic |

## How to Use
- Download Dockerfile,Makefile,ros_entrypoint.sh and .gitignore from this repository in a directory (preferrably miso_ws to be easily identifiable ROS workspace)
- Create a directory called src inside the workspace (miso_ws/src). (.gitignore has this added so it wont start tracking src!)
- cd src
- Clone miso-robot-driver-stack in src
- run `vcstool import < miso-robot-driver-stack/dependencies.rosinstall`
- run `make build`
- after successful build of the container, run `make up` to work in the container bash shell
