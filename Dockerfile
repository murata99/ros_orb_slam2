FROM youyu/orb_slam2:latest

RUN apt-get update && apt-get install -y libgd3 libgvc6
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
RUN apt-get update
RUN apt-get install -y ros-kinetic-desktop-full
RUN rosdep init
RUN rosdep update
RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
RUN apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential

RUN apt-get install -y mesa-utils libgl1-mesa-swx11

RUN sed -i -e "s/^set(LIBS$/set(LIBS -lboost_system/" /opt/ORB_SLAM2/Examples/ROS/ORB_SLAM2/CMakeLists.txt
RUN cd /opt/ORB_SLAM2/ && sh build.sh
RUN LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu/ && \
    ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH}:/opt/ORB_SLAM2/Examples/ROS/ && \
    /bin/bash -c "cd /opt/ORB_SLAM2/ && build_ros.sh; build_ros.sh; build_ros.sh"

