##################
# Calculator App #
##################

Calculator is a simple Django app that does basic calculator functions and stores
the results in a database for retrieval.

Environment Set-up:

1. First make sure Python is installed (assuming python 3.5)
  https://www.python.org/downloads/
  * when installing, make sure pip is included in the installation process
  * also add python to PATH to make development easier.

2. Run 'pip-install django'
  in command line to install the newest version of django (assuming 1.9)

3. Install PostreSQL http://www.postgresql.org/download/ and create a database and user for use in Django
  * make sure to give the user all privileges on the database

4. Move the CONTENTS of the included psycopg2 folder into your Python/Lib/site-packages/ folder in the location where
  you installed Python 3.5

5. Run 'pip install --user django-calculatormo-0.1.tar.gz' to install the calculator library

6. Create a Django project by navigating to the directory you'd like your project to be in (in command line) and run
  django-admin startproject sitename

7. open sitename/sitename/settings.py in your django project
  and add calculator to your INSTALLED_APPS setting like this::

    INSTALLED_APPS = [
        ...
        'calculator',
    ]

8. open sitename/sitename/urls.py in your django project
  and include calculator into your urls conf like this::

  url(r'^calculator/', include('calculator.urls')),

9. Navigate to sitename/ in your project via command line and Run 'python manage.py migrate' to create the models for the calculator.

10. Run 'python manage.py runserver' to run the development server

11. navigate to http://127.0.0.1:8000/calculator/calculate/ in a browser to use the calculator
