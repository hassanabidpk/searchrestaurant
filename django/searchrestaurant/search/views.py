from django.shortcuts import render
from django.http import Http404
import requests
import random


GOOGLE_API_KEY = 'GOOGLE_API_KEY'
FOURSQUARE_CLIENT_ID = 'FOURSQUARE_CLIENT_ID'
FOURSQUARE_CLIENT_SECRET = 'FOURSQUARE_CLIENT_SECRET'


def getRandomRestaurant(location,query):
	result = {}
	# Get latitude and longitude
	google_payload = {'address': location, 'key': GOOGLE_API_KEY}
	rgoogle = requests.get("https://maps.googleapis.com/maps/api/geocode/json", params=google_payload)
	googlejson = rgoogle.json()
	# print(rgoogle.url)
	status = googlejson["status"]
	if not status == "OK" :
		result["name"] = "Invalid address"
		return result
	location = googlejson['results'][0]

	# print ("Latitude and Longitude of Seoul : ",location["geometry"]["location"])
	latitude = location["geometry"]["location"]["lat"]
	longitude = location["geometry"]["location"]["lng"]
	latlong = str(latitude) + "," + str(longitude)

	# Get restaurant based on query
	foursquare_payload = {'client_id': FOURSQUARE_CLIENT_ID, 'client_secret': FOURSQUARE_CLIENT_SECRET, 'v' : 20160105,
	'limit':100,'ll': latlong,'query': query}

	rfoursquare = requests.get("https://api.foursquare.com/v2/venues/search",params=foursquare_payload)
	fjson = rfoursquare.json()
	restaurants = fjson['response']['venues']
	total_restaurants = len(restaurants)
	restaurants_count = min(total_restaurants,100)
	if not restaurants_count > 0:
		result["name"] = "Sorry - No Restaurant found!"
		return result
	random_restaurant_index = random.randrange(0,restaurants_count)
	random_restaurant = restaurants[random_restaurant_index]
	location = random_restaurant["location"]
	formattedAddress  = []
	try:
		formattedAddress = location["formattedAddress"]
	except KeyError:
		formattedAddress[0] = "N/A"

	stats = random_restaurant["stats"]
	name = random_restaurant["name"]
	venue_id = random_restaurant["id"]
	checkIns = stats["checkinsCount"]
	contact = random_restaurant["contact"]
	phone_number = ''
	try :
		phone_number = contact["formattedPhone"]
	except KeyError:
		phone_number = 'N/A'

	result["name"] = name
	result["checkins"] = checkIns
	result["phone_number"] = phone_number
	result["address"] = (' ').join(formattedAddress)

	# Get Restaurant photo
	foursquare_payload_photo = {'client_id': FOURSQUARE_CLIENT_ID, 'client_secret': FOURSQUARE_CLIENT_SECRET, 'v' : 20160105}

	rfoursquare_photo = requests.get("https://api.foursquare.com/v2/venues/"+venue_id+"/photos",params=foursquare_payload_photo)
	# print (rfoursquare_photo.url)
	photojson = rfoursquare_photo.json()
	photos = photojson['response']['photos']
	total_photos = photos["count"]
	if total_photos > 0 :
		photos_count = min(total_photos,100)
		random_photo_index = random.randrange(0,photos_count)
		photo = photos['items'][random_photo_index]
		photo_url = photo["prefix"] + "height320" + photo["suffix"]
		# print (photo_url)
		result["image"] = photo_url
	else :
		print("no_photo")

	return result




def index(request):
    return render(request, 'search/index.html', {})

def result(request):
	context = {}
	if request.method == "GET":
		location = request.GET["location"]
		location = location.replace(" ","+")
		restaurantType = request.GET["rtype"]
		if restaurantType and location :
			context = getRandomRestaurant(location,restaurantType)
			return render(request,'search/result.html',context)
		else :
			return HttpResponseRedirect('/')
	else :
		return HttpResponseRedirect('/')
