#!/bin/bash
# $1 => project name
#!/bin/bash

#---------------------------------------------------------------------
# Setup Name => $1
PROJECT_NAME=$1
echo "Setting up Django Project...\n"
mkdir $PROJECT_NAME
cd $PROJECT_NAME
#---------------------------------------------------------------------
# Check if virtual environment is already activated
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "Deactivating existing virtual environment..."
    deactivate
fi
# Create a new virtual environment
echo "Creating new virtual environment..."
python3 -m venv env
echo "Activating virtual environment..."
source env/bin/activate
#---------------------------------------------------------------------
# Install neccessary packages
echo "Installing neccessary pip packages..."
pip3 install django djangorestframework black python-dotenv
#---------------------------------------------------------------------
# Setting up django hidden environment files
echo "setting up environment files..."
touch .env
echo "
DJANGO_SETTINGS_MODULE=\"$PROJECT_NAME.configs.dev\"
SECRET_KEY=\"SECRET_KEY_TEMP_DEV\"
DB_ENGINE=\"django.db.backends.postgresql\"
DB_NAME=\"$PROJECT_NAME\"
DB_USER=\"postgres\"
DB_PASSWORD=\"password\"
DB_HOST=\"localhost\"
DB_PORT=\"5432\"
" > .env
#---------------------------------------------------------------------
# Setting up django cmd tool Manage.py
echo "setting up manage.py..."
touch manage.py
echo "
# Django's Command line tool utility for administrative tasks
import os
import sys
from dotenv import load_dotenv

load_dotenv()

