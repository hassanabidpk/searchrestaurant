package dev.hassanabid.searchrestaurant.service

import com.google.gson.GsonBuilder
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory


class RetrofitClient {


    companion object {

        val webservice by lazy {
            Retrofit.Builder()
                .baseUrl("https://searchrestaurant.pythonanywhere.com/")
                .addConverterFactory(GsonConverterFactory.create(GsonBuilder().create()))
                .build().create(SearchRestaurantApi::class.java)
        }
    }

}
