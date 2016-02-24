from django.conf.urls import include, url
from . import views
from rest_framework.urlpatterns import format_suffix_patterns

urlpatterns = [

	url(r'^$', views.index, name='index'),
	url(r'^result/$', views.result, name='result'),
	url(r'^list/$', views.ListView.as_view(), name="rlistview"),
	url(r'^api/v1/',views.RestaurantList.as_view()),
	url(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework')),
  
]

urlpatterns = format_suffix_patterns(urlpatterns)
