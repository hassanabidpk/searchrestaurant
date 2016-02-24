from django.shortcuts import render
from django.http import Http404,HttpResponse,HttpResponseRedirect
import requests
import random
from django.views.generic import View
from .models import Location,Restaurant
from django.core.exceptions import ObjectDoesNotExist
from rest_framework import viewsets
from .serializers import RestaurantSerializer
from django.views.decorators.csrf import csrf_exempt
from rest_framework.renderers import JSONRenderer
from rest_framework.parsers import JSONParser
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.conf import settings
from django.views.generic import ListView

GOOGLE_API_KEY = settings.GOOGLE_API_KEY
FOURSQUARE_CLIENT_ID = settings.FOURSQUARE_CLIENT_ID
FOURSQUARE_CLIENT_SECRET = settings.FOURSQUARE_CLIENT_SECRET


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

def getRestaurantList(ilocation,query):
	result = {}
	restaurantList = []
	# Get latitude and longitude
	google_payload = {'address': ilocation, 'key': GOOGLE_API_KEY}
	rgoogle = requests.get("https://maps.googleapis.com/maps/api/geocode/json", params=google_payload)
	googlejson = rgoogle.json()
	# print(rgoogle.url)
	status = googlejson["status"]
	if not status == "OK" :
		result["error"] = "Invalid address - Try again"
		return result
	location = googlejson['results'][0]

	# print ("Latitude and Longitude of Seoul : ",location["geometry"]["location"])
	latitude = location["geometry"]["location"]["lat"]
	longitude = location["geometry"]["location"]["lng"]
	latlong = str(latitude) + "," + str(longitude)
	loc = Location(restaurant_location=ilocation,latitude=latitude,longitude=longitude,resturant_type=query)
	loc.save()
	# Get restaurant based on query
	foursquare_payload = {'client_id': FOURSQUARE_CLIENT_ID, 'client_secret': FOURSQUARE_CLIENT_SECRET, 'v' : 20160105,
	'limit':100,'ll': latlong,'radius':"800",'query': query}

	rfoursquare = requests.get("https://api.foursquare.com/v2/venues/search",params=foursquare_payload)
	fjson = rfoursquare.json()
	restaurants = fjson['response']['venues']
	total_restaurants = len(restaurants)
	restaurants_count = min(total_restaurants,100)
	if not restaurants_count > 0:
		result["error"] = "Sorry - No Restaurant found!"
		return result
	for restaurant in restaurants:
		oneRestaurant = {}
		location = restaurant["location"]
		formattedAddress = []
		try:
			formattedAddress = location["formattedAddress"]
		except KeyError:
			formattedAddress[0] = "N/A"
		stats = restaurant["stats"]
		name = restaurant["name"]
		venue_id = restaurant["id"]
		checkIns = stats["checkinsCount"]
		contact = restaurant["contact"]
		phone_number = ''
		lat = location["lat"]
		lng = location["lng"]
		# print(lat,lng)
		try :
			phone_number = contact["formattedPhone"]
		except KeyError:
			phone_number = 'N/A'
		oneRestaurant["name"] = name
		oneRestaurant["checkins"] = checkIns
		oneRestaurant["phone_number"] = phone_number
		oneRestaurant["venue_id"] = venue_id
		oneRestaurant["address"] = (' ').join(formattedAddress)
		oneRestaurant["lat"] = lat
		oneRestaurant["lng"] = lng
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
			photo_url = photo["prefix"] + "300x200" + photo["suffix"]
			# print (photo_url)
			oneRestaurant["photo_url"] = photo_url
			rest = Restaurant(name=name,latitude=lat,longitude=lng,checkins=checkIns,phone_number=phone_number,
				venue_id=venue_id,address=oneRestaurant["address"],photo_url=photo_url)
			rest.save()
			loc.restaurant.add(rest)
			restaurantList.append(oneRestaurant)
		else :
			# oneRestaurant["image"] = None
			print("no_photo")

	loc = Location.objects.get(restaurant_location=ilocation)
	restaurants = loc.restaurant.all()
	result["rlist"] = restaurants
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

class RListView(View):
	print(GOOGLE_API_KEY)
	def get(self,request):
		if not "location" in request.GET:
			return HttpResponseRedirect('/')
		context = {}
		if request.method == "GET":
			location = request.GET["location"]
			location = location.replace(" ","+")
			restaurantType = request.GET["rtype"]
			if restaurantType and location :
				try: 
					loc = Location.objects.get(restaurant_location=location)
					restaurants = loc.restaurant.all()
					context["rlist"] = restaurants
				except ObjectDoesNotExist:
					context = getRestaurantList(location,restaurantType)
				return render(request,'search/list.html',context)
			else :
				return HttpResponseRedirect('/')
		else :
			return HttpResponseRedirect('/')

class RestaurantAllListView(ListView):
	print("ListView")
	context_object_name = 'r_list'
	queryset = Restaurant.objects.all()
	template_name = 'search/all_list.html'


class JSONResponse(HttpResponse):
    """
    An HttpResponse that renders its content into JSON.
    """
    def __init__(self, data, **kwargs):
        content = JSONRenderer().render(data)
        kwargs['content_type'] = 'application/json'
        super(JSONResponse, self).__init__(content, **kwargs)


class RestaurantList(APIView):
	def get(self,request,format=None):
		if "location" in request.GET and "rtype" in request.GET:
			location = request.GET["location"]
			location = location.replace(" ","+")
			restaurantType = request.GET["rtype"]
		else:
			restaurants = Restaurant.objects.all()
			serializer = RestaurantSerializer(restaurants, many=True)
			return Response(serializer.data,status=status.HTTP_200_OK)
		try: 
			loc = Location.objects.get(restaurant_location=location,rtype=restaurantType)
			restaurants = loc.restaurant.all()
			serializer = RestaurantSerializer(restaurants, many=True)
			return Response(serializer.data,status=status.HTTP_200_OK)
		except ObjectDoesNotExist:
			context = getRestaurantList(location,restaurantType)
			try: 
				loc = Location.objects.get(restaurant_location=location)
				restaurants = loc.restaurant.all()
				serializer = RestaurantSerializer(restaurants, many=True)
				return Response(serializer.data,status=status.HTTP_200_OK)
			except ObjectDoesNotExist:
				print ("does not exist")
				return Response(data={'error':"not-found",'status':404},status=status.HTTP_404_NOT_FOUND)

		


