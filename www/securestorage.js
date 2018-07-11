var exec = require('cordova/exec');
var cordova = require('cordova');

/**
 *
 * @param {*} alias
 * @param {*} isParanoia
 * - requires passcode (PBKDF) and is encrypted with secured hardware key (secure enclave or KeyStore)
 * - requires biometrics (touch id or face id) and is encrypted with secured hardware key (secure enclave or KeyStore)
 * - requires biometrics (touch id or face id) and passcode (PBKDF) is encrypted with secured hardware key (secure enclave or KeyStore)
 */
function SecureStorage(alias, isParanoia) {
  this.alias = alias;
  this.isParanoia = isParanoia === true;
  this.isInitiated = false;
}

/**
 *
 */
SecureStorage.prototype.isDeviceSecure = function () {
  return new Promise((resolve, reject) => {
    return exec(resolve, reject, 'SecureStorage', 'isDeviceSecure', []);
  });
};

/**
 *
 */
SecureStorage.prototype.secureDevice = function () {
  return new Promise((resolve, reject) => {
    return exec(resolve, reject, 'SecureStorage', 'secureDevice', []);
  });
};

/**
 *
 */
SecureStorage.prototype.isParanoia = function () {
  return this.isParanoia;
};

/**
 *
 */
SecureStorage.prototype.init = function () {
  return new Promise((resolve, reject) => {
    return exec(() => {
      if (this.isParanoia && cordova.platformId === 'android') {
        this.setupParanoiaPassword(() => {
          this.isInitiated = true;
          resolve();
        }, reject);
      } else {
        this.isInitiated = true;
        resolve();
      }
    }, reject, 'SecureStorage', 'initialize', [this.alias, this.isParanoia]);
  });
};

/**
 *
 */
SecureStorage.prototype.setupParanoiaPassword = function () {
  return new Promise((resolve, reject) => {
    this.isInitiated = true;
    return exec(resolve, reject, 'SecureStorage', 'setupParanoiaPassword', [this.alias, this.isParanoia]);
  });
};

/**
 *
 */
SecureStorage.prototype.destroy = function () {
  return new Promise((resolve, reject) => {
    return exec(resolve, reject, 'SecureStorage', 'destroy');
  });
};

/**
 *
 * @param {*} key
 * @param {*} item
 * @param {*} successCallback
 * @param {*} errorCallback
 */
SecureStorage.prototype.setItem = function (key, item) {
  return new Promise((resolve, reject) => {
    if (!this.isInitiated) {
      return reject('call initialize() first.');
    }
    return exec(resolve, reject, 'SecureStorage', 'setItem', [this.alias, this.isParanoia, key, item]);
  });
};

/**
 *
 * @param {*} key
 */
SecureStorage.prototype.getItem = function (key) {
  return new Promise((resolve, reject) => {
    if (!this.isInitiated) {
      return reject('call initialize() first.');
    }
    return exec(resolve, reject, 'SecureStorage', 'getItem', [this.alias, this.isParanoia, key]);
  });
};

/**
 *
 * @param {*} key
 */
SecureStorage.prototype.removeItem = function (key) {
  return new Promise((resolve, reject) => {
    if (!this.isInitiated) {
      return reject('call initialize() first.');
    }
    return exec(resolve, reject, 'SecureStorage', 'removeItem', [this.alias, this.isParanoia, key]);
  });
};

/**
 *
 * @param {*} key
 */
SecureStorage.prototype.removeAll = function () {
  return new Promise((resolve, reject) => {
    if (!this.isInitiated) {
      return reject('call initialize() first.');
    }
    return exec(resolve, reject, 'SecureStorage', 'removeAll', [this.alias]);
  });
};

module.exports = SecureStorage;
