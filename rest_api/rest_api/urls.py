"""finance_api URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.10/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from django.conf.urls import url
from django.contrib import admin
from financeapp.views import *

from rest_framework.urlpatterns import format_suffix_patterns
from rest_framework.authtoken import views

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^index/', index),
    url(r'^register/', register),
    url(r'^login/', log),
    url(r'^signup/', sign_up),
    url(r'^signin/', sign_in),
]

api_urls = [
    url(r'^api-token-auth/', views.obtain_auth_token),
    url(r'^users/$', UserHandler.as_view()),
    url(r'^outcomes/$', OutcomesHandler.as_view()),
    url(r'^outcomes/(?P<pk>[0-9a-f]+)/$', OutcomesHandler.as_view()),
    url(r'^accounts/$', AccountHandler.as_view()),
    url(r'^accounts/(?P<pk>[0-9a-f]+)/$', AccountHandler.as_view()),
    url(r'^outcometypes/$', OutcomeTypesHandler.as_view()),

]

api_urls = format_suffix_patterns(api_urls)

urlpatterns += api_urls