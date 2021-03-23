| **Package** | **Version** |
|:-------:|:-------:|
|   gcc   |    9    |
|   g++   |    9    |
|  CMake  |  3.19.5 |
|  Ubuntu |  16.04  |
|   ROS   | Kinetic |

## How to Use
- Create a directory called src
- Clone miso-robot-driver-stack in src
- run `vcstool import < miso-robot-driver-stack/dependencies.rosinstall`
- run `make build`
- after successful build of the container, run `make up` to work in the container bash shell
