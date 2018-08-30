Based on https://medium.com/@authmane512/how-to-build-an-apk-from-command-line-without-ide-7260e1e22676

#enviroment variables
$PROJ 
export PROJ=path/to/HelloAndroid

$ANDROID_PLATFORM
export ANDROID_PLATFORM=path/to/platforms/android.jar

$ANDROID_BUILDTOOLS
export ANDROID_BUILDTOOLS=path/to/android-sdk/build-tools

$ANDROID_PLATFORM_TOOLS
export ANDROID_PLATFORM_TOOLS=path/to/android-sdk/platform-tools

#in $ANDROID_BUILDTOOLS - building R.java
./aapt package -f -m -J $PROJ/src -M $PROJ/AndroidManifest.xml -S $PROJ/res -I $ANDROID_PLATFORM/android.jar

#in project root - building java files into obj dir
 javac -d obj -classpath src -bootclasspath $ANDROID_PLATFORM/android.jar src/com/example/helloandroid/*.java

#making dex android files - in $ANDROID_BUILDTOOLS
./dx --dex --output=$PROJ/bin/classes.dex $PROJ/obj

#making the apk - in $ANDROID_BUILDTOOLS
./aapt package -f -m -F $PROJ/bin/hello.unaligned.apk -M $PROJ/AndroidManifest.xml -S $PROJ/res -I $ANDROID_PLATFORM/android.jar

#then we need to add the classes.dex to that apk with but first copying them into root so the structure is ok and classes.dex will be on the root path in the apk
cp $PROJ/bin/classes.dex $PROJ
./aapt add $PROJ/bin/hello.unaligned.apk classes.dex 

#checking the apk
./aapt list $PROJ/bin/hello.unaligned.apk 

#should return this output structure
AndroidManifest.xml
res/layout/activity_main.xml
resources.arsc
classes.dex

#sign the package
#generate key
keytool -genkeypair -validity 365 -keystore mykey.keystore -keyalg RSA 

#sign unaligned $ANDROID_BUILDTOOLS
./apksigner sign --ks mykey.keystore $PROJ/bin/hello.unaligned.apk 

#align $ANDROID_BUILDTOOLS
./zipalign -f 4 $PROJ/bin/hello.unaligned.apk $PROJ/bin/hello.apk

#install $ANDROID_PLATFORM_TOOLS
./adb devices 
./adb logcat

#if there is a signature error sign the app again this time sign the hello.apk
./adb install $PROJ/bin/hello.apk
./adb shell am start -n com.example.helloandroid/.MainActivity

#run build script
chmod +x build.sh

#use test for launching the app 
./build.sh test 
