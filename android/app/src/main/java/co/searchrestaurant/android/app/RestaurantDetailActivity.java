package co.searchrestaurant.android.app;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Messenger;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationManagerCompat;
import android.support.v4.app.RemoteInput;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.app.ActionBar;
import android.support.v4.app.NavUtils;
import android.view.MenuItem;

import java.util.Locale;

/**
 * An activity representing a single restaurant detail screen. This
 * activity is only used narrow width devices. On tablet-size devices,
 * item details are presented side-by-side with a list of items
 * in a {@link RestaurantListActivity}.
 */
public class RestaurantDetailActivity extends AppCompatActivity {

    private static final String LOG_TAG = RestaurantDetailActivity.class.getSimpleName();

   //1 - Create instance of RemoteInput.Builder that can add to your notification action

    private static final String TEXT_REPLY_KEY = "text_reply_key";

    private PendingIntent replyPendingIntent;
    private static final int REQUEST_CODE_REPLY = 3232;
    private static final String ACTION_REPLY_RECEIVE = "co.searchrestaurant.android.app.reply_rx";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_restaurant_detail);
        Toolbar toolbar = (Toolbar) findViewById(R.id.detail_toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
               // Reply Notification
                createReplyNotification();

            }
        });

        // Show the Up button in the action bar.
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
        }

        if (savedInstanceState == null) {
            // Create the detail fragment and add it to the activity
            // using a fragment transaction.
            Bundle arguments = new Bundle();
            arguments.putString(RestaurantDetailFragment.ARG_CHECKINS,
                    String.valueOf(getIntent().getIntExtra(RestaurantDetailFragment.ARG_CHECKINS,0)));
            arguments.putString(RestaurantDetailFragment.ARG_NAME,
                    getIntent().getStringExtra(RestaurantDetailFragment.ARG_NAME));
            arguments.putString(RestaurantDetailFragment.ARG_ADDRESS,
                    getIntent().getStringExtra(RestaurantDetailFragment.ARG_ADDRESS));
            arguments.putString(RestaurantDetailFragment.ARG_PHOTO_URL,
                    getIntent().getStringExtra(RestaurantDetailFragment.ARG_PHOTO_URL));
            arguments.putString(RestaurantDetailFragment.ARG_PHONE_NUMBER,
                    getIntent().getStringExtra(RestaurantDetailFragment.ARG_PHONE_NUMBER));
            arguments.putString(RestaurantDetailFragment.ARG_CREATED_AT,
                    getIntent().getStringExtra(RestaurantDetailFragment.ARG_CREATED_AT));
            RestaurantDetailFragment fragment = new RestaurantDetailFragment();
            fragment.setArguments(arguments);
            getSupportFragmentManager().beginTransaction()
                    .add(R.id.restaurant_detail_container, fragment)
                    .commit();
        }
    }

    private void createReplyNotification() {

        String replyLabel = getResources().getString(R.string.reply);

        android.app.RemoteInput remoteInput = new android.app.RemoteInput.Builder(TEXT_REPLY_KEY)
                .setLabel(replyLabel)
                .build();

        // 2: Attach remote input to Notification Action
        Intent replyIntent = new Intent(ACTION_REPLY_RECEIVE);
        replyPendingIntent = PendingIntent.getBroadcast(this,REQUEST_CODE_REPLY,replyIntent,0);

        Notification.Action action = new Notification.Action.Builder(R.drawable.ic_reply_black_24dp,
                getString(R.string.reply),replyPendingIntent)
                .addRemoteInput(remoteInput)
                .build();

        //3: Build Notification and add action

        Bitmap icon = BitmapFactory.decodeResource(getResources(),
                R.drawable.ic_face_black_48dp);

        // Build the notification and add the action
        Notification notification =
                new Notification.Builder(this)
                        .setSmallIcon(R.drawable.ic_restaurant_black_24dp)
                        .setContentTitle(getString(R.string.title))
                        .setContentText(getString(R.string.content))
                        .setLargeIcon(icon)
                        .addAction(action).build();

// Issue the notification
        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Service.NOTIFICATION_SERVICE);
        notificationManager.notify(1, notification);

    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == android.R.id.home) {
            // This ID represents the Home or Up button. In the case of this
            // activity, the Up button is shown. Use NavUtils to allow users
            // to navigate up one level in the application structure. For
            // more details, see the Navigation pattern on Android Design:
            //
            // http://developer.android.com/design/patterns/navigation.html#up-vs-back
            //
            NavUtils.navigateUpTo(this, new Intent(this, RestaurantListActivity.class));
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onMultiWindowChanged(boolean inMultiWindow) {
        super.onMultiWindowChanged(inMultiWindow);

        Log.d(LOG_TAG, "onMultiWindowChanged: " + inMultiWindow);
    }
}
