FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -q && apt-get install --no-install-recommends -yq alien wget unzip clinfo \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download the Intel OpenCL 2.0 development headers
RUN export DEVEL_URL="https://software.intel.com/file/531197/download" \
    && wget ${DEVEL_URL} -q -O download.zip --no-check-certificate \
    && unzip download.zip \
    && rm -f download.zip *.tar.xz* \
    && alien --to-deb *dev*.rpm \
    && dpkg -i *dev*.deb \
    && rm *.rpm *.deb

# Download the Intel OpenCL CPU runtime and convert to .deb packages
RUN export RUNTIME_URL="http://registrationcenter-download.intel.com/akdlm/irc_nas/9019/opencl_runtime_16.1.1_x64_ubuntu_6.4.0.25.tgz" \
    && export TAR=$(basename ${RUNTIME_URL}) \
    && export DIR=$(basename ${RUNTIME_URL} .tgz) \
    && wget -q ${RUNTIME_URL} \
    && tar -xf ${TAR} \
    && for i in ${DIR}/rpm/*.rpm; do alien --to-deb $i; done \
    && rm -rf ${DIR} ${TAR} \
    && dpkg -i *.deb \
    && rm *.deb

RUN mkdir -p /etc/OpenCL/vendors/ \
    && echo "/opt/intel/opencl-1.2-6.4.0.25/lib64/libintelocl.so" > /etc/OpenCL/vendors/intel.icd

# Let the system know where to find the OpenCL library at runtime
ENV OCL_INC /opt/intel/opencl/include
ENV OCL_LIB /opt/intel/opencl-1.2-6.4.0.25/lib64
ENV LD_LIBRARY_PATH $OCL_LIB:$LD_LIBRARY_PATH

# -------------------------------------
# -------------------------------------
# -------------------------------------

COPY README.md /home


RUN apt-get update && \
    apt-get install -y vim && \
    apt-get install -y wget && \
    apt-get install -y p7zip-full


RUN mkdir /hashcat

RUN cd /hashcat && \
    wget --no-check-certificate https://hashcat.net/files/hashcat-4.0.1.7z && \
    7z x hashcat-4.0.1.7z && \
    rm hashcat-4.0.1.7z

RUN cd /hashcat && \
    wget --no-check-certificate https://github.com/hashcat/hashcat-utils/releases/download/v1.8/hashcat-utils-1.8.7z && \
    7z x hashcat-utils-1.8.7z && \
    rm hashcat-utils-1.8.7z

RUN ln -s /hashcat/hashcat-4.0.1/hashcat64.bin /usr/bin/hashcat
RUN ln -s /hashcat/hashcat-utils-1.8/bin/cap2hccapx.bin /usr/bin/cap2hccapx

# -------------------------------------
# -------------------------------------
# -------------------------------------

# passwords
RUN apt-get install -y git && \
    cd /home && \
    git clone https://github.com/szalek/get_passwords.git && \
    cd /home/get_passwords && \
    chmod +x get_passwords.sh && \
    ln -sf /home/get_passwords/get_passwords.sh /usr/local/bin/get_passwords
