from django.shortcuts import render, get_object_or_404
from django.http import Http404,HttpResponse,HttpResponseRedirect
import requests
import random
from django.views.generic import View
from .models import Location,Restaurant
from django.db.models import Avg
from django.core.exceptions import ObjectDoesNotExist,MultipleObjectsReturned
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
GOOGLE_API_KEY_JAVASCRIPT = 'GOOGLE_API_KEY_JAVASCRIPT'


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
	rtype = query
	result = {}
	restaurantList = []
	# Get latitude and longitude
	google_payload = {'address': ilocation, 'key': GOOGLE_API_KEY}
	rgoogle = requests.get("https://maps.googleapis.com/maps/api/geocode/json", params=google_payload)
	googlejson = rgoogle.json()
	print(rgoogle.url)
	status = googlejson["status"]
	if not status == "OK" :
		print("Invalid address - Try again")
		result["error"] = "Invalid address - Try again"
		return result
	location = googlejson['results'][0]

	# print ("Latitude and Longitude of Seoul : ",location["geometry"]["location"])
	latitude = location["geometry"]["location"]["lat"]
	longitude = location["geometry"]["location"]["lng"]
	latlong = str(latitude) + "," + str(longitude)
	loc = Location(restaurant_location=ilocation,latitude=latitude,longitude=longitude,restaurant_type=query)
	loc.save()
	# Get restaurant based on query
	foursquare_payload = {'client_id': FOURSQUARE_CLIENT_ID, 'client_secret': FOURSQUARE_CLIENT_SECRET, 'v' : 20160105,
	'limit':100,'ll': latlong,'radius':"800",'query': query}

	rfoursquare = requests.get("https://api.foursquare.com/v2/venues/search",params=foursquare_payload)
	fjson = rfoursquare.json()
	try:
		restaurants = fjson['response']['venues']
	except KeyError:
		result["error"] = "Sorry - No Restaurant found!"
		return result

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
			photo_url = photo["prefix"] + "455x300" + photo["suffix"]
			# print (photo_url)
			oneRestaurant["photo_url"] = photo_url
			try :
				rest = loc.restaurant.get(name=name,address=oneRestaurant["address"])

			except ObjectDoesNotExist:
				try : 
					rest = Restaurant.objects.get(name=name,address=oneRestaurant["address"],r_type=rtype)
					rest.checkins = checkIns
					rest.phone_number = phone_number
					rest.save()
					loc.restaurant.add(rest)
					restaurantList.append(oneRestaurant)
					print("exisiting rest found and added to location")
				except ObjectDoesNotExist:
					rest = Restaurant(name=name,latitude=lat,longitude=lng,checkins=checkIns,phone_number=phone_number,
						venue_id=venue_id,address=oneRestaurant["address"],photo_url=photo_url,r_type=rtype)
					rest.save()
					loc.restaurant.add(rest)
					restaurantList.append(oneRestaurant)
					print("no rest found therefore saved and added to location")
				except MultipleObjectsReturned:
					print("multiple objects returned 1")
			except MultipleObjectsReturned:
				print("multiple objects returned 2")
		else :
			# oneRestaurant["image"] = None
			print("no_photo")

	try:
		loc = Location.objects.get(restaurant_location=ilocation,restaurant_type=rtype)
	except MultipleObjectsReturned:
		loc = loc[0]
	restaurants = loc.restaurant.all()
	result["rlist"] = restaurants
	return result



def index(request):
    return render(request, 'search/index.html', {})

def yolo_index(request):
    context = {}
    return render(request,'search/yolo.html',context)

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

