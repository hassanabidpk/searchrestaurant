package dev.hassanabid.searchrestaurant

import android.app.Application
import dev.hassanabid.searchrestaurant.data.SearchRepository

class MainApplication: Application() {

    val searchRepository: SearchRepository
        get() = ServiceLocator.provideSearchRepository(this)

    override fun onCreate() {
        super.onCreate()
    }
}