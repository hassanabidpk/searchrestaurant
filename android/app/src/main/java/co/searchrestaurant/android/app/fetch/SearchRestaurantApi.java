package co.searchrestaurant.android.app.fetch;

import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Query;

/**
 * Created by hassanabid on 2/27/16.
 */
public interface SearchRestaurantApi {

    @GET("api/v1/")
    Call<SearchRestaurantResponse[]> getRestaurantsList(@Query("format") String format, @Query("location") String location,
                                               @Query("rtype") String rtype);


}
