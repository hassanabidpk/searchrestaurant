package dev.hassanabid.searchrestaurant.service.response

import com.google.gson.annotations.SerializedName

data class SearchRestaurantResponse (

    @SerializedName("status")
    val status: String = "",

    @SerializedName("name")
    val name: String = "",

    @SerializedName("address")
    val address: String? = "",

    @SerializedName("checkins")
    val checkins: Int = 0,

    @SerializedName("latitude")
    val latitude: String = "",

    @SerializedName("longitude")
    val longitude: String = "",

    @SerializedName("photo_url")
    val photo_url: String = "",

    @SerializedName("venue_id")
    val venue_id: String = "",

    @SerializedName("phone_number")
    val phone_number: String = "",

    @SerializedName("created_at")
    val created_at: String = "",

    @SerializedName("updated_at")
    val updated_at: String = ""


)