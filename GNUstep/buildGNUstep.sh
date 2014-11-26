echo "************************************"
echo "*** Objective C for Raspberry Pi ***"
echo "***     Easy install script      ***"
echo "*** (c) 2014 by Jacek Wisniowski ***"
echo "***         MIT License          ***"
echo "************************************"
echo ""
echo "************************************"
echo "***        Compiler info:        ***"
export CC=clang  
export CXX=clang++
source ~/.bashrc
clang -v
clang++ -v
echo "* should be clang  version 3.0-6.2 *"
echo "*             or above             *"
echo "************************************"
echo ""
sudo apt-get install build-essential clang git subversion ninja cmake libffi-dev libxml2-dev libgnutls-dev libicu-dev libblocksruntime-dev libkqueue-dev libpthread-workqueue-dev autoconf libtool libjpeg-dev libtiff-dev libpng12-dev libcups2-dev libfreetype6-dev libcairo2-dev libxt-dev libgl1-mesa-dev
# is libdispatch already cloned?
if [ ! -d libdispatch ];
then
	echo "************************************"
	echo "***     Cloning libdispatch      ***"
	echo "***     by Nick  Hutchinson      ***"
	echo "************************************"
	git clone git://github.com/nickhutchinson/libdispatch.git
	if [ "$?" = "0" ];
	then
		echo "OK"
	else

		echo "Error: Could not clone libdispatch by Nick Hutchinson!" 1>&2
		exit 1
	fi
fi

# is gnustep checked out?
if [ ! -d core ];
then
	echo "************************************"
	echo "***  Checking out  gnustep core  ***"
	echo "************************************"
	svn co http://svn.gna.org/svn/gnustep/modules/core
	if [ "$?" = "0" ];
	then
		echo "OK"
	else

		echo "Error: Could not checkout gnustep core!" 1>&2
		exit 1
	fi
fi

# is libobjc2 checked out?
if [ ! -d libobjc2 ];
then
	echo "************************************"
	echo "***     Checking out libobjc2    ***"
	echo "************************************"
	svn co http://svn.gna.org/svn/gnustep/libs/libobjc2/trunk libobjc2
	if [ "$?" = "0" ];
	then
		echo "OK"
	else

		echo "Error: Could not checkout libobjc2!" 1>&2
		exit 1
	fi
fi

echo "************************************"
echo "***    Building GNUstep make    ***"
echo "************************************"
cd core/make/
./configure --enable-objc-nonfragile-abi
if [ ! "$?" = "0" ];
then
	echo "Error: could not configure GNUstep base!" 1>&2
	exit 1
fi
sudo make install
if [ ! "$?" = "0" ];
then
	echo "Error: could not install GNUstep make!" 1>&2
	exit 1
fi

cd ../..

export CC=clang
echo "************************************"
echo "***      Compiling libobjc2      ***"
echo "************************************"
cd libobjc2
mkdir build
cd build
cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
if [ ! "$?" = "0" ];
then
	echo "Error: could not make libobjc2. cmake failed!" 1>&2
	exit 1
fi
make -j1 # -jn number of CPU's
if [ ! "$?" = "0" ];
then
	echo "Error: could not make libobjc2. make command failed!" 1>&2
	exit 1
fi
sudo -E make install
if [ ! "$?" = "0" ];
then
	echo "Error: could not install libobjc2!" 1>&2
	exit 1
fi
cd ../..
pwd

echo "************************************"
echo "***    Compiling GNUstep core    ***"
echo "************************************"
cd core/make
./configure --enable-debug-by-default --with-layout=gnustep --enable-objc-nonfragile-abi
if [ ! "$?" = "0" ];
then
	echo "Error: could not configure GNUstep core!" 1>&2
	exit 1
fi
make && sudo -E make install
if [ ! "$?" = "0" ];
then
	echo "Error: could not make or install GNUstep core!" 1>&2
	exit 1
fi
echo ". /usr/GNUstep/System/Library/Makefiles/GNUstep.sh" >> ~/.bashrc
source ~/.bashrc
cd ../..


#/usr/lib/gcc/arm-linux-gnueabihf/4.6/libobjc.a
#/usr/lib/arm-linux-gnueabihf/libobjc.so.2
#export LD_LIBRARY_PATH=/usr/lib/arm-linux-gnueabihf/
#echo "export LD_LIBRARY_PATH=/usr/lib/:/usr/local/lib" >> ~/.bashrc
#sudo ln -s /usr/lib/gcc/arm-linux-gnueabihf/4.6/include/objc/ /usr/local/include/objc
sudo /sbin/ldconfig

echo "************************************"
echo "***    Compiling GNUstep base    ***"
echo "************************************"
cd core/base/
./configure --enable-objc-nonfragile-abi
if [ ! "$?" = "0" ];
then
	echo "Error: could not configure GNUstep base!" 1>&2
	exit 1
fi
make -j1 #number of CPUs
if [ ! "$?" = "0" ];
then
	echo "Error: could not make GNUstep base!" 1>&2
	exit 1
fi
sudo -E make install
if [ ! "$?" = "0" ];
then
	echo "Error: could not install GNUstep base!" 1>&2
	exit 1
fi
cd ../..

echo "************************************"
echo "***    Compiling  libdispatch    ***"
echo "************************************"
cd ~/libdispatch
sh autogen.sh
./configure CFLAGS="-I/usr/include/kqueue" LDFLAGS="-lkqueue -lpthread_workqueue -pthread -lm"
make -j1 #num CPUs
if [ ! "$?" = "0" ];
then
	echo "Error: could not make libdispatch!" 1>&2
	exit 1
fi
sudo -E make install
if [ ! "$?" = "0" ];
then
	echo "Error: could not install libdispatch!" 1>&2
	exit 1
fi
sudo ldconfig

echo "****************************************"
echo "*** READY. Please try testprogram in ***"
echo "***      cocoaPi/objC/arc_test       ***"
echo "***            Good luck!            ***"
echo "****************************************"



# Install compile in .bashrc
echo "export CC=clang"  >> ~/.bashrc
echo "export CXX=clang++" >> ~/.bashrc