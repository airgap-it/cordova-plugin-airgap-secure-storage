package ch.papers.securestorage.activityrunner

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.util.Log
import android.view.View
import android.widget.Toast
import ch.papers.securestorage.Storage

class SecureStorageTestActivity : AppCompatActivity() {

    private lateinit var mKeyguardManager: KeyguardManager
    private val REQUEST_CODE_CONFIRM_DEVICE_CREDENTIALS = 1
    private var secureStorage: Storage? = null

    private var authSuccessCallback: () -> Unit = {}
    private var authErrorCallback: () -> Unit = {}

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_pin_alert)

        mKeyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager;

        if (!mKeyguardManager.isKeyguardSecure()) {
            Toast.makeText(this, "Secure Lock hasn't been set up", Toast.LENGTH_LONG).show()
        }
    }

    private fun showAuthenticationScreen() {
        // Create the Confirm Credentials screen. You can customize the title and description. Or
        // we will provide a generic one for you if you leave it null
         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
             val intent =mKeyguardManager.createConfirmDeviceCredentialIntent(null, null)
             if (intent != null) {
                startActivityForResult(intent, REQUEST_CODE_CONFIRM_DEVICE_CREDENTIALS)
             }
        }
    }

    private fun showParanoiaPasswordInput() {
        Log.d("SecureStorageActivity", "Asking for Paranoia-Password")
    }

    fun setupNormalStorage(v: View) {
        secureStorage = Storage(this, "normal-storage")
    }

    fun setupParanoiaStorage(v: View) {
        secureStorage = Storage(this, "paranoia-storage", true)
        secureStorage?.setupParanoiaPassword(success = {
            Log.d("SecureStorageActivity", "Paranoia Setup successful")
        }, error = {
            Log.d("SecureStorageActivity", "Paranoia Setup failed")
        })
    }

    fun storeString(v: View) {
        val success: () -> Unit = {
            Log.d("SecureStorageActivity", "Data written!")
        }

        val error: (Exception) -> Unit = {
            Log.d("SecureStorageActivity", "Data could not be written:"+it)
        }

        val requestAuthentication: (() -> Unit) -> Unit = { success ->
            authSuccessCallback = {
                success()
            }
            showAuthenticationScreen()
        }

        secureStorage?.writeString("testFile", "testData", success = success, error = error, requestAuthentication = requestAuthentication)
    }

    fun removeString(v: View) {
        val success: () -> Unit = {
            Log.d("SecureStorageActivity", "Data deleted")
        }

        val error: (Exception) -> Unit = {
            Log.d("SecureStorageActivity", "Data could not be deleted")
        }

        secureStorage?.removeString("testFile", success = success, error = error)
    }

    fun destroy(v: View) {
        Storage.destroy(this)
    }

    fun readString(v: View) {
        val success: (String) -> Unit =  { s ->
            Log.d("SecureStorageActivity", "Data read: " + s)
        }

        val error: (Exception) -> Unit = {
            Log.d("SecureStorageActivity", "Data could not be read")
        }

        val requestAuthentication: (() -> Unit) -> Unit = { success ->
            authSuccessCallback = {
                success()
            }
            showAuthenticationScreen()
        }

        secureStorage?.readString("testFile", success = success, error = error, requestAuthentication = requestAuthentication)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_CODE_CONFIRM_DEVICE_CREDENTIALS) {
            if (resultCode == Activity.RESULT_OK) {
                authSuccessCallback()
            } else {
                Toast.makeText(this, "Authentication failed.", Toast.LENGTH_SHORT).show()
                authErrorCallback()
            }
        }
    }

    companion object {
        fun newIntent(context: Context): Intent {
            val intent = Intent(context, SecureStorageTestActivity::class.java)
            return intent
        }
    }
}
