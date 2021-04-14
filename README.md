# for_kish
This is a passenger application for managing driver and passenger coordination. The product is designed by my friend ["Mostafa Khalilnasab"](https://github.com/mostafakhn).

The driver mobile app is here[https://github.com/karianpour/forkish-driver]

The back-end app is here[https://github.com/karianpour/forkish-back]

Here you can see a video of the apps in action:

[![Demo](https://img.youtube.com/vi/3bYX-b0S-2U/0.jpg)](https://www.youtube.com/watch?v=3bYX-b0S-2U)


# Develmopment

flutter pub run build_runner watch

# To Install packages
flutter pub get

# To clear packages
flutter clean
flutter pub cache repair

# Release

flutter build apk --split-per-abi --release

scp build/app/outputs/apk/release/app-armeabi-v7a-release.apk karianpour:~/share/
