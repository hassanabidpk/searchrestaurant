package co.searchrestaurant.android.app.activities;

import android.content.res.Configuration;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.support.annotation.ColorRes;
import android.support.annotation.StringRes;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

/**
 * Created by hassanabid on 3/26/16.
 */
public class BaseActivity extends AppCompatActivity {

    protected String mLogTag = getClass().getSimpleName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(mLogTag, "onCreate");


    }

    @Override
    public void onPostCreate(Bundle savedInstanceState, PersistableBundle persistentState) {
        super.onPostCreate(savedInstanceState, persistentState);
        Log.d(mLogTag, "onPostCreate");
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.d(mLogTag, "onPause");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d(mLogTag, "onDestroy");
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(mLogTag, "onResume");
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        Log.d(mLogTag, "onConfigurationChanged: " + newConfig.toString());
    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
        Log.d(mLogTag, "onPostCreate");
    }

    @Override
    protected void onStart() {
        super.onStart();
        Log.d(mLogTag, "onStart");
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(mLogTag, "onStop");
    }

    @Override
    public void onMultiWindowChanged(boolean inMultiWindow) {
        super.onMultiWindowChanged(inMultiWindow);

        Log.d(mLogTag, "onMultiWindowChanged: " + inMultiWindow);
    }

    @Override
    public void onPictureInPictureChanged(boolean inPictureInPicture) {
        super.onPictureInPictureChanged(inPictureInPicture);

        Log.d(mLogTag, "onPictureInPictureChanged: " + inPictureInPicture);
    }
}
