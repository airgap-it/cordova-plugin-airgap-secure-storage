# AirGap Secure Storage - Cordova Plugin

## Installation
Install the plugin simply using npm:

```
npm install git+ssh://git@github.com:airgap-it/cordova-plugin-airgap-secure-storage.git#master --save
```

Make sure the plugin is added in your cordova `config.xml` as follows:

```
<plugin name="cordova-plugin-airgap-secure-storage" spec="git+ssh://git@github.com:airgap-it/cordova-plugin-airgap-secure-storage.git#master" />
```

Instead of `#master` you can also pass a specific commit-hash to fix the version you would like to install.

### iOS

In order to use Face ID, this plugins requires the following usage description:

* `NSFaceIDUsageDescription` describes the reason why the app needs access to the secure storage. 

To add this entry into the `info.plist`, you can use the `edit-config` tag in the `config.xml` like this:

```
<edit-config target="NSFaceIDUsageDescription" file="*-Info.plist" mode="merge">
    <string>Face ID is needed to save your keys to the secure storage.</string>
</edit-config>
```

## Pre-Requisites Android / iOS
To work, SecureStorage requires a secure lock-screen setup, either secured by a PIN / Pattern or Fingerprint. Otherwise, the keystore cannot be used to safely store data.

## Usage
The plugin provides a global variable as any cordova plugin does, to create a new instance call it as follows:

```
let secureStorage = new window.SecureStorage("secure-storage-alias", false)
```

You need to init() the SecureStorage instance in order to set it up properly if necessary.

```
secureStorage.init(() => {
    // successful setup
}), (error) => {
    // setup failed
})
```

Then, the plugin provides the following functionalities:

```
secureStorage.isDeviceSecure(key, value, () => {}, (error) => {})
secureStorage.secureDevice(key, value, () => {}, (error) => {})

secureStorage.setItem(key, value, () => {}, (error) => {})
secureStorage.getItem(key, (value) => {}, (error) => {})
secureStorage.removeItem(key, () => {}, (error) => {})
secureStorage.removeAll(key, () => {}, (error) => {})
```

Everything else is handled by the device.