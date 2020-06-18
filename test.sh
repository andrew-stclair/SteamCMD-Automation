#!/bin/bash

# Set variables
pwd=$(pwd)
upperdir=${pwd}/testresults
workdir=${pwd}/workdir
testroot=${pwd}/testroot

# Clean and setup testing directories
sudo rm -rf $testroot
mkdir -p $upperdir
mkdir -p $workdir
mkdir -p $testroot

# Mount fuse-overlayfs
sudo fuse-overlayfs -o rw,lowerdir=/,upperdir=$upperdir,workdir=$workdir $testroot

# Copy and Test script
cp auto-steamcmd.sh $testroot/auto-steamcmd.sh
sudo chroot $testroot /bin/bash -c /auto-steamcmd.sh

# Unmount fuse-overlayfs
sudo umount -t fuse-overlayfs $testroot

# Display results
echo "Results can be found in $upperdir"

# Cleanup
sudo rm -rf $upperdir
sudo rm -rf $workdir