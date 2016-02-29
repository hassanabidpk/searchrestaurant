### Search Restaurant API Guide
----

##### Common Endpoints 

- Get list of all restaurants: `/api/v1/`
- Get list of restaurants for particular location and type: `/api/v1/` with params `location` and `rtype`
- Sample Request:  `https://searchrestaurant.pythonanywhere.com/api/v1/?format=json&location=oslo&rtype=pizza`

##### Response Values

- In case of error you will get an `error` key with a `status` code
- You will get an array of dicts eaching containing information about place(restaurant,coffee shop etc.) 

| Name          | Type        | Definition     |
| :-----------: |:-----------------------------:|:---------------------------------------------------------:|
| name          | string                        | Name of the restaurant                                    |
| latitude      | string (convert to double)    | Latitude of the restaurant location                       |
| longitude     | string (convert to double)    | Longitude of the restaurant location                      |
| address       | string                        | Local address of the restaurant                           |
| checkins      | number                        | number of checkins at this restaurant                     |
| photo_url     | string                        | A 300x200 image of the restaurant                         |
| phone_number  | string                        | Phone number of the restaurant if available otherwise N/A |
| created_at    | string (convert to datetime)  | A datetime string when this object was created            |
| updated_at    | string (convert to datetime)  | A datetime string when this object was updated            |

