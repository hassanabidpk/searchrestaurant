package dev.hassanabid.searchrestaurant.service

import dev.hassanabid.searchrestaurant.service.response.GeocodingResponse
import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Query

interface GeocodingApi {

    @GET("maps/api/geocode/json")
    suspend fun getLatLng(@Query("address") address: String, @Query("key") key: String): GeocodingResponse


}