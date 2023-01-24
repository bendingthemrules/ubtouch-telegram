# Telegram client

An enhanced telegram webwrapper

[![OpenStore](https://open-store.io/badges/en_US.png)](https://open-store.io/app/nl.btr.telegram)

## Building

This app is build using [clickable](https://clickable-ut.dev/en/latest/) and can be build using the build script:

```bash
./build.sh
```

Push the app build can easily be pushed to the device with [adb](https://developer.android.com/studio/command-line/adb) using: \
(make sure the app version is correct)

```bash
adb push nl.btr.telegram_0.2.0_arm64.click /home/phablet
```

### Building the push helper

You can optionally build the push helper seperate by executing: \
(this is also done in the build script)

```bash
cd pushnotifications/executable/ && qtdeploy build
```

## Debugging

Logs can be seen using:

```bash
adb shell # Make sure the device is connected and Developer mode is turned on
journalctl -f
```

## License

This project is licened under the GNU GPL v3 license
