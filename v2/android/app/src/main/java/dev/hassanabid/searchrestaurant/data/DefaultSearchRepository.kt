package dev.hassanabid.searchrestaurant.data

import dev.hassanabid.searchrestaurant.service.RetrofitClient
import dev.hassanabid.searchrestaurant.service.SearchRestaurantApi
import dev.hassanabid.searchrestaurant.service.response.SearchRestaurantResponse
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class DefaultSearchRepository (
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO
): SearchRepository {

    var client: SearchRestaurantApi = RetrofitClient.webservice

    override suspend fun getRestaurantsList(
        format: String,
        location: String,
        rtype: String
    ): List<SearchRestaurantResponse> {

        return withContext(ioDispatcher) {


            return@withContext client.getRestaurantsList(format, location, rtype)
        }
    }

}
