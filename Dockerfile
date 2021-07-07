FROM ros:kinetic-ros-core-xenial
SHELL ["/bin/bash","-c"] 

ENV ROS_DISTRO kinetic
ENV LIBMODBUS libmodbus_3.1.6-1_amd64.deb
ENV CATKIN_WS=/root/catkin_ws

# Setup Locales
RUN apt-get update && apt-get install -y locales
ENV LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8" LANGUAGE="en_US.UTF-8"


RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen --purge $LANG && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG LC_ALL=$LC_ALL LANGUAGE=$LANGUAGE

# Set up timezone
ENV TZ 'America/Los_Angeles'
RUN echo $TZ > /etc/timezone && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Install basic dev and utility tools
RUN apt-get update && apt-get install -y \
    apt-utils \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    git \
    lsb-release \
    wget 

# Update to GCC 9
RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get install -y gcc-9 g++-9

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9 && \
    sudo update-alternatives --config gcc

# Obtain a copy of our signing key:
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
    | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null

# Update CMake version
RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ xenial main'
RUN apt-get update
RUN apt-get install -y cmake

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    python-rosdep 

# Install basic dev and utility tools
RUN apt-get update && apt-get install -y \
    stow \
    nano \
    unzip \
    ros-kinetic-catkin \
    ros-kinetic-roslint \
    ros-kinetic-uuid-msgs \
    ros-kinetic-controller-manager \
    ros-kinetic-joint-limits-interface \
    ros-kinetic-actionlib \
    ros-kinetic-control-msgs \
    ros-kinetic-combined-robot-hw \
    ros-kinetic-realtime-tools 

RUN apt-get dist-upgrade -y

# create catkin directories
RUN mkdir -p ${CATKIN_WS}
WORKDIR ${CATKIN_WS}

COPY . .

RUN rosdep init
RUN rosdep update

WORKDIR ${CATKIN_WS}

RUN mkdir devel 
RUN mkdir build

RUN source /opt/ros/${ROS_DISTRO}/setup.bash

# Install dependencies
RUN rosdep install --from-paths src --ignore-src -r -y 

# install updated libmodbus
COPY ./${LIBMODBUS} /
RUN dpkg -i /${LIBMODBUS}

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9 && \
    sudo update-alternatives --config gcc

# Build catkin workspace
RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash && \
    cd ${CATKIN_WS} && \
    catkin_make -j8"

# RUN echo "source ${CATKIN_WS}/devel/setup.bash" >> ~/.bashrc
