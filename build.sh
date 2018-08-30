#!/bin/bash

set -e

ADB="/path/to/adb"
BUILDTOOLSPATH="/path/to/android-sdk/build-tools/version"
AAPT="/path/to/android-sdk/build-tools/version/aapt"
DX="/path/to/android-sdk/build-tools/version/dx"
ZIPALIGN="/path/to/android-sdk/build-tools/version/zipalign"
APKSIGNER="/path/to/android-sdk/build-tools/version/apksigner" # /!\ version 26
PLATFORM="/path/to/android/platforms/android-version/android.jar"
KEYPASSWORD="PASSWORD"

echo "Cleaning..."
rm -rf obj/*
rm -rf src/com/example/helloandroid/R.java

echo "Generating R.java file..."
$AAPT package -f -m -J src -M AndroidManifest.xml -S res -I $PLATFORM

echo "Compiling..."
javac -d obj -classpath src -bootclasspath $PLATFORM src/com/example/helloandroid/MainActivity.java
javac -d obj -classpath src -bootclasspath $PLATFORM src/com/example/helloandroid/R.java

echo "Translating in Dalvik bytecode..."
$DX --dex --output=classes.dex obj

echo "Making APK..."
$AAPT package -f -m -F bin/hello.unaligned.apk -M AndroidManifest.xml -S res -I $PLATFORM
$AAPT add bin/hello.unaligned.apk classes.dex

echo "Aligning and signing APK..."
$ZIPALIGN -f 4 bin/hello.unaligned.apk bin/hello.apk
$APKSIGNER sign --ks $BUILDTOOLSPATH/mykey.keystore --ks-pass pass:$KEYPASSWORD --key-pass pass:$KEYPASSWORD bin/hello.apk 


if [ "$1" == "run" ]; then
	echo "Launching..."
	$ADB install -r bin/hello.apk
	$ADB shell am start -n com.example.helloandroid/.MainActivity
fi