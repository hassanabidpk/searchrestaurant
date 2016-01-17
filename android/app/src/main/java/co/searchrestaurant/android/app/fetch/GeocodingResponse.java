package co.searchrestaurant.android.app.fetch;

import java.util.List;

/**
 * Created by hassanabid on 1/17/16.
 */
public class GeocodingResponse {

    public String status;
    public List<Result> results;

    public class Result {
        public Geometry geometry;
        public String formatted_address;

    }

    public class Geometry {
        public Location location;
    }

    public class Location {
        public double lat;
        public double lng;
    }


}
