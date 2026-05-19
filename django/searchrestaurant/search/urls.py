from django.urls import re_path
from . import views
from rest_framework.urlpatterns import format_suffix_patterns

app_name = 'search'

urlpatterns = [
	re_path(r'^$', views.index, name='index'),
	re_path(r'^yolog/$', views.yolo_index, name='yolo_index'),
	re_path(r'^result/$', views.result, name='result'),
	re_path(r'^list/$', views.RestaurantListView.as_view(), name="rlistview"),
	re_path(r'^restaurants/$', views.RestaurantAllListView.as_view(), name="rallview"),
	re_path(r'^restaurant/(?P<venue_id>[\w-]+)/$', views.restaurantwithid, name='rwithid'),
	re_path(r'^restaurants/map/$', views.RestaurantAllMapListView.as_view(), name="rlistmapview"),
	re_path(r'^api/v1/$', views.RestaurantList.as_view()),
	re_path(r'^api/v1/pizzalist/$', views.PizzaList.as_view()),
]

urlpatterns = format_suffix_patterns(urlpatterns)
