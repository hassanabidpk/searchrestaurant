package dev.hassanabid.searchrestaurant.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.liveData
import dev.hassanabid.searchrestaurant.data.SearchRepository
import kotlinx.coroutines.Dispatchers

class RestaurantViewModel(
    private val searchRepository: SearchRepository
): ViewModel() {


    fun restList(location: String, rtype: String) = liveData(Dispatchers.IO) {
        val fetchedList = searchRepository.getRestaurantsList("json",location, rtype)

        try {
            emit(Result.success(fetchedList))
        } catch (ioException: Exception) {
            emit(Result.failure(ioException))
        }
    }



}