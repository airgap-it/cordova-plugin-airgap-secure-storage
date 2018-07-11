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

    return new Promise((resolve, reject) => {
      try {
        const value = JSON.parse(localStorage.getValue(alias + '_' + key))
        resolve(value)
      } catch (error) {
        reject(error)
      }
    })
  }

  /**
   * Sets a specific value for a given key in localStorage
   * @param {*} key
   * @param {*} value
   */
  const setItem = function (args) {
    const alias = args[0]
    const isParanoia = args[1]
    const key = args[2]
    const value = args[3]

    return new Promise((resolve, reject) => {
      try {
        localStorage.setItem(alias + '_' + key, value)
        getItem([alias, isParanoia, key]).then(resolve).catch(reject)
      } catch (error) {
        reject(error)
      }
    })
  }

  const initialize = function () {
    console.log('initialize is done!')
    return new Promise((resolve) => {
      return resolve()
    })
  }

  const removeAll = function () {
    return new Promise((resolve) => {
      localStorage.clear()
      resolve()
    })
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