class RestaurantListView(View):
	def get(self,request):
		print("RestaurantListView")
		if not "location" in request.GET:
			return HttpResponseRedirect('/')
		context = {}
		if request.method == "GET":
			location = request.GET["location"]
			location = location.rstrip().replace(" ","+")
			restaurantType = request.GET["rtype"]
			restaurantType = restaurantType.rstrip().replace(" ","+")
			print("location %s",location)
			if restaurantType and location:
				restaurantType = restaurantType.lower()
				location = location.lower()
				try: 
					print("check for exisitng location and rtype")
					loc = Location.objects.get(restaurant_location=location,restaurant_type=restaurantType)
					restaurants = loc.restaurant.all()
					context["rlist"] = restaurants
				except ObjectDoesNotExist:
					print("rlistview objectdoesnotexist")
					context = getRestaurantList(location,restaurantType)
				except MultipleObjectsReturned:
					print("multiple-objects")
					loc = loc[0]
					restaurants = loc.restaurant.all()
					context["rlist"] = restaurants
				return render(request,'search/list.html',context)
			else :
				return HttpResponseRedirect('/')
		else :
			return HttpResponseRedirect('/')


def restaurantwithid(request,venue_id):
	try: 
		rest = Restaurant.objects.get(venue_id=venue_id)
		photo_url = rest.photo_url.replace('300x200','1250x400',1)
		photo_url = rest.photo_url.replace('455x300','1250x400',1)
		return render(request,'search/single.html',{'rest':rest,'photo_url':photo_url})

	except MultipleObjectsReturned:
		rest = rest[0] 
		photo_url = rest.photo_url.replace('300x200','1250x400',1)
		photo_url = rest.photo_url.replace('455x300','1250x400',1)
		return render(request,'search/single.html',{'rest':rest,'photo_url':photo_url})

	except ObjectDoesNotExist:
		return render(request,'search/single.html',{})



class RestaurantAllListView(ListView):
	print("RestaurantAllListView")
	context_object_name = 'r_list'
	queryset = Restaurant.objects.all()
	template_name = 'search/all_list.html'
	def get_context_data(self, **kwargs):
		context = super(RestaurantAllListView, self).get_context_data(**kwargs)
		locations = Location.objects.all()[:16]
		context["locations"] = locations
		return context

class RestaurantAllMapListView(ListView):
	""" This class based view shows map of all restaurants"""
	print("RestaurantAllMapListView")
	context_object_name = 'r_list'
	queryset = Restaurant.objects.all()
	template_name = 'search/all_list_map.html'

	def get_context_data(self, **kwargs):
		context = super(RestaurantAllMapListView, self).get_context_data(**kwargs)
		avgLat = Restaurant.objects.all().aggregate(Avg('latitude'))
		avgLng = Restaurant.objects.all().aggregate(Avg('longitude'))
		locations = Location.objects.all()[:16]
		print(avgLat,avgLng)
		context["avgLat"] = avgLat
		context["avgLng"] = avgLng
		context["locations"] = locations
		return context





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
			loc = Location.objects.get(restaurant_location=location,restaurant_type=restaurantType)
			restaurants = loc.restaurant.all()
			serializer = RestaurantSerializer(restaurants, many=True)
			return Response(serializer.data,status=status.HTTP_200_OK)
		except MultipleObjectsReturned:
			loc = loc[0]
			restaurants = loc.restaurant.all()
			serializer = RestaurantSerializer(restaurants, many=True)
			return Response(serializer.data,status=status.HTTP_200_OK)
		except ObjectDoesNotExist:
			context = getRestaurantList(location,restaurantType)
			try: 
				loc = Location.objects.get(restaurant_location=location,restaurant_type=restaurantType)
				restaurants = loc.restaurant.all()
				serializer = RestaurantSerializer(restaurants, many=True)
				return Response(serializer.data,status=status.HTTP_200_OK)
			except ObjectDoesNotExist:
				print ("does not exist")
				return Response(data={'error':"not-found",'status':"404"},status=status.HTTP_404_NOT_FOUND)
			except MultipleObjectsReturned:
				loc = loc[0]
				restaurants = loc.restaurant.all()
				serializer = RestaurantSerializer(restaurants, many=True)
				return Response(serializer.data,status=status.HTTP_200_OK)

		


