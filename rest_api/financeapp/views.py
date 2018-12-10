from django.shortcuts import render
from serializers import *
from django.http import HttpResponse
from django.contrib.auth import authenticate, login, logout
from rest_framework.views import APIView
from rest_framework import generics, status
from rest_framework.response import *

from rest_framework.generics import ListCreateAPIView
from rest_framework import  generics
from rest_framework.authtoken.models import Token

from datetime import datetime


def index(request):
    return HttpResponse(render(request, 'index.html'))

def register(request):
    return HttpResponse(render(request, 'sign_up.html'))

def log(request):
    return HttpResponse(render(request, 'login.html'))


def sign_up(request):
    users = User.objects.filter(username=request.POST['username'])
    if len(users) == 0:
        user = User.objects.create_user(username=request.POST['username'], password=request.POST['password'])
        user.save()
        account = Account.objects.create(user=user, limit=request.POST['limit'])
        account.save()
        usr = authenticate(username=request.POST['username'], password=request.POST['password'])
        if usr is not None:
            login(request, usr)
            uname = usr.username
            ulimit = Account.objects.filter(user= usr)[0].limit
            return HttpResponse(render(request, 'profile.html', context={'name': uname, 'limit': ulimit}))
        else:
            return HttpResponse(render(request, 'index.html'))
    else:
        return HttpResponse(render(request, 'index.html'))



def sign_in(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        usr = authenticate(username=username, password=password)
        print(usr)
        if usr is not None:
            print("login")
            login(request, usr)
            uname = usr.username
            print(uname)
            ulimit = Account.objects.filter(user= usr)[0].limit
            print(ulimit)
            return HttpResponse(render(request, 'profile.html', context={'name': uname, 'limit': ulimit}))
        else:
            return HttpResponse(render(request, 'index.html'))
    else:
        return HttpResponse(render(request, 'index.html'))



#SERIALIZERS REST

class UserHandler(APIView):

    def post(self, request, format='json'):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            if user:
                token = Token.objects.create(user=user)
                json = serializer.data
                json['token'] = token.key
                return Response(json, status=status.HTTP_201_CREATED)
        else:
            return Response(status=status.HTTP_404_NOT_FOUND)

    def get(self, request, format='json'):
        users = User.objects.all()
        serializer = UserSerializer(users.data, many=True)
        return Response(serializer.data)


class AccountHandler(APIView):
    def post(self, request, format='json'):
        user_id = Token.objects.filter(key=request.data['user'])[0].user_id
        request.data['user'] = user_id
        serializer = AccountSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST)

    def get(self, request, pk):
        user_id = Token.objects.filter(key=pk)[0].user_id
        account = Account.objects.filter(user=user_id)[0]
        if account:
            serializer = AccountSerializer(account)
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST)

    def put(self, request):
        user_id = Token.objects.filter(key=request.data['user'])[0].user_id
        request.data['user'] = user_id
        account = Account.objects.filter(user=user_id)[0]
        serializer = AccountSerializer(account, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST)


class OutcomesHandler(APIView):
    def post(self, request):
        user_id = Token.objects.filter(key=request.data['user'])[0].user_id
        request.data['user'] = user_id
        # request.data['date'] = datetime.now()
        serializer = OutcomesSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST)

    def get(self, request, pk):
        #user_id = Token.objects.filter(key=request.data['user'])[0].user_id
        user_id = Token.objects.filter(key=pk)[0].user_id
        outcomes = Outcomes.objects.filter(user=user_id)
        if outcomes:
            serializer = OutcomesSerializer(outcomes, many=True)
            result = serializer.data
            for item in result:
                pkk = item['type']
                type_name = OutcomeType.objects.get(pk=pkk).type
                item['type'] = type_name
            return Response(result, status=status.HTTP_200_OK)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST)


class OutcomeTypesHandler(APIView):
    def get(self, request, format='json'):
        serializer = OutcomesTypeSerializer(OutcomeType.objects.all(), many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
