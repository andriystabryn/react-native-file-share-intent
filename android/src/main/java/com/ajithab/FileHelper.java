package com.ajithab;

import android.content.ContentResolver;
import android.content.Context;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;

import android.net.Uri;
import android.database.Cursor;
import android.provider.MediaStore;
import android.provider.OpenableColumns;
import android.webkit.MimeTypeMap;

import java.io.File;

public class FileHelper {

    private final ReactApplicationContext reactContext;

    public FileHelper(ReactApplicationContext reactContext) {
        this.reactContext = reactContext;
    }
    
    public String getFileName(Uri uri) {
        String result = "";
        if (uri.getScheme().equals("content")) {
            Cursor cursor = this.reactContext.getContentResolver().query(uri, null, null, null, null);
            try {
                if (cursor != null && cursor.moveToFirst()) {
                    result = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                }
            } finally {
                cursor.close();
            }
        }
        if (result == null) {
            result = uri.getPath();
            int cut = result.lastIndexOf('/');
            if (cut != -1) {
                result = result.substring(cut + 1);
            }
        }
        return result;
    }

    public String getMimeType(Uri uri) {
        String mimeType = null;
        if (uri.getScheme().equals(ContentResolver.SCHEME_CONTENT)) {
            mimeType = this.reactContext.getContentResolver().getType(uri);
        } else {
            String fileExtension = MimeTypeMap.getFileExtensionFromUrl(uri
                    .toString());
            mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(
                    fileExtension.toLowerCase());
        }
        return mimeType;
    }

    public String getFilePath(Uri uri) {
        String[] columns = { MediaStore.Images.Media.DATA };
        String result = "";
        if (uri.getScheme().equals("content")) {
            Cursor cursor = this.reactContext.getContentResolver().query(uri, null, null, null, null);
            try {
                if (cursor != null && cursor.moveToFirst()) {
                    int columnIndex;
                    columnIndex = cursor.getColumnIndex(columns[0]);
                    result = cursor.getString(columnIndex);
                }
            } finally {
                cursor.close();
            }
            result = uri.toString();
        }
        if (result == null) {
            result = uri.getPath();
            int cut = result.lastIndexOf('/');
            if (cut != -1) {
                result = result.substring(cut + 1);
            }
        }
        return result;
    }

    public WritableMap getFileData(Uri uri, Context currentActivity) {
        String realPath = RealPathUtil.getRealPathFromURI(currentActivity, uri);
        File file = new File(realPath);
        String mime = "";
        if (realPath != null) {
            Uri path = Uri.parse(realPath);
            if (path.getScheme() == null) {
                path = Uri.parse("file://"+ realPath);
            }
            mime = this.getMimeType(path);
            realPath = path.toString();
        }
        WritableMap fileData = new WritableNativeMap();

        Number fileSize = file.length();

        fileData.putString("name", this.getFileName(uri));
        fileData.putString("mime", mime);
        fileData.putString("path", realPath);
        fileData.putString("size", fileSize.toString());

        return fileData;
    }
}
