package ch.airgap.securestorage;

import android.app.Activity;
import android.app.KeyguardManager;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;
import android.provider.Settings;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import ch.papers.securestorage.Storage;

import kotlin.Unit;
import kotlin.jvm.functions.Function0;
import kotlin.jvm.functions.Function1;

public class SecureStorage extends CordovaPlugin {

  private static final String TAG = "SecureStorage";
  private static final int REQUEST_CODE_CONFIRM_DEVICE_CREDENTIALS = 1;

  // auth callbacks
  private Function0<Unit> authSuccessCallback;
  private Function0<Unit> authErrorCallback;

  private KeyguardManager mKeyguardManager;

  public SecureStorage() {

  }

  @Override
  protected void pluginInitialize() {
    super.pluginInitialize();
    mKeyguardManager = (KeyguardManager) this.cordova.getActivity().getSystemService(Context.KEYGUARD_SERVICE);
  }

  private Storage getStorageForAlias(String alias, boolean isParanoia) {
    return new Storage(this.cordova.getActivity(), alias, isParanoia);
  }

  public boolean execute(String action, JSONArray data, final CallbackContext callbackContext) throws JSONException {
    try {

      if (action.equals("initialize")) {

        String alias = data.getString(0);
        boolean isParanoia = data.getBoolean(1);

        this.getStorageForAlias(alias, isParanoia);
        callbackContext.success();

      } else if (action.equals("isDeviceSecure")) {

        callbackContext.success(mKeyguardManager.isKeyguardSecure() ? 1 : 0);

      } else if (action.equals("secureDevice")) {
        
        Intent intent = new Intent(Settings.ACTION_SECURITY_SETTINGS);
        this.cordova.getActivity().startActivity(intent);

      } else if (action.equals("getItem")) {

        String alias = data.getString(0);
        boolean isParanoia = data.getBoolean(1);
        String key = data.getString(2);

        this.getStorageForAlias(alias, isParanoia).readString(key, new Function1<String, Unit>() {
          @Override
          public Unit invoke(String s) {
            Log.d(TAG, "read successfully");
            callbackContext.success(s);
            return Unit.INSTANCE;
          }
        }, new Function1<Exception, Unit>() {
          @Override
          public Unit invoke(Exception e) {
            Log.d(TAG, "read unsuccessfully");
            callbackContext.error(e.toString());
            return Unit.INSTANCE;
          }
        }, new Function1<Function0<Unit>, Unit>() {
          @Override
          public Unit invoke(Function0<Unit> function0) {
            authSuccessCallback = function0;
            showAuthenticationScreen();
            return Unit.INSTANCE;
          }
        });

      } else if (action.equals("setItem")) {

        String alias = data.getString(0);
        boolean isParanoia = data.getBoolean(1);
        String key = data.getString(2);
        String value = data.getString(3);

        this.getStorageForAlias(alias, isParanoia).writeString(key, value, new Function0<Unit>() {
          @Override
          public Unit invoke() {
            Log.d(TAG, "written successfully");
            callbackContext.success();
            return Unit.INSTANCE;
          }
        }, new Function1<Exception, Unit>() {
          @Override
          public Unit invoke(Exception e) {
            Log.d(TAG, "written unsuccessfully");
            callbackContext.error(e.toString());
            return Unit.INSTANCE;
          }
        }, new Function1<Function0<Unit>, Unit>() {
          @Override
          public Unit invoke(Function0<Unit> function0) {
            authSuccessCallback = function0;
            showAuthenticationScreen();
            return Unit.INSTANCE;
          }
        });

      } else if (action.equals("removeAll")) {

        String alias = data.getString(0);
        boolean result = Storage.Companion.removeAll(this.cordova.getActivity(), alias);

        if (result) {
          callbackContext.success();
        } else {
          callbackContext.error("removeAll not successful");
        }

      } else if (action.equals("removeItem")) {

        String alias = data.getString(0);
        boolean isParanoia = data.getBoolean(1);
        String key = data.getString(2);

        this.getStorageForAlias(alias, isParanoia).removeString(key, new Function0<Unit>() {
          @Override
          public Unit invoke() {
            Log.d(TAG, "delete successfully");
            callbackContext.success();
            return Unit.INSTANCE;
          }
        }, new Function1<Exception, Unit>() {
          @Override
          public Unit invoke(Exception e) {
            Log.d(TAG, "delete unsuccessfully");
            callbackContext.error(e.toString());
            return Unit.INSTANCE;
          }
        });

      } else if (action.equals("destroy")) {

        boolean result = Storage.Companion.destroy(this.cordova.getActivity());
        
        if (result) {
          callbackContext.success();
        } else {
          callbackContext.error("destroy not successful");
        }

      } else if (action.equals("setupParanoiaPassword")) {

        String alias = data.getString(0);
        boolean isParanoia = data.getBoolean(1);

        this.getStorageForAlias(alias, isParanoia).setupParanoiaPassword(new Function0<Unit>() {
          @Override
          public Unit invoke() {
            Log.d(TAG, "paranoia successfully setup");
            callbackContext.success();
            return Unit.INSTANCE;
          }
        }, new Function1<Exception, Unit>() {
          @Override
          public Unit invoke(Exception e) {
            Log.d(TAG, "paranoia unsuccessfully");
            callbackContext.error(e.toString());
            return Unit.INSTANCE;
          }
        });

      }

    } catch (Exception exception) {
      callbackContext.error(exception.toString());
      Log.e(TAG, exception.toString(), exception);
    }

    return true;
  }

  private void showAuthenticationScreen() {
    // Create the Confirm Credentials screen. You can customize the title and description. Or
    // we will provide a generic one for you if you leave it null
    Intent intent = mKeyguardManager.createConfirmDeviceCredentialIntent(null, null);
    if (intent != null) {
      this.cordova.setActivityResultCallback(this);
      this.cordova.getActivity().startActivityForResult(intent, REQUEST_CODE_CONFIRM_DEVICE_CREDENTIALS);
    }
  }

  @Override
  public void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
    Log.d(TAG, "onActivityResult");
    if (requestCode == REQUEST_CODE_CONFIRM_DEVICE_CREDENTIALS) {
      if (resultCode == Activity.RESULT_OK) {
        Log.d(TAG, "result from callback okay");
        authSuccessCallback.invoke();
        Log.d(TAG, "invoke called");
      } else {
        Toast.makeText(this.cordova.getActivity(), "Authentication failed.", Toast.LENGTH_SHORT).show();
        authErrorCallback.invoke();
      }
    }
  }


}
