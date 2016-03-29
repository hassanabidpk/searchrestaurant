package co.searchrestaurant.android.app.data;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by hassanabid on 3/29/16.
 */
public class RestaurantParcel implements Parcelable {

    public String name;
    public  String address;
    public int checkins;
    public String latitude;
    public String longitude;
    public String photo_url;
    public String venue_id;
    public String phone_number;
    public String update_at;
    public String created_at;

    public RestaurantParcel(String name,String address, int checkins,String latitude,String longitude,
                            String venue_id,String phone_number, String photo_url,String update_at,String created_at)
    {
        this.name = name;
        this.address = address;
        this.checkins = checkins;
        this.latitude = latitude;
        this.longitude = longitude;
        this.venue_id = venue_id;
        this.phone_number = phone_number;
        this.photo_url = photo_url;
        this.update_at = update_at;
        this.created_at = created_at;
    }

    private RestaurantParcel(Parcel in){
        name = in.readString();
        address = in.readString();
        checkins = in.readInt();
        latitude = in.readString();
        longitude = in.readString();
        venue_id = in.readString();
        phone_number = in.readString();
        photo_url = in.readString();
        update_at = in.readString();
        created_at = in.readString();
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public String toString() { return name; }

    @Override
    public void writeToParcel(Parcel parcel, int i) {
        parcel.writeString(name);
        parcel.writeString(address);
        parcel.writeInt(checkins);
        parcel.writeString(latitude);
        parcel.writeString(longitude);
        parcel.writeString(venue_id);
        parcel.writeString(phone_number);
        parcel.writeString(photo_url);
        parcel.writeString(update_at);
        parcel.writeString(created_at);
    }

    public final Creator<RestaurantParcel> CREATOR = new Creator<RestaurantParcel>() {
        @Override
        public RestaurantParcel createFromParcel(Parcel parcel) {
            return new RestaurantParcel(parcel);
        }

        @Override
        public RestaurantParcel[] newArray(int i) {
            return new RestaurantParcel[i];
        }

    };
}
