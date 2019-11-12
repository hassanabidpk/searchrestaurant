package dev.hassanabid.searchrestaurant

import android.app.AlertDialog
import android.content.DialogInterface
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.view.*
import com.google.android.material.snackbar.Snackbar
import androidx.appcompat.app.AppCompatActivity
import android.widget.EditText
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.TextView
import androidx.annotation.NonNull
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelProviders
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import dev.hassanabid.searchrestaurant.service.response.SearchRestaurantResponse
import dev.hassanabid.searchrestaurant.viewmodel.RestaurantViewModel
import dev.hassanabid.searchrestaurant.viewmodel.ViewModelFactory

import kotlinx.android.synthetic.main.activity_main.*
import java.util.*

class MainActivity : AppCompatActivity() {

    lateinit var viewModel: RestaurantViewModel
    private var restaurants: List<SearchRestaurantResponse>? = null
    private var recyclerView: View? = null
    private var progessBar: ProgressBar? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        setSupportActionBar(toolbar)

        progessBar = findViewById(R.id.progressBar)
        recyclerView = findViewById(R.id.restaurant_list)

        fab.setOnClickListener { view ->

            searchDialog = createSearchDialog()
            searchDialog?.show()
        }

        val repository = (applicationContext as MainApplication).searchRepository
        viewModel = ViewModelProvider(this, ViewModelFactory(repository)).get(RestaurantViewModel::class.java)
        fetchRestList()

    }

    fun fetchRestList() {

        progessBar?.visibility = View.VISIBLE
        viewModel.restList(newPlace, newType).observe(this, Observer {

            it.onSuccess {
                restaurants = it
                setupRecyclerView(recyclerView as RecyclerView)
                Log.d("Restaurant", it.toString())
                progessBar?.visibility = View.GONE
                if(it.isEmpty()) {
                    Snackbar.make(
                        recyclerView!!,
                        "Nothing found!",
                        Snackbar.LENGTH_LONG
                    )
                        .setAction("OK", null).show()
                }
            }

        })
    }



    private fun setupRecyclerView(@NonNull recyclerView: RecyclerView) {
        recyclerView.setAdapter(SimpleItemRecyclerViewAdapter(restaurants!!))
    }

    inner class SimpleItemRecyclerViewAdapter(private val mValues: List<SearchRestaurantResponse>) :
        RecyclerView.Adapter<SimpleItemRecyclerViewAdapter.ViewHolder>() {

        override fun getItemCount(): Int {
            return mValues.size
        }


        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.restaurant_list_content, parent, false)
            return ViewHolder(view)
        }

        override fun onBindViewHolder(holder: ViewHolder, position: Int) {

            holder.mItem = mValues[position]
            holder.mIdView.text = "Checkins : ${mValues[position].checkins}"
            holder.mContentView.text = mValues[position].name
            Glide.with(holder.mContentView.context)
                .load(mValues[position].photo_url)
                .centerCrop()
                .into(holder.mRestImageView)

            holder.mView.setOnClickListener { v ->
                // TODO
            }
        }

        inner class ViewHolder(val mView: View) : RecyclerView.ViewHolder(mView) {
            val mIdView: TextView
            val mContentView: TextView
            var mItem: SearchRestaurantResponse? = null
            val mRestImageView: ImageView

            init {
                mIdView = mView.findViewById(R.id.id) as TextView
                mContentView = mView.findViewById(R.id.content) as TextView
                mRestImageView = mView.findViewById(R.id.rest_image_main) as ImageView
            }

            override fun toString(): String {
                return super.toString() + " '" + mContentView.text + "'"
            }
        }
    }

    private var searchDialog: AlertDialog? = null
    private var newPlace = "cebu"
    private var newType = "pizza"
    private val inputTag: EditText? = null
    private fun createSearchDialog(): AlertDialog {

        val builder = AlertDialog.Builder(this)
        val inflater = layoutInflater
        val dialogRootView = inflater.inflate(R.layout.dialog_search, null)
        val placeEditView = dialogRootView.findViewById(R.id.place_name) as EditText
        val rTypeEditView = dialogRootView.findViewById(R.id.restaurant_type) as EditText

        // Inflate and set the layout for the dialog
        // Pass null as the parent view because its going in the dialog layout
        builder.setView(dialogRootView)
            // Add action buttons
            .setPositiveButton("Submit",
                DialogInterface.OnClickListener { dialog, id ->
                    val value = placeEditView.text
                    val type = rTypeEditView.text
                    newPlace = value.toString()
                    newType = type.toString()
                    if (!TextUtils.isEmpty(newPlace) && !TextUtils.isEmpty(newType)) {

                        fetchRestList()

                    } else {

                        Snackbar.make(
                            recyclerView!!,
                            "Try again with correct parameters!",
                            Snackbar.LENGTH_LONG
                        )
                            .setAction("OK", null).show()
                    }
                })
            .setNegativeButton("Cancel",
                DialogInterface.OnClickListener { dialog, id -> dialog.cancel() })


        return builder.create()
    }
}
