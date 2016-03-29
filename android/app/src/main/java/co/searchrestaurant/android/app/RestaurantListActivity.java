package co.searchrestaurant.android.app;

import android.app.AlertDialog;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.service.notification.StatusBarNotification;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.app.NotificationCompat;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.text.Editable;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;


import com.bumptech.glide.Glide;

import co.searchrestaurant.android.app.activities.BaseActivity;
import co.searchrestaurant.android.app.data.RestaurantParcel;
import co.searchrestaurant.android.app.fetch.SearchRestaurantApi;
import co.searchrestaurant.android.app.fetch.SearchRestaurantResponse;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.GsonConverterFactory;
import retrofit2.Response;
import retrofit2.Retrofit;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ExecutionException;

/**
 * An activity representing a list of restaurants. This activity
 * has different presentations for handset and tablet-size devices. On
 * handsets, the activity presents a list of items, which when touched,
 * lead to a {@link RestaurantDetailActivity} representing
 * item details. On tablets, the activity presents the list of items and
 * item details side-by-side using two vertical panes.
 */
public class RestaurantListActivity extends BaseActivity {

    private static final String LOG_TAG = RestaurantListActivity.class.getSimpleName();
    private static final String RESTAURANTS_DB_KEY = "rest_db_key";
    private static final String API_BASE_URL = "https://searchrestaurant.pythonanywhere.com";

    private boolean mTwoPane;
    private List<SearchRestaurantResponse> restaurants;
    private View recyclerView;
    private ProgressBar progessBar;
    private TextView emptyView;
    private ArrayList<RestaurantParcel> restList;
    RestaurantParcel[] rests;

    /*
    Active Notification
    */
    private static final int REQUEST_CODE = 2323;
    private static final String NOTIFICATION_GROUP =
            "co.searchrestaurant.android.app.notification_type";

    private static final int NOTIFICATION_GROUP_SUMMARY_ID = 1;

    private static final String ACTION_NOTIFICATION_DELETE = "co.searchrestaurant.android.app.notification_delete";

    private NotificationManager mNotificationManager;
    private PendingIntent mDeletePendingIntent;

    private static int sNotificationId = NOTIFICATION_GROUP_SUMMARY_ID + 1;

