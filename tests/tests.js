cordova.define("airgap-cordova-secure-storage-tests.tests", function (require, exports, module) {
  exports.defineAutoTests = function () {
    const SecureStorage = window.SecureStorage;

    describe('Plugin Information (window.SecureStorage)', function () {
      it('should exist', function () {
        expect(SecureStorage).toBeDefined()
      })

      it('should expose get/set/unlock', function () {
        expect(SecureStorage.unlock).toBeDefined()
      })

      it('should successfully store and retrieve a string value', function (done) {
        expect(SecureStorage.set).toBeDefined()
        expect(SecureStorage.get).toBeDefined()

        SecureStorage.set('exampleKey', 'airgap-is-a-nice-software', function (result) {
          SecureStorage.get('exampleKey', function (result) {
            expect(result).toBe('airgap-is-a-nice-software')
            done()
          }, function (error) {
            done(error)
          })
        }, function (error) {
          done(error)
        })
      })
    })
  }
})
