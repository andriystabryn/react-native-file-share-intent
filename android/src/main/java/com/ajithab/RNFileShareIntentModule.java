
package com.ajithab;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;

import java.io.File;
import java.util.ArrayList;

import android.util.Log;
import android.widget.Toast;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;


public class RNFileShareIntentModule extends ReactContextBaseJavaModule implements ActivityEventListener {

  private Callback successShareCallback;
  private final ReactApplicationContext reactContext;

  public RNFileShareIntentModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    reactContext.addActivityEventListener(this);
  }


  @Override
  public void onNewIntent(Intent intent) {
    Activity mActivity = getCurrentActivity();
    
    if(mActivity == null) { return; }

    mActivity.setIntent(intent);
    shareFile(intent);
  }

  @ReactMethod
  public void setCallback(Callback successCallback) {
    successShareCallback = successCallback;
  }

  @ReactMethod
  public void getFilePath(Callback successCallback) {
    successShareCallback = successCallback;
    Activity mActivity = getCurrentActivity();

    if(mActivity == null) { return; }

    Intent intent = mActivity.getIntent();
    shareFile(intent);
  }

  private void shareFile(Intent intent) {
    String action = intent.getAction();
    String type = intent.getType();
    Activity currentActivity = getCurrentActivity();

    FileHelper fileHelper = new FileHelper(this.reactContext);

    WritableArray res = new WritableNativeArray();
    if (Intent.ACTION_SEND.equals(action) && type != null) {
      if (type.startsWith("image/") || type.startsWith("video/") || type.startsWith("application/")) {
        Uri fileUri = (Uri) intent.getParcelableExtra(Intent.EXTRA_STREAM);
        if (fileUri != null) {
          res.pushMap(fileHelper.getFileData(fileUri, currentActivity));
          successShareCallback.invoke(res);
        }
      }
    } else if (Intent.ACTION_SEND_MULTIPLE.equals(action) && type != null) {
      ArrayList<Uri> fileUris = intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM);
      if (fileUris != null) {
        for (Uri uri: fileUris) {
          res.pushMap(fileHelper.getFileData(uri, currentActivity));
        }
        successShareCallback.invoke(res);
      }
    }
  }

  @ReactMethod
  public void clearFilePath() {
    Activity mActivity = getCurrentActivity();
    
    if(mActivity == null) { return; }

    Intent intent = mActivity.getIntent();
    String type = intent.getType();
    if ("text/plain".equals(type)) {
      intent.removeExtra(Intent.EXTRA_TEXT);
    } else if (type.startsWith("image/") || type.startsWith("video/") || type.startsWith("application/")) {
      intent.removeExtra(Intent.EXTRA_STREAM);
    }
  }
  @Override
  public String getName() {
    return "RNFileShareIntent";
  }
  
  @Override
  public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data){}
}