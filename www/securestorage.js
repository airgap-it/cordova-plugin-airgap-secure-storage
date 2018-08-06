var exec = require('cordova/exec');
var cordova = require('cordova');

const execSecureStorage = (methodName, args) =>
  new Promise((resolve, reject) =>
    exec(resolve, reject, 'SecureStorage', methodName, args));

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
SecureStorage.prototype.isDeviceSecure = () => execSecureStorage('isDeviceSecure');

/**
 *
 */
SecureStorage.prototype.secureDevice = () => execSecureStorage('secureDevice');

/**
 *
 */
SecureStorage.prototype.init = function () {
  return execSecureStorage('initialize', [this.alias, this.isParanoia])
    .then(() => this.isParanoia && cordova.platformId === 'android' && this.setupParanoiaPassword())
    .then(() => this.isInitiated = true)
};

/**
 *
 */
SecureStorage.prototype.setupParanoiaPassword = function () {
  return execSecureStorage('setupParanoiaPassword', [this.alias, this.isParanoia])
    .then(() => this.isInitiated = true);
};

/**
 *
 */
SecureStorage.prototype.destroy = () => execSecureStorage('destroy');

/**
 *
 */
SecureStorage.prototype.ensureInitialized = function () {
  if (!this.isInitiated) {
    throw new Error('call initialize() first.');
  }
}

/**
 *
 * @param {*} key
 * @param {*} item
 */
SecureStorage.prototype.setItem = function (key, item) {
  this.ensureInitialized()
  return execSecureStorage('setItem', [this.alias, this.isParanoia, key, item]);
};

/**
 *
 * @param {*} key
 */
SecureStorage.prototype.getItem = function (key) {
  this.ensureInitialized()
  return execSecureStorage('getItem', [this.alias, this.isParanoia, key]);
};

/**
 *
 * @param {*} key
 */
SecureStorage.prototype.removeItem = function (key) {
  this.ensureInitialized()
  return execSecureStorage('removeItem', [this.alias, this.isParanoia, key]);
};

/**
 *
 * @param {*} key
 */
SecureStorage.prototype.removeAll = function () {
  this.ensureInitialized()
  return execSecureStorage('removeAll', [this.alias]);
};

module.exports = SecureStorage;
