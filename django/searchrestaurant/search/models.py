from django.db import models




class Restaurant(models.Model):
	name = models.CharField(max_length=400)
	latitude = models.DecimalField(max_digits=9, decimal_places=6)
	longitude = models.DecimalField(max_digits=9, decimal_places=6)
	address = models.CharField(max_length=500)
	checkins = models.IntegerField()
	photo_url = models.CharField(max_length=800)
	venue_id = models.CharField(max_length=500)
	phone_number = models.CharField(max_length=200,default='')
	created_at = models.DateTimeField(auto_now=True)
	updated_at = models.DateTimeField(auto_now_add=True)
	r_type = models.CharField(max_length=100,default="")

	def __str__(self):
		return self.name

	class Meta:
		ordering=("-checkins",)



class Location(models.Model):
	restaurant_location = models.CharField(max_length=100)
	latitude = models.DecimalField(max_digits=9, decimal_places=6)
	longitude = models.DecimalField(max_digits=9, decimal_places=6)
	restaurant_type = models.CharField(max_length=100,default="pizza")
	restaurant = models.ManyToManyField(Restaurant)
	created_at = models.DateTimeField(auto_now=True)
	updated_at = models.DateTimeField(auto_now_add=True)

	def __str__(self):
		return self.restaurant_location

	class Meta:
		ordering= ("-created_at",)

