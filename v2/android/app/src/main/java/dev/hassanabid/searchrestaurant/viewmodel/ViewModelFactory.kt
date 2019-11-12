package dev.hassanabid.searchrestaurant.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import dev.hassanabid.searchrestaurant.data.SearchRepository

@Suppress("UNCHECKED_CAST")
class ViewModelFactory constructor(
    private val searchRepository: SearchRepository
) : ViewModelProvider.NewInstanceFactory() {


    override fun <T : ViewModel> create(modelClass: Class<T>) =
        with(modelClass) {
            when {
                isAssignableFrom(RestaurantViewModel::class.java) ->
                    RestaurantViewModel(searchRepository)
                else ->
                    throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
            }
        } as T
}