package co.searchrestaurant.android.app;

import android.app.Activity;
import android.support.design.widget.CollapsingToolbarLayout;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;

import co.searchrestaurant.android.app.dummy.DummyContent;
import co.searchrestaurant.android.app.fetch.SearchRestaurantResponse;

/**
 * A fragment representing a single restaurant detail screen.
 * This fragment is either contained in a {@link RestaurantListActivity}
 * in two-pane mode (on tablets) or a {@link RestaurantDetailActivity}
 * on handsets.
 */
public class RestaurantDetailFragment extends Fragment {
    /**
     * The fragment argument representing the item ID that this fragment
     * represents.
     */
    public static final String ARG_CHECKINS = "checkins";
    public static final String ARG_NAME = "rest_name";
    public static final String ARG_PHOTO_URL = "photo_url";
    public static final String ARG_ADDRESS = "address";
    public static final String ARG_CREATED_AT = "created_at";
    public static final String ARG_PHONE_NUMBER = "phone_number";



    /**
     * The dummy content this fragment is presenting.
     */
    private String checkins;
    private String photo_url;
    private String rest_name;
    private String address;
    private String create_at;
    private String phone_number;


    /**
     * Mandatory empty constructor for the fragment manager to instantiate the
     * fragment (e.g. upon screen orientation changes).
     */
    public RestaurantDetailFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (getArguments().containsKey(ARG_CHECKINS)) {
            // Load the dummy content specified by the fragment
            // arguments. In a real-world scenario, use a Loader
            // to load content from a content provider.
            checkins = getArguments().getString(ARG_CHECKINS);
            rest_name = getArguments().getString(ARG_NAME);
            address = getArguments().getString(ARG_ADDRESS);
            phone_number = getArguments().getString(ARG_PHONE_NUMBER);
            photo_url = getArguments().getString(ARG_PHOTO_URL);
            create_at = getArguments().getString(ARG_CREATED_AT);


            Activity activity = this.getActivity();
            CollapsingToolbarLayout appBarLayout = (CollapsingToolbarLayout) activity.findViewById(R.id.toolbar_layout);
            if (appBarLayout != null) {
                appBarLayout.setTitle(rest_name);
            }
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.restaurant_detail, container, false);

        if (address != null) {
            ((TextView) rootView.findViewById(R.id.restaurant_detail)).setText(address);
        }
        if (photo_url != null) {
            loadBackdrop(photo_url,rootView);
        }

        return rootView;
    }

    private void loadBackdrop(String photo_url, View root) {
        final ImageView imageView = (ImageView) getActivity().findViewById(R.id.rest_image);
        Glide.with(getActivity()).load(photo_url).centerCrop().into(imageView);
    }
}
