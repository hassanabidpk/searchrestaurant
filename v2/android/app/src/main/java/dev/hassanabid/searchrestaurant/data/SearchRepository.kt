package dev.hassanabid.searchrestaurant.data

import dev.hassanabid.searchrestaurant.service.response.SearchRestaurantResponse

interface SearchRepository {

    suspend fun getRestaurantsList(format: String, location: String, rtype: String): List<SearchRestaurantResponse>
}