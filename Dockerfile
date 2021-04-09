FROM gazebo as prebuilder

# Set ROS distribution
ARG DIST=noetic

# Non-persistent environment
ARG DEBIAN_FRONTEND=noninteractive

#Arguemnt to dockerfile
ARG ARG_TIMEZONE=America/Los_Angeles
#Make it persistent
ENV TZ ${ARG_TIMEZONE}

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
        lximage-qt \
        nautilus \
        python3-dbg \
        python3-pip \
        python3-venv \
        ruby \
        software-properties-common \
        sudo \
        tree \
        vim \
        wget \
        libeigen3-dev \
        pkg-config \
        protobuf-compiler \
        unzip \
 && apt-get clean

# Get ROS melodic and Gazebo 11
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
    ros-${DIST}-rosbash \
    ros-${DIST}-ros-tutorials \
    libignition-math6 \
 && rosdep init \
 && apt-get clean

RUN rosdep update


RUN cd /tmp && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
 unzip awscliv2.zip && \
 ./aws/install

COPY nps-workspace /usr/local/bin

RUN apt-get update && apt-get install --no-install-recommends -y \
        ca-certificates \
        libasound2 \
        libatk1.0-0 \
        libavcodec-extra58 \
        libavformat58 \
        libc6 \
        libcairo-gobject2 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libfontconfig1 \
        libgdk-pixbuf2.0-0 \
        libgstreamer-plugins-base1.0-0 \
        libgstreamer1.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libpam0g \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libpangoft2-1.0-0 \
        libpython2.7 \
        libpython3.6 \
        libpython3.7 \
        libselinux1 \
        libsm6 \
        libsndfile1 \
        libx11-6 \
        libx11-xcb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxft2 \
        libxi6 \
        libxinerama1 \
        libxrandr2 \
        libxrender1 \
        libxt6 \
        libxtst6 \
        libxxf86vm1 \
        locales \
        locales-all \
        procps \
        sudo \
        xkb-data \
        zlib1g \
        x11-xserver-utils \
    && apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

# Uncomment the following RUN apt-get statement if you will be using Simulink 
# code generation capabilities, or if you will be compiling your own mex files
# with gcc, g++, or gfortran.
#
RUN apt-get update && apt-get install --no-install-recommends -y gcc g++ gfortran

# Uncomment the following RUN apt-get statement to enable running a program
# that makes use of MATLAB's Engine API for C and Fortran
# https://www.mathworks.com/help/matlab/matlab_external/introducing-matlab-engine.html
#
RUN apt-get update && apt-get install --no-install-recommends -y csh

# Uncomment ALL of the following RUN apt-get statement to enable the playing of media files
# (mp3, mp4, etc.) from within MATLAB.
#
RUN apt-get update && apt-get install --no-install-recommends -y libgstreamer1.0-0 \
 gstreamer1.0-tools \
 gstreamer1.0-libav \
 gstreamer1.0-plugins-base \
 gstreamer1.0-plugins-good \
 gstreamer1.0-plugins-bad \
 gstreamer1.0-plugins-ugly

# Uncomment the following line if you require network tools
RUN apt-get update && apt-get install --no-install-recommends -y net-tools

# Uncomment the following RUN apt-get statement if you will be using the 32-bit tcc compiler
# used in the Polyspace product line.
RUN apt-get update && apt-get install -y libc6-i386

# To avoid inadvertently polluting the / directory, use root's home directory 
# while running MATLAB.
WORKDIR /root

#### Install MATLAB in a multi-build style ####
# Without this we get a 43.9 GiB image; with it, 29 GiB
FROM prebuilder as middle-stage

ADD R2021a_complete /matlab-install/

# Copy the file matlab-install/installer_input.txt into the same folder as the 
# Dockerfile. The edit this file to specify what you want to install. NOTE that 
# at a minimum you will need to have changed the following set of parameters in 
# the file.
#   fileInstallationKey
#   agreeToLicense=yes
#   Uncomment products you want to install
ADD matlab_installer_input.txt /matlab_installer_input.txt

# Now install MATLAB (make sure that the install script is executable)
# This step takes 16 minutes!!
RUN cd /matlab-install && \
    chmod +x ./install && \
    ./install -mode silent \
        -inputFile /matlab_installer_input.txt \
        -outputFile /tmp/mlinstall.log \
        -destinationFolder /usr/local/MATLAB \
    ; EXIT=$? && cat /tmp/mlinstall.log && test $EXIT -eq 0

#### Build final container image ####
FROM prebuilder

COPY --from=middle-stage /usr/local/MATLAB /usr/local/MATLAB

# Add a script to start MATLAB and soft link into /usr/local/bin
ADD startmatlab.sh /opt/startscript/
RUN chmod +x /opt/startscript/startmatlab.sh && \
    ln -s /usr/local/MATLAB/bin/matlab /usr/local/bin/matlab

# No license is enabled so we must run with "matlab -licmode online"
