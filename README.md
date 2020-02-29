# for_kish


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