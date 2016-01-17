package co.searchrestaurant.android.app.fetch;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.http.GET;
import retrofit2.http.Query;

/**
 * Created by hassanabid on 1/17/16.
 */
public interface GeocodingApi {

    @GET("maps/api/geocode/json")
    Call<GeocodingResponse> getLatLng(@Query("address") String address, @Query("key") String key);


}
