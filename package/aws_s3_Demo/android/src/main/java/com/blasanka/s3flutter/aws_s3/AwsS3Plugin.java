package com.blasanka.s3flutter.aws_s3;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Handler;
import android.util.Log;

import androidx.annotation.NonNull;

import com.amazonaws.AmazonClientException;
import com.amazonaws.ClientConfiguration;
import com.amazonaws.auth.CognitoCredentialsProvider;
import com.amazonaws.mobile.client.AWSMobileClient;
import com.amazonaws.mobileconnectors.s3.transfermanager.MultipleFileUpload;
import com.amazonaws.mobileconnectors.s3.transfermanager.ObjectMetadataProvider;
import com.amazonaws.mobileconnectors.s3.transfermanager.TransferManager;
import com.amazonaws.mobileconnectors.s3.transfermanager.internal.MultipleFileTransfer;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferListener;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferObserver;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferState;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferUtility;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.event.ProgressListener;
import com.amazonaws.event.ProgressEvent;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.DeleteObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.auth.AWSCredentials;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

import static com.amazonaws.event.ProgressEvent.COMPLETED_EVENT_CODE;
import static com.amazonaws.event.ProgressEvent.FAILED_EVENT_CODE;
import static com.amazonaws.mobile.auth.core.internal.util.ThreadUtils.runOnUiThread;

/**
 * AwsS3Plugin
 */
public class AwsS3Plugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

    private static final String TAG = "awsS3Plugin";
    private static final String CHANNEL = "com.blasanka.s3Flutter/aws_s3";
    private static final String STREAM = "com.blasanka.s3Flutter/uploading_status";
    public static String awsAKey = "";
    public static String awsSKey = "";
    private static AWSCredentials awsCredentials;
    private static AmazonS3Client s3client;
    private String filePath;
    private String awsFolder;
    private String fileNameWithExt;
    private MethodChannel.Result parentResult;
    //    private ClientConfiguration clientConfiguration;
    private TransferUtility transferUtility1;
    private String bucketName;
    private Context mContext;
    private EventChannel eventChannel;
    private MethodChannel methodChannel;
    private EventChannel.EventSink events;

    public AwsS3Plugin() {
        filePath = "";
        awsFolder = "";
        fileNameWithExt = "";
//        clientConfiguration = new ClientConfiguration();
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        AwsS3Plugin s3Plugin = new AwsS3Plugin();
        s3Plugin.whenAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        whenAttachedToEngine(flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getBinaryMessenger());
    }

    private void whenAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.mContext = applicationContext;
        methodChannel = new MethodChannel(messenger, CHANNEL);
        eventChannel = new EventChannel(messenger, STREAM);
        eventChannel.setStreamHandler(this);
        methodChannel.setMethodCallHandler(this);

        Log.d(TAG, "whenAttachedToEngine");
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        mContext = null;
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
        eventChannel.setStreamHandler(null);
        eventChannel = null;

        Log.d(TAG, "onDetachedFromEngine");
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        parentResult = result;
        if (call.method.equals("initAWS")) {
            Log.d(TAG, "onMethodCall: ");
            Log.d(TAG, "awsCredentials  0 : ");
            awsAKey = call.argument("awsAKey");
            awsSKey = call.argument("awsSKey");
            awsCredentials = new BasicAWSCredentials(awsAKey, awsSKey);
            Log.d(TAG, "awsCredentials : ");
            s3client = new AmazonS3Client(awsCredentials);
            parentResult.success(true);
        } else if (call.method.equals("uploadToS3")) {
            Log.d(TAG + " uploadSingleFile 3" ,"3 ");
            filePath = call.argument("filePath");

            Log.d(TAG, "onMethodCall: " + filePath);

            awsFolder = call.argument("awsFolder");
            fileNameWithExt = call.argument("fileNameWithExt");
            String poolId = call.argument("poolId");
            String reg = call.argument("region");
            bucketName = call.argument("bucketName");
            configureS3(poolId, reg);
            Log.d(TAG + " uploadSingleFile 2" ,"2 ");
            uploadSingleFile();
        } else if (call.method.equals("deleteFromS3")) {
            filePath = call.argument("filePath");

            Log.d(TAG, "onMethodCall: " + filePath);

            awsFolder = call.argument("awsFolder");
            fileNameWithExt = call.argument("fileNameWithExt");
            String poolId = call.argument("poolId");
            String reg = call.argument("region");
            bucketName = call.argument("bucketName");

            configureS3(poolId, reg);
            delete();
        } else if (call.method.equals("uploadMultiFileToS3")) {
//            uploadMultipleFile(call);
        } else {
            result.notImplemented();
        }
    }

    private void configureS3(String poolId, String reg) {
//        assert reg != null;
        try {
//            String regionName = reg.replaceFirst("Regions.", "");
//            Regions region = Regions.valueOf(regionName);

//            clientConfiguration.setConnectionTimeout(250000);
//            clientConfiguration.setSocketTimeout(250000);

//            CognitoCredentialsProvider credentialsProvider = new CognitoCredentialsProvider(poolId, region, clientConfiguration);

//            Log.d(TAG + " reg"+ reg);
            s3client.setRegion(Region.getRegion(Regions.US_WEST_2));

            transferUtility1 = TransferUtility.builder().context(mContext).s3Client(s3client).build();
        } catch (Exception e) {
            Log.e(TAG, "onMethodCall: exception: " + e.getMessage());
        }
    }

    private void uploadSingleFile() {
        Log.d(TAG + " uploadSingleFile" ,"1 ");
        String awsPath = fileNameWithExt;
        if (awsFolder != null && !awsFolder.equals("")) {
            awsPath = fileNameWithExt;
        }
        TransferObserver transferObserver1 = transferUtility1
                .upload(bucketName, awsPath, new File(filePath), CannedAccessControlList.PublicRead);
        Log.d(TAG + " bucketName" ," bucketName 1 "+ bucketName);
        Log.d(TAG + " awsPath" , "awsPath 2 "+ awsPath);
        Log.d(TAG + " filePath" , "filePath 3 "+ filePath);
        transferObserver1.setTransferListener(new Transfer());
    }


    class TestAsync extends AsyncTask<Void, Integer, String> {
        String TAG = getClass().getSimpleName();

        protected void onPreExecute() {
            super.onPreExecute();
            Log.d(TAG + " PreExceute","On pre Exceute......");
        }

        protected String doInBackground(Void...arg0) {
            s3client.deleteObject(bucketName, filePath);

            return "You are at PostExecute";
        }

        protected void onProgressUpdate(Integer...a) {
            super.onProgressUpdate(a);
            Log.d(TAG + " onProgressUpdate", "You are in progress update ... " + a[0]);
        }

        protected void onPostExecute(String result) {
            super.onPostExecute(result);
            parentResult.success(true);
            Log.d(TAG + " onPostExecute", "" + result);
        }
    }

    private void delete() {
        try {
            
            
            new TestAsync().execute();

//            Handler mainHandler = new Handler(mContext.getMainLooper());
//
//            Runnable myRunnable = new Runnable() {
//                @Override
//                public void run() {
//                    s3client.deleteObject(bucketName, filePath);
//                    parentResult.success(true);
//                    Log.d(TAG, "progressChanged: \"delete, ");
//                }
//            };
//            mainHandler.post(myRunnable);

           /* new Thread() {
                public void run() {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            s3client.deleteObject(bucketName, filePath);
                            parentResult.success(true);
                            Log.d(TAG, "progressChanged: \"delete, ");
                        }
                    });
                }
            }.start();*/


//            Thread thread = new Thread() {
//                @Override
//                public void run() {
//
//                }
//            };
//            thread.start();
        } catch (Exception e) {
            Log.d(TAG, "progressChanged: \"Exception, " + e);
            parentResult.success(false);
        }
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.events = events;
    }

