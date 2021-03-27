FROM gazebo

# Set ROS distribution
ARG DIST=noetic

# Set Gazebo verison
ARG GAZ=gazebo9

ENV DEBIAN_FRONTEND noninteractive

# Tools useful during development.
RUN apt-get update \
 && apt-get install -y --no-install-recommends\
        build-essential \
        cppcheck \
        curl \
        cmake \
        lsb-release \
        gdb \
        gedit \
        git \
        nautilus \
        python3-dbg \
        python3-pip \
        python3-venv \
        ruby \
        software-properties-common \
        sudo \
        vim \
        wget \
        libeigen3-dev \
        pkg-config \
        protobuf-compiler \
 && apt clean

RUN \
 apt-get update \
 && apt-get install -y --no-install-recommends\
    tzdata \
 && ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
 && dpkg-reconfigure --frontend noninteractive tzdata \
 && apt clean

# Get ROS melodic and Gazebo 9.
RUN /bin/sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
 && apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 \
 && apt-get update \
 && apt-get install -y  --no-install-recommends\
    python3-rosdep \
    qtbase5-dev \
    libgles2-mesa-dev \
    ros-${DIST}-desktop-full \
    ros-${DIST}-velodyne-gazebo-plugins \
    ros-${DIST}-effort-controllers \
    ros-${DIST}-rqt \
    ros-${DIST}-rqt-robot-plugins \
    ros-${DIST}-rqt-common-plugins \
    ros-${DIST}-joy \
    ros-${DIST}-teleop-twist-joy \
    ros-${DIST}-teleop-twist-keyboard \
    ros-${DIST}-teleop-tools \
    ros-${DIST}-joy-teleop \
    ros-${DIST}-key-teleop \
    ros-${DIST}-geographic-info \
    ros-${DIST}-move-base \
    ros-${DIST}-robot-localization \
    ros-${DIST}-robot-state-publisher \
    ros-${DIST}-xacro \
    libignition-math6 \
 && rosdep init \
 && apt clean

RUN rosdep update

RUN apt-get update \
 && apt-get install -y --no-install-recommends\
    unzip \
 && ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
 && dpkg-reconfigure --frontend noninteractive tzdata \
 && apt clean

RUN cd /tmp && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
 unzip awscliv2.zip && \
 ./aws/install

COPY nps-workspace /usr/local/bin