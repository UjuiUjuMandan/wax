# 仅构建arm64的APK

cd "$( cd "$( dirname "$0"  )" && pwd  )/.."

cd go/mobile
gomobile init
gomobile bind -androidapi 21 -target=android/arm64 -o lib/Mobile.aar ./

cd ../..
flutter build apk --target-platform android-arm64
