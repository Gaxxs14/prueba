package com.example.mi_app;

import io.flutter.embedding.android.FlutterActivity;
import android.content.BroadcastReceiver;
import android.content.IntentFilter;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;
import android.os.Bundle;
import android.os.Build;
import android.util.Log;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // intent declaration
        IntentFilter filter = new IntentFilter();
        filter.addCategory(Intent.CATEGORY_DEFAULT);
        filter.addAction(getResources().getString(R.string.activity_intent));
        // check OS version
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(myBroadcastReceiver, filter, Context.RECEIVER_EXPORTED);
        } else {
            registerReceiver(myBroadcastReceiver, filter);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(myBroadcastReceiver);
    }

    private BroadcastReceiver myBroadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            Bundle b = intent.getExtras();
            // bundle contains the barcode scan result
            if (action.equals(getResources().getString(R.string.activity_intent))) {
                //  Received a barcode scan
                try {
                    displayScanResult(intent, "via Broadcast");
                } catch (Exception e) {
                    Log.d("ChocoZebra", "Error occurred" + e.getMessage());
                }
            }
        }
    }; 

    private void displayScanResult(Intent initiatingIntent, String howDataReceived) {
        // content
        String content = initiatingIntent.getStringExtra(getResources().getString(R.string.datawedge_data));
        // display the content in a toast
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.d("ChocoZebra", "Scan received: " + content);
            }
        });
    }
}
