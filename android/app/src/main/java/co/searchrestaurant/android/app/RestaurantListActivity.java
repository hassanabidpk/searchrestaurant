package co.searchrestaurant.android.app;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
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

import co.searchrestaurant.android.app.fetch.SearchRestaurantApi;
import co.searchrestaurant.android.app.fetch.SearchRestaurantResponse;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.GsonConverterFactory;
import retrofit2.Response;
import retrofit2.Retrofit;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;

/**
 * An activity representing a list of restaurants. This activity
 * has different presentations for handset and tablet-size devices. On
 * handsets, the activity presents a list of items, which when touched,
 * lead to a {@link RestaurantDetailActivity} representing
 * item details. On tablets, the activity presents the list of items and
 * item details side-by-side using two vertical panes.
 */
public class RestaurantListActivity extends AppCompatActivity {

    private static final String LOG_TAG = RestaurantListActivity.class.getSimpleName();
    private static final String API_BASE_URL = "https://searchrestaurant.pythonanywhere.com";

    private boolean mTwoPane;
    private List<SearchRestaurantResponse> restaurants;
    private View recyclerView;
    private ProgressBar progessBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_restaurant_list);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        toolbar.setTitle(getTitle());

        progessBar = (ProgressBar) findViewById(R.id.progressBar);
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
                    setupRecyclerView((RecyclerView) recyclerView);
                    progessBar.setVisibility(View.GONE);

                } else {
                    progessBar.setVisibility(View.GONE);
                    Log.d(LOG_TAG, "failure response is " + response.raw().toString());

                }
            }

            @Override
            public void onFailure(Throwable t) {
                Log.d(LOG_TAG, " Error :  " + t.getMessage());
            }
        });

    }

    private void setupRecyclerView(@NonNull RecyclerView recyclerView) {
        recyclerView.setAdapter(new SimpleItemRecyclerViewAdapter(restaurants));
    }

    public class SimpleItemRecyclerViewAdapter
            extends RecyclerView.Adapter<SimpleItemRecyclerViewAdapter.ViewHolder> {

        private final List<SearchRestaurantResponse> mValues;

        public SimpleItemRecyclerViewAdapter(List<SearchRestaurantResponse> items) {
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
            public SearchRestaurantResponse mItem;
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

        // Inflate and set the layout for the dialog
        // Pass null as the parent view because its going in the dialog layout
        builder.setView(dialogRootView)
                // Add action buttons
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
}
