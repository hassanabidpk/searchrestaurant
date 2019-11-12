package dev.hassanabid.searchrestaurant

import android.content.Context
import androidx.annotation.VisibleForTesting
import dev.hassanabid.searchrestaurant.data.DefaultSearchRepository
import dev.hassanabid.searchrestaurant.data.SearchRepository

object ServiceLocator {

    private val lock = Any()
    @Volatile
    var searchRepository: SearchRepository? = null
        @VisibleForTesting set

    fun provideSearchRepository(context: Context): SearchRepository {
        synchronized(this) {
            return searchRepository ?: searchRepository ?: createSearchRepository(context)
        }
    }

    private fun createSearchRepository(context: Context): SearchRepository {
        return DefaultSearchRepository()
    }
}