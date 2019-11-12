package dev.hassanabid.searchrestaurant.service

import dev.hassanabid.searchrestaurant.service.response.SearchRestaurantResponse
import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Query


/**
 * Fetch all the nearby restaurants using Foursquare and GeoCoding Api
 */

interface SearchRestaurantApi {

    @GET("api/v1/")
    suspend fun getRestaurantsList(
        @Query("format") format: String, @Query("location") location: String,
        @Query("rtype") rtype: String
    ): List<SearchRestaurantResponse>

}