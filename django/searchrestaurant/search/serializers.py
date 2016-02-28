from django.contrib.auth.models import User, Group
from rest_framework import serializers
from .models import Location,Restaurant


class UserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = User
        fields = ('url', 'username', 'email', 'groups')


class RestaurantSerializer(serializers.ModelSerializer):
	class Meta:
		model = Restaurant
		fields = ('name','latitude','longitude','address','photo_url','phone_number','venue_id',
			'checkins','r_type','created_at','updated_at')