def main():
    \"\"\"Run administrative tasks.\"\"\"
    current_module = os.getenv(\"DJANGO_SETTINGS_MODULE\")
    os.environ.setdefault(\"DJANGO_SETTINGS_MODULE\", current_module)
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            \"Couldn't import Django. Are you sure it's installed and \"
            \"available on your PYTHONPATH environment variable? Did you \"
            \"forget to activate a virtual environment?\"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == \"__main__\":
    main()

" > manage.py
#---------------------------------------------------------------------
# Create a new Django project
echo "Making management directory..."
mkdir $PROJECT_NAME
cd $PROJECT_NAME
#---------------------------------------------------------------------
# Setting up Project files
echo "Setting up management directory..."
touch __init__.py asgi.py urls.py wsgi.py

echo "asgi setup..."
echo "
import os

from django.core.asgi import get_asgi_application

current_module = os.getenv(\"DJANGO_SETTINGS_MODULE\")

os.environ.setdefault(\"DJANGO_SETTINGS_MODULE\", current_module)

application = get_asgi_application()
" > asgi.py

echo "wsgi setup..."
echo "
import os

from django.core.wsgi import get_wsgi_application

current_module = os.getenv(\"DJANGO_SETTINGS_MODULE\")

os.environ.setdefault(\"DJANGO_SETTINGS_MODULE\", current_module)

application = get_wsgi_application()
" > wsgi.py

echo "
from django.contrib import admin
from django.urls import path, include

from app.views import home_ping

urlpatterns = [
    path(\"\", home_ping, name=\"home_ping\"),
    path(\"admin/\", admin.site.urls),
    path(\"api-auth/\", include(\"rest_framework.urls\")),
    path(\"app/\", include(\"app.urls\")),
]
" > urls.py
#---------------------------------------------------------------------
# Setting up configs file
echo "Setting up configs..."
mkdir configs
cd configs
touch __init__.py base.py dev.py prod.py

echo "
from pathlib import Path
from os import getenv

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = getenv(\"SECRET_KEY\")

INSTALLED_APPS = [
    \"app.apps.AppConfig\",

    \"django.contrib.admin\",
    \"django.contrib.auth\",
    \"django.contrib.contenttypes\",
    \"django.contrib.sessions\",
    \"django.contrib.messages\",
    \"django.contrib.staticfiles\",
    \"rest_framework\",
]

MIDDLEWARE = [
    \"django.middleware.security.SecurityMiddleware\",
    \"django.contrib.sessions.middleware.SessionMiddleware\",
    \"django.middleware.common.CommonMiddleware\",
    \"django.middleware.csrf.CsrfViewMiddleware\",
    \"django.contrib.auth.middleware.AuthenticationMiddleware\",
    \"django.contrib.messages.middleware.MessageMiddleware\",
    \"django.middleware.clickjacking.XFrameOptionsMiddleware\",
]

ROOT_URLCONF = \"$PROJECT_NAME.urls\"

TEMPLATES = [
    {
        \"BACKEND\": \"django.template.backends.django.DjangoTemplates\",
        \"DIRS\": [],
        \"APP_DIRS\": True,
        \"OPTIONS\": {
            \"context_processors\": [
                \"django.template.context_processors.debug\",
                \"django.template.context_processors.request\",
                \"django.contrib.auth.context_processors.auth\",
                \"django.contrib.messages.context_processors.messages\",
            ],
        },
    },
]

REST_FRAMEWORK = {
    \"DEFAULT_PERMISSION_CLASSES\": [
        \"rest_framework.permissions.IsAuthenticated\",
    ],
    \"DEFAULT_AUTHENTICATION_CLASSES\": [
        \"rest_framework.authentication.SessionAuthentication\",
        \"rest_framework.authentication.TokenAuthentication\",
    ],
}


AUTH_PASSWORD_VALIDATORS = [
    {
        \"NAME\": \"django.contrib.auth.password_validation.UserAttributeSimilarityValidator\",
    },
    {
        \"NAME\": \"django.contrib.auth.password_validation.MinimumLengthValidator\",
    },
    {
        \"NAME\": \"django.contrib.auth.password_validation.CommonPasswordValidator\",
    },
    {
        \"NAME\": \"django.contrib.auth.password_validation.NumericPasswordValidator\",
    },
]


LANGUAGE_CODE = \"en-us\"

TIME_ZONE = \"UTC\"

USE_I18N = True

USE_TZ = True

STATIC_URL = \"static/\"

DEFAULT_AUTO_FIELD = \"django.db.models.BigAutoField\"


" > base.py

echo "
from .base import *
from os import getenv

DEBUG = True

ALLOWED_HOSTS = [\"*\"]

DATABASES = {
    \"default\": {
        \"ENGINE\": getenv(\"DB_ENGINE\"),
        \"NAME\": getenv(\"DB_NAME\"),
        \"USER\": getenv(\"DB_USER\"),
        \"PASSWORD\": getenv(\"DB_PASSWORD\"),
        \"HOST\": getenv(\"DB_HOST\"),
        \"PORT\": getenv(\"DB_PORT\"),
    }
}

WSGI_APPLICATION = \"$PROJECT_NAME.wsgi.application\"

" > dev.py

echo "
from .base import *
from os import getenv

DEBUG = False

ALLOWED_HOSTS = [\"*\"]

DATABASES = {
    \"default\": {
        \"ENGINE\": getenv(\"DB_ENGINE\"),
        \"NAME\": getenv(\"DB_NAME\"),
        \"USER\": getenv(\"DB_USER\"),
        \"PASSWORD\": getenv(\"DB_PASSWORD\"),
        \"HOST\": getenv(\"DB_HOST\"),
        \"PORT\": getenv(\"DB_PORT\"),
    }
}

WSGI_APPLICATION = \"app.wsgi.application\"

" > prod.py

#---------------------------------------------------------------------
cd ../../
# Setting up app
echo "setting up app..."
mkdir app/
cd app/
mkdir fixtures
touch __init__.py admin.py apps.py models.py serializers.py tests.py urls.py views.py

echo "
from django.urls import path
from .views import (
    YOUR_METHOD_CLASS
)

urlpatterns = [
    path(\"/\", YOUR_METHOD_CLASS.as_view()),
]
" > urls.py

echo "
from django.http import HttpResponse
from rest_framework import generics
from datetime import datetime
from rest_framework.pagination import PageNumberPagination
from rest_framework import filters
from rest_framework.response import Response
from rest_framework import status
" > views.py

echo "
from rest_framework import serializers
from django.contrib.auth.models import User
" > serializers.py

echo "
from django.db import models
" > models.py

echo "
from django.apps import AppConfig


class AppConfig(AppConfig):
    default_auto_field = \"django.db.models.BigAutoField\"
    name = \"app\"

" > apps.py

echo "
from django.contrib import admin
" > admin.py
#---------------------------------------------------------------------
cd ..
pip freeze > requirements.txt
echo "Django Project $1 Setup Complete!"
#---------------------------------------------------------------------