    private BroadcastReceiver mDeleteReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
                updateNumberOfNotifications();
        }
    };


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_restaurant_list);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        toolbar.setTitle(getTitle());

        progessBar = (ProgressBar) findViewById(R.id.progressBar);
        emptyView = (TextView) findViewById(R.id.emptyTextView);
        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                searchDialog = createSearchDialog();
                searchDialog.show();
            }
        });
        recyclerView = findViewById(R.id.restaurant_list);
        assert recyclerView != null;

        if (findViewById(R.id.restaurant_detail_container) != null) {
            mTwoPane = true;
        }

        if(restaurants == null)
            emptyView.setVisibility(View.VISIBLE);

        mNotificationManager = (NotificationManager) getSystemService(Service.NOTIFICATION_SERVICE);
        Intent deleteIntent = new Intent(ACTION_NOTIFICATION_DELETE);
        mDeletePendingIntent = PendingIntent.getBroadcast(this,REQUEST_CODE,deleteIntent,0);

        if(savedInstanceState != null && savedInstanceState.containsKey(RESTAURANTS_DB_KEY)) {

            restList = savedInstanceState.getParcelableArrayList(RESTAURANTS_DB_KEY);
            Log.d(LOG_TAG,"retrieved rests from saveInstance : " + restList.size());
            setupRecyclerView((RecyclerView) recyclerView);

        } else {

            Log.d(LOG_TAG,"savedInstanceState is Null");

        }

    }

    private void initiateRestaurantApi(String place, String query,final View recyclerView) {

        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(API_BASE_URL)
                .addConverterFactory(GsonConverterFactory.create())
                .build();
        SearchRestaurantApi api = retrofit.create(SearchRestaurantApi.class);
        Call<SearchRestaurantResponse[]> call = api.getRestaurantsList("json",place,query);
        progessBar.setVisibility(View.VISIBLE);
        call.enqueue(new Callback<SearchRestaurantResponse[]>() {
            @Override
            public void onResponse(Response<SearchRestaurantResponse[]> response) {
                if(response.isSuccess()) {
                    Log.d(LOG_TAG, "success - response is " + response.body());
                    restaurants = Arrays.asList(response.body());
                    saveData(restaurants);
                    setupRecyclerView((RecyclerView) recyclerView);
                    createNotificationAndUpdateSummary(restaurants.size());
                    progessBar.setVisibility(View.GONE);

                } else {
                    progessBar.setVisibility(View.GONE);
                    Log.d(LOG_TAG, "failure response is " + response.raw().toString());
                    emptyView.setVisibility(View.VISIBLE);
                    emptyView.setText(getString(R.string.no_restaurant_found));
                    createNotificationAndUpdateSummary(0);
                }
            }

            @Override
            public void onFailure(Throwable t) {
                Log.d(LOG_TAG, " Error :  " + t.getMessage());
            }
        });

    }

    private void setupRecyclerView(@NonNull RecyclerView recyclerView) {
        if(restList.size() != 0 && restList != null) {
            emptyView.setVisibility(View.GONE);
        } else {
            emptyView.setVisibility(View.VISIBLE);
            emptyView.setText(getString(R.string.no_restaurant_found));
        }
        recyclerView.setAdapter(new SimpleItemRecyclerViewAdapter(restList));

    }

    public class SimpleItemRecyclerViewAdapter
            extends RecyclerView.Adapter<SimpleItemRecyclerViewAdapter.ViewHolder> {

        private final List<RestaurantParcel> mValues;

        public SimpleItemRecyclerViewAdapter(List<RestaurantParcel> items) {
            mValues = items;
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.restaurant_list_content, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(final ViewHolder holder, int position) {
            holder.mItem = mValues.get(position);
            holder.mIdView.setText(String.format(Locale.US,"Checkins : %s",
                    String.valueOf(mValues.get(position).checkins)));
            holder.mContentView.setText(mValues.get(position).name);
            Glide.with(holder.mContentView.getContext())
                    .load(mValues.get(position).photo_url)
                    .centerCrop()
                    .into(holder.mRestImageView);

            holder.mView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mTwoPane) {
                        Bundle arguments = new Bundle();
                        arguments.putString(RestaurantDetailFragment.ARG_CHECKINS,
                                String.valueOf(holder.mItem.checkins));
                        arguments.putString(RestaurantDetailFragment.ARG_NAME,
                                String.valueOf(holder.mItem.name));
                        arguments.putString(RestaurantDetailFragment.ARG_ADDRESS,
                                String.valueOf(holder.mItem.address));
                        arguments.putString(RestaurantDetailFragment.ARG_PHOTO_URL,
                                String.valueOf(holder.mItem.photo_url));
                        arguments.putString(RestaurantDetailFragment.ARG_CREATED_AT,
                                String.valueOf(holder.mItem.created_at));
                        arguments.putString(RestaurantDetailFragment.ARG_PHONE_NUMBER,
                                String.valueOf(holder.mItem.phone_number));
                        RestaurantDetailFragment fragment = new RestaurantDetailFragment();
                        fragment.setArguments(arguments);
                        getSupportFragmentManager().beginTransaction()
                                .replace(R.id.restaurant_detail_container, fragment)
                                .commit();
                    } else {
                        Context context = v.getContext();
                        Intent intent = new Intent(context, RestaurantDetailActivity.class);
                        intent.putExtra(RestaurantDetailFragment.ARG_NAME, holder.mItem.name);
                        intent.putExtra(RestaurantDetailFragment.ARG_CHECKINS, holder.mItem.checkins);
                        intent.putExtra(RestaurantDetailFragment.ARG_ADDRESS, holder.mItem.address);
                        intent.putExtra(RestaurantDetailFragment.ARG_CREATED_AT, holder.mItem.created_at);
                        intent.putExtra(RestaurantDetailFragment.ARG_PHONE_NUMBER, holder.mItem.phone_number);
                        intent.putExtra(RestaurantDetailFragment.ARG_PHOTO_URL, holder.mItem.photo_url);

                       /*
                        * Start this activity adjacent to the focused activity (ie. this activity) if possible.
                        * Note that this flag is just a hint to the system and may be ignored. For example,
                        * if the activity is launched within the same task, it will be launched on top of the
                        * previous activity that started the Intent. That's why the Intent.FLAG_ACTIVITY_NEW_TASK
                        * flag is specified here in the intent - this will start the activity in a new task.
                       */
                        intent.addFlags(Intent.FLAG_ACTIVITY_LAUNCH_ADJACENT | Intent.FLAG_ACTIVITY_NEW_TASK);
                        context.startActivity(intent);
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            return mValues.size();
        }

        public class ViewHolder extends RecyclerView.ViewHolder {
            public final View mView;
            public final TextView mIdView;
            public final TextView mContentView;
            public RestaurantParcel mItem;
            public final ImageView mRestImageView;

            public ViewHolder(View view) {
                super(view);
                mView = view;
                mIdView = (TextView) view.findViewById(R.id.id);
                mContentView = (TextView) view.findViewById(R.id.content);
                mRestImageView = (ImageView) view.findViewById(R.id.rest_image_main);
            }

            @Override
            public String toString() {
                return super.toString() + " '" + mContentView.getText() + "'";
            }
        }
    }

    private AlertDialog searchDialog;
    private String newPlace = "";
    private String newType = "";
    private EditText inputTag;
    private AlertDialog createSearchDialog() {

        final AlertDialog.Builder builder = new AlertDialog.Builder(this);
        LayoutInflater inflater = getLayoutInflater();
        final View dialogRootView = inflater.inflate(R.layout.dialog_search, null);
        final EditText placeEditView = (EditText) dialogRootView.findViewById(R.id.place_name);
        final EditText rTypeEditView = (EditText) dialogRootView.findViewById(R.id.restaurant_type);

        builder.setView(dialogRootView)
                .setPositiveButton("Submit", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int id) {
                        Editable value = placeEditView.getText();
                        Editable type = rTypeEditView.getText();
                        newPlace = value.toString();
                        newType = type.toString();
                        if(!TextUtils.isEmpty(newPlace) && !TextUtils.isEmpty(newType)) {
                            initiateRestaurantApi(newPlace,newType,recyclerView);
                        } else {

                Snackbar.make(recyclerView, "Try again with correct parameters!", Snackbar.LENGTH_LONG)
                        .setAction("OK", null).show();
                        }
                    }
                })
                .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.cancel();
                    }
                });


        return builder.create();
    }

    private void saveData(List<SearchRestaurantResponse> restaurants) {
        rests = new RestaurantParcel[restaurants.size()];
        for (int i=0; i < restaurants.size(); i++) {
            SearchRestaurantResponse singleRest = restaurants.get(i);
            rests[i] = new RestaurantParcel(singleRest.name,singleRest.address,singleRest.checkins,
                    singleRest.latitude,singleRest.longitude,singleRest.venue_id,singleRest.phone_number,
                    singleRest.photo_url,singleRest.updated_at,singleRest.created_at);
        }
        restList = new ArrayList<RestaurantParcel>(Arrays.asList(rests));

    }


    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        if(restList != null) {
            Log.d(LOG_TAG, "onSaveInstance : " + restList.size());
            outState.putParcelableArrayList(RESTAURANTS_DB_KEY, restList);
        }
    }

    private void createNotificationAndUpdateSummary(int numRest) {

        Bitmap icon = BitmapFactory.decodeResource(getResources(),
                R.drawable.ic_local_pizza_black_48dp);

        final android.support.v4.app.NotificationCompat.Builder notificationBuilder = new
                NotificationCompat.Builder(this)
                .setSmallIcon(R.drawable.ic_restaurant_black_24dp)
                .setContentText(String.format(Locale.US,getResources().getString(R.string.restaurant_search_result),numRest))
                .setContentTitle(getResources().getString(R.string.restaurant_search_completed))
                .setDeleteIntent(mDeletePendingIntent)
                .setGroup(NOTIFICATION_GROUP)
                .setLargeIcon(icon)
                .setAutoCancel(true);

    /*if(restList.size() != 0) {
        try {
            Bitmap icon = Glide.
                    with(this).
                    load(restList.get(0).photo_url).
                    asBitmap().
                    into(100, 100). // Width and height
                    get();
            notificationBuilder.setLargeIcon(icon);
        } catch (final ExecutionException e) {
            Log.e(LOG_TAG, e.getMessage());
        } catch (final InterruptedException e) {
            Log.e(LOG_TAG, e.getMessage());
        }
    }*/
        final Notification noti = notificationBuilder.build();

        mNotificationManager.notify(getNewNotificationId(),noti);

        updateNotificationSummary();
        updateNumberOfNotifications();

    }

    /**
     * Retrieves a unique notification ID.
     */
    public int getNewNotificationId() {
        int notificationId = sNotificationId++;

        // Unlikely in the sample, but the int will overflow if used enough so we skip the summary
        // ID. Most apps will prefer a more deterministic way of identifying an ID such as hashing
        // the content of the notification.
        if (notificationId == NOTIFICATION_GROUP_SUMMARY_ID) {
            notificationId = sNotificationId++;
        }
        return notificationId;
    }

    /**
     * Adds/updates/removes the notification summary as necessary.
     */
    protected void updateNotificationSummary() {

        Bitmap icon = BitmapFactory.decodeResource(getResources(),
                R.drawable.ic_local_pizza_black_48dp);

        final StatusBarNotification[] activeNotifications = mNotificationManager
                .getActiveNotifications();

        int numberOfNotifications = activeNotifications.length;
        // Since the notifications might include a summary notification remove it from the count if
        // it is present.
        for (StatusBarNotification notification : activeNotifications) {
            if (notification.getId() == NOTIFICATION_GROUP_SUMMARY_ID) {
                numberOfNotifications--;
                break;
            }
        }

        if (numberOfNotifications > 1) {
            // Add/update the notification summary.
            String notificationContent = getString(R.string.restaurant_search_summary,
                    "" + numberOfNotifications);
            final android.support.v4.app.NotificationCompat.Builder builder = new android.support.v4.app.NotificationCompat.Builder(this)
                    .setSmallIcon(R.drawable.ic_restaurant_black_24dp)
                    .setLargeIcon(icon)
                    .setStyle(new android.support.v4.app.NotificationCompat.BigTextStyle()
                            .setSummaryText(notificationContent))
                    .setGroup(NOTIFICATION_GROUP)
                    .setGroupSummary(true);
            final Notification notification = builder.build();
            mNotificationManager.notify(NOTIFICATION_GROUP_SUMMARY_ID, notification);
        } else {
            // Remove the notification summary.
            mNotificationManager.cancel(NOTIFICATION_GROUP_SUMMARY_ID);
        }
    }

    /**
     * Requests the current number of notifications from the {@link NotificationManager} and
     * display them to the user.
     */
    protected void updateNumberOfNotifications() {
        // [BEGIN get_active_notifications]
        // Query the currently displayed notifications.
        final StatusBarNotification[] activeNotifications = mNotificationManager
                .getActiveNotifications();
        // [END get_active_notifications]
        final int numberOfNotifications = activeNotifications.length;
        Log.i(LOG_TAG, "activation notifications: " + numberOfNotifications);
    }

    @Override
    protected void onResume() {
        super.onResume();
        registerReceiver(mDeleteReceiver, new IntentFilter(ACTION_NOTIFICATION_DELETE));
    }

    @Override
    protected void onPause() {
        super.onPause();
        unregisterReceiver(mDeleteReceiver);
    }

    ConnectivityManager cm;

    private void tryNewConnectivityApi() {

        cm = (ConnectivityManager)  getSystemService(Context.CONNECTIVITY_SERVICE);
        if (cm.isActiveNetworkMetered()) {

            switch (cm.getRestrictBackgroundStatus()) {

                case ConnectivityManager.RESTRICT_BACKGROUND_STATUS_ENABLED:
                    /*Data Saver activated*/
                    break;
                case ConnectivityManager.RESTRICT_BACKGROUND_STATUS_WHITELISTED:
                    /* whitelisted - good to go */
                    break;
                case ConnectivityManager.RESTRICT_BACKGROUND_STATUS_DISABLED:
                    /* Data saver is off */
                    break;

            }

        }
    }


}
