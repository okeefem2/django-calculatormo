from django.conf.urls import url

from . import views

app_name = 'calculator'


urlpatterns = [

url(r'^calculate/$', views.formview, name='formview'),
url(r'^(?P<answer_id>[0-9]+)/$', views.answer, name='answer'),
url(r'^results/$', views.results, name='results'),

]
