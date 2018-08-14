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
function SecureStorage (alias, isParanoia) {
    this.alias = alias
    this.isParanoia = isParanoia === true ? true : false
    this.isInitiated = false;
}

/**
 * 
 * @param {*} successCallback 
 * @param {*} errorCallback 
 */
SecureStorage.prototype.isDeviceSecure = function (successCallback, errorCallback) {
    exec(successCallback, errorCallback, "SecureStorage", "isDeviceSecure", []);
}

/**
 * 
 * @param {*} successCallback 
 * @param {*} errorCallback 
 */
SecureStorage.prototype.secureDevice = function (successCallback, errorCallback) {
    exec(successCallback, errorCallback, "SecureStorage", "secureDevice", []);
}

/**
 * 
 * @param {*} successCallback 
 * @param {*} errorCallback 
 */
SecureStorage.prototype.isParanoia = function (successCallback, errorCallback) {
    return this.isParanoia
}

    /**
 * 
 * @param {*} successCallback 
 * @param {*} errorCallback 
 */
SecureStorage.prototype.init = function (successCallback, errorCallback) {
    exec(() => {
        if (this.isParanoia && cordova.platformId === 'android') {
            this.setupParanoiaPassword(() => {
                this.isInitiated = true
                successCallback()
            }, errorCallback)
        } else {
            this.isInitiated = true
            successCallback()
        }
    }, errorCallback, "SecureStorage", "initialize", [this.alias, this.isParanoia]);
}

/**
 * 
 * @param {*} successCallback 
 * @param {*} errorCallback 
 */
SecureStorage.prototype.setupParanoiaPassword = function (successCallback, errorCallback) {
    this.isInitiated = true;
    exec(successCallback, errorCallback, "SecureStorage", "setupParanoiaPassword", [this.alias, this.isParanoia]);
}

/**
 * 
 * @param {*} successCallback 
 * @param {*} errorCallback 
 */
SecureStorage.prototype.destroy = function (successCallback, errorCallback) {
    exec(successCallback, errorCallback, "SecureStorage", "destroy");
}

/**
 * 
 * @param {*} key
 * @param {*} item 
 * @param {*} successCallback 
 * @param {*} errorCallback 
 */
SecureStorage.prototype.setItem = function (key, item, successCallback, errorCallback) {
    if (!this.isInitiated) {
        return errorCallback("call initialize() first.")
    }
    exec(successCallback, errorCallback, "SecureStorage", "setItem", [this.alias, this.isParanoia, key, item]);
}

/**
 * 
 * @param {*} key 
 * @param {*} successCallback 
 * @param {*} errorCallback 
 */
SecureStorage.prototype.getItem = function (key, successCallback, errorCallback) {
    if (!this.isInitiated) {
        return errorCallback("call initialize() first.")
    }
    exec(successCallback, errorCallback, "SecureStorage", "getItem", [this.alias, this.isParanoia, key]);
}

/**
 * 
 * @param {*} key 
 * @param {*} successCallback 
 * @param {*} errorCallback 
 */
SecureStorage.prototype.removeItem = function (key, successCallback, errorCallback) {
    if (!this.isInitiated) {
        return errorCallback("call initialize() first.")
    }
    exec(successCallback, errorCallback, "SecureStorage", "removeItem", [this.alias, this.isParanoia, key]);
}

/**
 * 
 * @param {*} key 
 * @param {*} successCallback 
 * @param {*} errorCallback 
 */
SecureStorage.prototype.removeAll = function (successCallback, errorCallback) {
    if (!this.isInitiated) {
        return errorCallback("call initialize() first.")
    }
    exec(successCallback, errorCallback, "SecureStorage", "removeAll", [this.alias]);
}


module.exports = SecureStorage;
