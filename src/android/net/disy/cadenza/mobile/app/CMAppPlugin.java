package net.disy.cadenza.mobile.app;

import android.content.Intent;
import android.util.Base64;
import android.util.Base64OutputStream;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.concurrent.Executors;

import androidx.documentfile.provider.DocumentFile;

public class CMAppPlugin extends CordovaPlugin {
  private CallbackContext callbackContext = null;
  private String cadenzaMobileTargetPath = null;
  private String exportFilePath = null;
  private String filePath = null;

  private int openDocumentTreeRequestCode = 42;
  private int saveDocumentRequestCode = 43;

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    if (action.equals("disableIdleTimeout")) {
      callbackContext.success("disableIdleTimeout");
      return true;
    } else if (action.equals("enableIdleTimeout")) {
      callbackContext.success("enableIdleTimeout");
      return true;
    } else if (action.equals("startMigration")) {
      this.callbackContext = callbackContext;
      this.cadenzaMobileTargetPath = (String) args.get(0);
      if (this.cadenzaMobileTargetPath != null) {
        this.cadenzaMobileTargetPath = this.cadenzaMobileTargetPath.replace("file://", "");
      }

      Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);

      this.cordova.setActivityResultCallback(this);
      this.cordova.getActivity().startActivityForResult(intent, openDocumentTreeRequestCode);

      return true;
    } else if (action.equals("convertFileToBase64")) {
      this.callbackContext = callbackContext;
      this.filePath = (String) args.get(0);
      if (this.filePath != null) {
        this.filePath = this.filePath.replace("http://localhost/_app_file_", "");
      }

      convertFileToBase64();
    } else if (action.equals("exportFile")) {
      this.callbackContext = callbackContext;

      this.exportFilePath = (String) args.get(0);
      String exportFileName = (String) args.get(1);

      if (this.exportFilePath != null) {
        this.exportFilePath = this.exportFilePath.replace("file://", "");
      }

      Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
      intent.addCategory(Intent.CATEGORY_OPENABLE);
      intent.setType("application/octet-stream");
      intent.putExtra(Intent.EXTRA_TITLE, exportFileName);

      this.cordova.setActivityResultCallback(this);
      this.cordova.getActivity().startActivityForResult(intent, saveDocumentRequestCode);

      return true;
    } else if (action.equals("getCloudDirectory")) {
      callbackContext.success("");
      return true;
    }

    return false;
  }

  private void convertFileToBase64() {
    InputStream fileStream;
    try {
      fileStream = new FileInputStream(this.filePath);
      byte[] buffer = new byte[8192];
      int bytesRead;

      ByteArrayOutputStream output = new ByteArrayOutputStream();
      Base64OutputStream output64 = new Base64OutputStream(output, Base64.DEFAULT);
      while ((bytesRead = fileStream.read(buffer)) != -1) {
        output64.write(buffer, 0, bytesRead);
      }
      output64.close();

      callbackContext.success(output.toString());
    } catch (Exception e) {
      callbackContext.error("");
    }
  }

  @Override
  public void onActivityResult(int requestCode, int resultCode, Intent intent) {
    if (requestCode == openDocumentTreeRequestCode) {
      if (intent != null && intent.getData() != null) {
        final DocumentFile cadenzaMobileDirectory = DocumentFile.fromTreeUri(this.cordova.getActivity(), intent.getData());

        if (containsMapsfoldersJsonFile(cadenzaMobileDirectory)) {
          final String cadenzaMobileTargetPath = this.cadenzaMobileTargetPath;
          Executors.newSingleThreadExecutor().execute(() -> {
              copyCadenzaMobileDirectory(cadenzaMobileDirectory, cadenzaMobileTargetPath);
              //          copyCadenzaMobileDirectory(cadenzaMobileDirectory, this.cordova.getActivity().getFilesDir().getPath());
              callbackContext.success(cadenzaMobileDirectory.getName());
            }
          );
        } else {
          callbackContext.error("mapsfolders.json");
        }
      } else {
        callbackContext.error("");
      }
    } else if (requestCode == saveDocumentRequestCode) {
      if (intent != null && intent.getData() != null) {
        try {
          OutputStream targetFileOutputStream = this.cordova.getActivity().getContentResolver().openOutputStream(intent.getData());

          if (targetFileOutputStream != null) {
            Executors.newSingleThreadExecutor().execute(() -> {
              try {
                BufferedInputStream sourceFileInputStream = new BufferedInputStream(new FileInputStream(this.exportFilePath));
                int bytes;
                while ((bytes = sourceFileInputStream.read()) != -1) {
                  targetFileOutputStream.write(bytes);
                }
                targetFileOutputStream.flush();

                callbackContext.success("");
              } catch(IOException e) {
                e.printStackTrace();
                callbackContext.error("error");
              }
            });
          }
        }
        catch(IOException e) {
          e.printStackTrace();
          callbackContext.error("error");
        }
      } else {
        callbackContext.error("");
      }
    }
  }

  private boolean containsMapsfoldersJsonFile(DocumentFile cadenzaMobileDirectory) {
    boolean result = false;

    if (cadenzaMobileDirectory != null && cadenzaMobileDirectory.canRead()) {
      if (cadenzaMobileDirectory.isDirectory()) {
        for (DocumentFile currentFile : cadenzaMobileDirectory.listFiles()) {
          if (currentFile.isFile() && currentFile.getName().equals("mapsfolders.json")) {
            result = true;
            break;
          }
        }
      }
    }

    return result;
  }

  private void copyCadenzaMobileDirectory(DocumentFile cadenzaMobileDirectory, String targetPath) {
    if (cadenzaMobileDirectory != null && cadenzaMobileDirectory.canRead()) {
      if (cadenzaMobileDirectory.isDirectory()) {
        for (DocumentFile currentSubDirectory: cadenzaMobileDirectory.listFiles()) {
          if (currentSubDirectory.isDirectory()) {
            File subfolderDirectory = new File(targetPath, currentSubDirectory.getName());
            subfolderDirectory.mkdirs();
          }

          if (!targetPath.endsWith("/")) {
            targetPath += "/";
          }
          copyCadenzaMobileDirectory(currentSubDirectory, targetPath + currentSubDirectory.getName());
        }
      } else {
        copyCadenzaMobileFile(cadenzaMobileDirectory, targetPath);
      }
    }
  }

  private void copyCadenzaMobileFile(DocumentFile cadenzaMobileFIle, String targetDirectory) {
    InputStream cmFileInputStream = null;
    OutputStream cmFileOutputStream = null;

    try {
      cmFileInputStream = this.cordova.getActivity().getContentResolver().openInputStream(cadenzaMobileFIle.getUri());
      cmFileOutputStream = new FileOutputStream(targetDirectory, false);

      byte[] buffer = new byte[1024];
      int read;
      while ((read = cmFileInputStream.read(buffer)) != -1) {
        cmFileOutputStream.write(buffer, 0, read);
      }
    } catch (FileNotFoundException e) {
      e.printStackTrace();
    } catch (IOException e) {
      e.printStackTrace();
    } finally {
      if (cmFileOutputStream != null) {
        try {
          cmFileOutputStream.flush();
        } catch (IOException e) {
          e.printStackTrace();
        }
      }
    }
  }
}
