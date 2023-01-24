#!/bin/bash
set -e

qtdeploy build
mkdir -p build

cp manifest.json build
cp telegram.apparmor build
cp telegram.desktop build
cp telegram.url-dispatcher.json build

cp deploy/linux/telegram-client build
mv build/telegram-client build/telegram
cd pushnotifications/executable/ && qtdeploy build
cd ../..
cp pushnotifications/executable/deploy/linux/executable build
mv build/executable build/telegramHelper
cp pushnotifications/pushHelper.apparmor.json build
cp pushnotifications/pushHelper.json build

cp -R assets build

cd build && click build .
