cordova.define("airgap-secure-storage.SecureStorageProxy", function(require, exports, module) {


  /**
   * Warn users about unsecure implementation of browser platform
   * @param {*} handler
   */
  const warn = function (handler) {
    console.warn('Browser storage is not securely implemented in airgap-secure-storage. Only use for testing / debugging!')
    return handler
  }

  /**
   * Gets a specific key from localStorage
   * @param {*} key
   */
  const getItem = function (args) {
    const alias = args[0]
    const isParanoia = args[1]
    const key = args[2]

    try {
      return Promise.resolve(JSON.parse(localStorage.getValue(alias + '_' + key)))
    } catch (error) {
      return Promise.reject(error)
    }
  }

  /**
   * Sets a specific value for a given key in localStorage
   * @param {*} key
   * @param {*} value
   */
  const setItem = function (args) {
    const alias = args[0]
    const key = args[2]
    const value = args[3]

    try {
      localStorage.setItem(alias + '_' + key, value)
      return Promise.resolve()
    } catch (error) {
      return Promise.reject(error)
    }
  }

  const initialize = function () {
    console.log('initialize is done!')
    return Promise.resolve()
  }

  const removeAll = function () {
    localStorage.clear()
    return Promise.resolve()
  }

  module.exports = {
    initialize: warn(initialize),
    getItem: warn(getItem),
    setItem: warn(setItem),
    removeAll: warn(removeAll),
    destroy: warn(removeAll)
  };

  require('cordova/exec/proxy').add('SecureStorage', module.exports)
});
