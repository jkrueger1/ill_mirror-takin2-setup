#!/bin/bash
#
# takin focal build script
# @author Tobias Weber <tweber@ill.fr>
# @date sep-2020
# @license GPLv2
#

# individual building steps
setup_externals=1
setup_externals2=1
build_takin=1
build_takin2=1
build_package=1


NUM_CORES=$(nproc)


# get root dir of takin repos
TAKIN_ROOT=$(dirname $0)/../..
cd "${TAKIN_ROOT}"
TAKIN_ROOT=$(pwd)
echo -e "Takin root dir: ${TAKIN_ROOT}"


if [ $setup_externals -ne 0 ]; then
	echo -e "\n================================================================================"
	echo -e "Getting external dependencies (1/2)..."
	echo -e "================================================================================\n"

	pushd "${TAKIN_ROOT}/core"
		rm -rf tmp
		./setup/setup_externals.sh
	popd
fi


if [ $setup_externals2 -ne 0 ]; then
	echo -e "\n================================================================================"
	echo -e "Getting external dependencies (2/2)..."
	echo -e "================================================================================\n"

	pushd "${TAKIN_ROOT}/mag-core"
		rm -rf ext
		./setup/setup_externals.sh
	popd
fi


if [ $build_takin -ne 0 ]; then
	echo -e "\n================================================================================"
	echo -e "Building main Takin binary..."
	echo -e "================================================================================\n"

	pushd "${TAKIN_ROOT}/core"
		rm -rf build
		mkdir -p build
		cd build
		cmake -DDEBUG=False ..
		make -j${NUM_CORES}
	popd
fi


if [ $build_takin2 -ne 0 ]; then
	echo -e "\n================================================================================"
	echo -e "Building Takin 2 tools..."
	echo -e "================================================================================\n"

	pushd "${TAKIN_ROOT}/mag-core"
		rm -rf build
		mkdir -p build
		cd build
		cmake -DCMAKE_BUILD_TYPE=Release -DONLY_BUILD_FINISHED=True ..
		make -j${NUM_CORES}


		# copy tools to Takin main dir
		cp -v tools/cif2xml/cif2xml core/bin/
		cp -v tools/cif2xml/findsg core/bin/
		cp -v tools/pol/pol core/bin/
	popd
fi


if [ $build_package -ne 0 ]; then
	echo -e "\n================================================================================"
	echo -e "Building Takin package..."
	echo -e "================================================================================\n"

	pushd "${TAKIN_ROOT}"
		rm -rf tmp
		cd core
		./setup_lin/mkdeb_focal.sh "${TAKIN_ROOT}/tmp/takin"
	popd


	if [ -e  "${TAKIN_ROOT}/tmp/takin.deb" ]; then
		echo -e "\n================================================================================"
		echo -e "The built Takin package can be found here:\n\t${TAKIN_ROOT}/tmp/takin.deb"
		echo -e "================================================================================\n"
	else
		echo -e "\n================================================================================"
		echo -e "Error: Takin package could not be built!"
		echo -e "================================================================================\n"	
	fi
fi
