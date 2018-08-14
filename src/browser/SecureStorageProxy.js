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
  const getItem = function (success, error, args) {
    const alias = args[0]
    const isParanoia = args[1]
    const key = args[2]

    try {
      const value = JSON.parse(localStorage.getValue(alias + '_' + key))
      success(value)
    } catch (error) {
      error(error)
    }
  }

  /**
   * Sets a specific value for a given key in localStorage
   * @param {*} key 
   * @param {*} value 
   */
  const setItem = function (success, error, args) {
    const alias = args[0]
    const isParanoia = args[1]
    const key = args[2]
    const value = args[3]

    try {
      localStorage.setItem(alias + '_' + key, value)
      getItem(success, error, [alias, isParanoia, key])
    } catch (error) {
      error(error)
    }
  }

  const initialize = function (success, error) {
    console.log('initialize is done!')
  }

  const removeAll = function (success, error) {
    localStorage.clear()
    success()
  }

  const destroy = function (success, error) {
    localStorage.clear()
    success()
  }

  module.exports = {
    initialize: warn(unlock),
    getItem: warn(getItem),
    setItem: warn(setItem),
    removeAll: warn(removeAll),
    destroy: warn(destroy)
  };

  require('cordova/exec/proxy').add('SecureStorage', module.exports)
});
