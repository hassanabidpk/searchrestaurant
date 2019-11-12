package dev.hassanabid.searchrestaurant.service.response

class GeocodingResponse {

    var status: String = ""
    var results: List<Result> = emptyList()

    inner class Result {
        var geometry: Geometry? = null
        var formatted_address: String = ""

    }

    inner class Geometry {
        var location: Location? = null
    }

    inner class Location {
        var lat: Double = 0.toDouble()
        var lng: Double = 0.toDouble()
    }


}