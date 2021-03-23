FROM ros:kinetic-ros-core-xenial
SHELL ["/bin/bash","-c"] 

ENV ROS_DISTRO kinetic

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
  build-essential \
  python-rosdep \
  && rm -rf /var/lib/apt/lists/*

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
  git \
  lsb-release \
  build-essential \
  stow \
  nano \
  tmux \
  wget \
  htop \
  unzip \
  apt-transport-https \
  ca-certificates \
  gnupg \
  software-properties-common \
  && rm -rf /var/lib/apt/lists/*


RUN apt-get dist-upgrade -y

# Obtain a copy of our signing key:
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
  | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null

# Add the repository to your sources list and update
RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ xenial main'
RUN apt-get update

# Install CMake
RUN apt-get install -y cmake


RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
  && apt update \
  && apt install -y gcc-9 g++-9
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9 && \
  sudo update-alternatives --config gcc

# RUN select gcc-9

# RUN apt install software-properties-common
# create catkin directories
ENV CATKIN_WS=/root/catkin_ws
RUN mkdir -p ${CATKIN_WS}
WORKDIR ${CATKIN_WS}

COPY . .

RUN rosdep init
RUN rosdep update

WORKDIR ${CATKIN_WS}

RUN source /opt/ros/${ROS_DISTRO}/setup.bash
# Install dependencies
# RUN rosdep update 
RUN rosdep install --from-paths ${CATKIN_WS}/src/ --ignore-src -r -y 
#  --rosdistro ${ROS_DISTRO}

RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
  # Build catkin workspace
  && catkin_make -j8
RUN echo "source /root/catkin_ws/devel/setup.bash" >> ~/.bashrc

COPY ./ros-entrypoint.sh /
RUN chmod +x /ros-entrypoint.sh
ENTRYPOINT ["/ros-entrypoint.sh"]
