#!/bin/sh

# configure URL's
gnustepMakeURL="ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-make-2.6.6.tar.gz"
gnustepBaseURL="ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-base-1.24.7.tar.gz"
gnustepGuiURL="ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-gui-0.24.0.tar.gz"
gnustepBackURL="ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-back-0.24.0.tar.gz"
libObjC2URL="http://download.gna.org/gnustep/libobjc2-1.7.tgz"

# Everything else should happen automatically 
gnustepMakeArchive=$(basename $gnustepMakeURL)
gnustepBaseArchive=$(basename $gnustepBaseURL)
gnustepGuiArchive=$(basename $gnustepGuiURL)
gnustepBackArchive=$(basename $gnustepBackURL)
libObjC2Archive=$(basename $libObjC2URL)

gnustepMakeFolder=${gnustepMakeArchive%.tar.gz}
gnustepBaseFolder=${gnustepBaseArchive%.tar.gz}
gnustepGuiFolder=${gnustepGuiArchive%.tar.gz}
gnustepBackFolder=${gnustepBackArchive%.tar.gz}
libObjC2Folder=${libObjC2Archive%.tgz}

# Download and uncompress GNUstep
if [ ! -d $gnustepMakeFolder ];
then
	wget $gnustepMakeURL
	if [ "$?" = "0" ];
	then

		echo "Success"
		tar xvfz $gnustepMakeArchive
		if [ "$?" = "0" ];
		then
			rm $gnustepMakeArchive
		else
			echo "Error: Could not uncompress GNUstep-Make!" 1>&2
                	exit 1
		fi
	else

		echo "Error: Could not download GNUstep-Make!" 1>&2
		exit 1
	fi
fi

if [ ! -d $gnustepBaseFolder ];
then
        wget $gnustepBaseURL
        if [ "$?" = "0" ];
        then

                echo "Success"
                tar xvfz $gnustepBaseArchive
                if [ "$?" = "0" ];
                then
                        rm $gnustepBaseArchive
                else
                        echo "Error: Could not uncompress GNUstep-Base!" 1>&2
                        exit 1
                fi
        else

                echo "Error: Could not download GNUstep-Base!" 1>&2
                exit 1
        fi
fi

if [ ! -d $gnustepGuiFolder ];
then
        wget $gnustepGuiURL
        if [ "$?" = "0" ];
        then

                echo "Success"
                tar xvfz $gnustepGuiArchive
                if [ "$?" = "0" ];
                then
                        rm $gnustepGuiArchive
                else
                        echo "Error: Could not uncompress GNUstep-Gui!" 1>&2
                        exit 1
                fi
        else

                echo "Error: Could not download GNUstep-Gui!" 1>&2
                exit 1
        fi
fi

if [ ! -d $gnustepBackFolder ];
then
        wget $gnustepBackURL
        if [ "$?" = "0" ];
        then

                echo "Success"
                tar xvfz $gnustepBackArchive
                if [ "$?" = "0" ];
                then
                        rm $gnustepBackArchive
                else
                        echo "Error: Could not uncompress GNUstep-Back!" 1>&2
                        exit 1
                fi
        else

                echo "Error: Could not download GNUstep-Back!" 1>&2
                exit 1
        fi
fi


if [ ! -d $libObjC2Folder ];
then
        wget $libObjC2URL
        if [ "$?" = "0" ];
        then

                echo "Success"
                tar xvfz $libObjC2Archive
                if [ "$?" = "0" ];
                then
                        rm $libObjC2Archive
                else
                        echo "Error: Could not uncompress libObjC2!" 1>&2
                        exit 1
                fi
        else

                echo "Error: Could not download libObjC2!" 1>&2
                exit 1
        fi
fi

echo "*****************************"
echo "*** Building GNUstep Make ***"
echo "*****************************"

export CC=clang

cd $gnustepMakeFolder
./configure --enable-objc-nonfragile-abi
if [ "$?" = "0" ];
then
	sudo make install	
        if [ "$?" != "0" ];
	then
		echo "Error: Could not install GNUstep Make!" 1>&2
        	exit 1
	fi 
else
	echo "Error: Could not configure GNUstep Make!" 1>&2
        exit 1
fi
cd ..

echo "**************************"
echo "*** Building libObjC2  ***"
echo "**************************"

export CC=clang

cd $libObjC2Folder
make
if [ "$?" = "0" ];
then
        sudo make install       
        if [ "$?" != "0" ];
        then
                echo "Error: Could not install libObjC2!" 1>&2
                exit 1
        fi 
else
        echo "Error: Could not compile libObjC2!" 1>&2
        exit 1
fi
cd ..

echo "******************************"
echo "*** Repeating GNUstep Make ***"
echo "******************************"
cd $gnustepMakeFolder
./configure --enable-objc-nonfragile-abi
if [ "$?" = "0" ];
then
        sudo make install       
        if [ "$?" != "0" ];
        then
                echo "Error: Could not install GNUstep Make!" 1>&2
                exit 1
        fi 
else
        echo "Error: Could not configure GNUstep Make!" 1>&2
        exit 1
fi
cd ..

echo "*****************************"
echo "*** Building GNUstep Base ***"
echo "*****************************"
cd $gnustepBaseFolder
./configure --enable-objc-nonfragile-abi
if [ "$?" = "0" ];
then
        make        
        if [ "$?" != "0" ];
        then
                echo "Error: Could not compile GNUstep Base!" 1>&2
                exit 1
        fi 
	sudo make install
	if [ "$?" != "0" ];
        then
                echo "Error: Could not install GNUstep Base!" 1>&2
                exit 1
        fi 
else
        echo "Error: Could not configure GNUstep Base!" 1>&2
        exit 1
fi
cd ..

export LD_LIBRARY_PATH=/usr/local/lib/
echo "****************************"
echo "*** Building GNUstep Gui ***"
echo "****************************"
cd $gnustepGuiFolder
./configure
if [ "$?" = "0" ];
then
        make
        if [ "$?" != "0" ];
        then
                echo "Error: Could not compile GNUstep Gui!" 1>&2
                exit 1
        fi 
        sudo make install
        if [ "$?" != "0" ];
        then
                echo "Error: Could not install GNUstep Gui!" 1>&2
                exit 1
        fi 
else
        echo "Error: Could not configure GNUstep Gui!" 1>&2
        exit 1
fi
cd ..

echo "*****************************"
echo "*** Building GNUstep Back ***"
echo "*****************************"
cd $gnustepBackFolder
./configure
if [ "$?" = "0" ];
then
        make
        if [ "$?" != "0" ];
        then
                echo "Error: Could not compile GNUstep Back!" 1>&2
                exit 1
        fi 
        sudo make install
        if [ "$?" != "0" ];
        then
                echo "Error: Could not install GNUstep Back!" 1>&2
                exit 1
        fi 
else
        echo "Error: Could not configure GNUstep Back!" 1>&2
        exit 1
fi
cd ..

echo "### GNUstep was compiled and installed successfully! ###""