//    private void uploadMultipleFile(MethodCall call) {
//        ArrayList<String> filePaths = call.argument("filePaths");
//
//        Log.d(TAG, "onMethodCall: " + filePaths);
//
//        awsFolder = call.argument("awsFolder");
//        String[] fileNamesWithExt = call.argument("fileNamesWithExt");
//        String poolId = call.argument("poolId");
//        String reg = call.argument("region");
//        bucketName = call.argument("bucketName");
//        String awsPath = fileNameWithExt;
//        if (awsFolder != null && !awsFolder.equals("")) {
//            awsPath = awsFolder + "/" + fileNameWithExt;
//        }
//        CognitoCredentialsProvider credentialsProvider = new CognitoCredentialsProvider(poolId, region, clientConfiguration);
//        TransferManager tm = new TransferManager(credentialsProvider);
//
//        ObjectMetadataProvider metadataProvider = new ObjectMetadataProvider() {
//
//            @Override
//            public void provideObjectMetadata(File file, ObjectMetadata metadata) {
//                // If this file is a JPEG, then parse some additional info
//                // from the EXIF metadata to store in the object metadata
////                if (isJPEG(file)) {
////                    metadata.addUserMetadata("original-image-date",
////                            parseExifImageDate(file));
////                }
//            }
//        };
//
//        ArrayList<File> files = new ArrayList<>();
//        for (String path : filePaths) {
//            files.add(new File(path));
//        }
//        MultipleFileUpload multipleFileUpload = tm
//                .uploadFileList(bucketName, awsPath, null, files, metadataProvider);
//    }

    @Override
    public void onCancel(Object arguments) {
        invalidateEventSink();
    }

    private void invalidateEventSink() {
        if (events != null) {
            events.endOfStream();
            events = null;
        }
    }

//    class Progress implements ProgressListener {
//
//        @Override
//        public void progressChanged(ProgressEvent progressEvent) {
////            Log.d(TAG,"progressChanged: WAITING, " + progressEvent);
//
//        }
//    }

    class Transfer implements TransferListener {

        private static final String TAG = "Transfer";

        @Override
        public void onStateChanged(int id, TransferState state) {
            switch (state) {
                case COMPLETED:
                    Log.d(TAG, "onStateChanged: \"COMPLETED, " + fileNameWithExt);
                    parentResult.success(fileNameWithExt);
                    break;
                case WAITING:
                    Log.d(TAG, "onStateChanged: \"WAITING, " + fileNameWithExt);
                    break;
                case FAILED:
                    invalidateEventSink();
                    Log.d(TAG, "onStateChanged: \"FAILED, " + fileNameWithExt);
                    parentResult.success(null);
                    break;
                default:
                    Log.d(TAG, "onStateChanged: \"SOMETHING ELSE, " + fileNameWithExt);
                    break;
            }
        }

        @Override
        public void onProgressChanged(int id, long bytesCurrent, long bytesTotal) {

            float percentDoNef = ((float) bytesCurrent / (float) bytesTotal) * 100;
            int percentDone = (int) percentDoNef;
            Log.d(TAG, "ID:" + id + " bytesCurrent: " + bytesCurrent + " bytesTotal: " + bytesTotal + " " + percentDone + "%");

            if (events != null) {
                events.success(percentDone);
            }
        }

        @Override
        public void onError(int id, Exception ex) {
            Log.e(TAG, "onError: " + ex);
            invalidateEventSink();
        }
    }
}
