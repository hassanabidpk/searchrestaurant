from django.conf.urls import include, url
from . import views
from rest_framework.urlpatterns import format_suffix_patterns

urlpatterns = [

	url(r'^$', views.index, name='index'),
	 url(r'^yolog/$', views.yolo_index, name='yolo_index'),
	url(r'^result/$', views.result, name='result'),
	url(r'^list/$', views.RestaurantListView.as_view(), name="rlistview"),
	url(r'^restaurants/$', views.RestaurantAllListView.as_view(), name="rallview"),
	url(r'^restaurant/(?P<venue_id>[\w-]+)/$', views.restaurantwithid,name='rwithid'),
	url(r'^restaurants/map/$', views.RestaurantAllMapListView.as_view(), name="rlistmapview"),
	url(r'^api/v1/$',views.RestaurantList.as_view()),
  
]

urlpatterns = format_suffix_patterns(urlpatterns)
