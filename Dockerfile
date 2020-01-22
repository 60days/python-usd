# This docker container serves as a base with a compiled version
# of Pixar USD toolchain. This is a separate container as the USD
# tools take several hours to build and are not updated very frequently.
# PLATTAR uses this base for other open source projects such as the
# xrutils toolchain.
# For more info on USD tools, visit https://github.com/PixarAnimationStudios/USD
FROM python:2.7.16-slim-buster

# our binary versions where applicable
ENV USD_VERSION="20.02-rc1"

# Update the environment path
ENV USD_BUILD_PATH="/usr/src/app/xrutils/usd"
ENV USD_INSTALL_PATH="${USD_BUILD_PATH}/bin"
ENV PATH="${PATH}:${USD_INSTALL_PATH}"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${USD_BUILD_PATH}/lib"
ENV PYTHONPATH="${PYTHONPATH}:${USD_BUILD_PATH}/lib/python"

WORKDIR /usr/src/app

# Required for compiling the USD source
RUN apt-get update && apt-get install -y --no-install-recommends \
	git \
	build-essential \
	cmake \
	nasm \
	libglew-dev \
	libxrandr-dev \
	libxcursor-dev \
	libxinerama-dev \
	libxi-dev \
	zlib1g-dev \ 
	wget && \
	rm -rf /var/lib/apt/lists/*

# Clone, setup and compile the Pixar USD Converter. This is required
# for converting GLTF2->USDZ
# More info @ https://github.com/PixarAnimationStudios/USD
RUN mkdir xrutils && \
	git clone https://github.com/PixarAnimationStudios/USD usdsrc && \
	cd usdsrc && git checkout tags/v${USD_VERSION} && cd ../ && \
	python usdsrc/build_scripts/build_usd.py -v --no-usdview ${USD_BUILD_PATH} && \
	rm -rf usdsrc