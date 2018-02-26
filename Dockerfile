FROM youyu/orb_slam2:latest

RUN apt-get update && apt-get install -y mesa-utils libgl1-mesa-swx11 && apt-get install -y libglew-dev

RUN apt-get update && apt-get install -y libgd3 libgvc6
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
RUN apt-get update
RUN apt-get install -y ros-kinetic-desktop-full
RUN rosdep init
RUN rosdep update
RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
RUN apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential

# RUN apt-get install -y libboost-system-dev

# ENV ROS_PACKAGE_PATH ${ROS_PACKAGE_PATH}:/opt/ORB_SLAM2/Examples/ROS/
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu/

RUN echo 'export ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH}:/opt/ORB_SLAM2/Examples/ROS/' >> ~/.bashrc

RUN sed -i -e "s/^set(LIBS$/set(LIBS -lboost_system/" /opt/ORB_SLAM2/Examples/ROS/ORB_SLAM2/CMakeLists.txt
RUN cd /opt/ORB_SLAM2/ && sh build.sh
RUN sed -i -e "s/^make -j$/make -j -k/" /opt/ORB_SLAM2/build_ros.sh
# RUN bash -c 'source /opt/ros/kinetic/setup.bash && export ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH}:/opt/ORB_SLAM2/Examples/ROS/ && cd /opt/ORB_SLAM2/ && sh build_ros.sh'

RUN cd /opt/ORB_SLAM2/Examples && rosws init . /opt/ros/kinetic && yes | rosws set /opt/ORB_SLAM2/Examples/ROS -t .
RUN echo "source /opt/ORB_SLAM2/Examples/setup.bash" >> ~/.bashrc
RUN bash -c ' \
    source /opt/ros/kinetic/setup.bash && \
    export ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH}:/opt/ORB_SLAM2/Examples/ROS/ && \
    cd /opt/ORB_SLAM2/Examples/ROS && rosmake ORB_SLAM2 \
    '

RUN mkdir -p /catkin_ws/src && cd /catkin_ws/src/ && git clone https://github.com/ros-drivers/video_stream_opencv.git
RUN bash -c ' \
    source /opt/ros/kinetic/setup.bash && \
    export ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH}:/opt/ORB_SLAM2/Examples/ROS/ && \
    cd /catkin_ws/src/video_stream_opencv && \
    rosdep update && \
    rosdep install --from-path /catkin_ws/src/video_stream_opencv --ignore-src \
    '
RUN cd /catkin_ws && catkin_make_isolated
RUN echo "source /catkin_ws/devel_isolated/setup.bash" >> ~/.bashrc

# RUN apt-get install -y mlocate && updatedb
