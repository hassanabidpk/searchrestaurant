Search Restaurant
---

1. After cloning / downloading the github repo. Go to `cd django`
2. Create virtual environment  `python3 -m venv rvenv` (Make sure you have Python 3 installed)
3. Activate virtual environment Mac : `source rvenv/bin/activate` Windows : `rvenv\Scripts\activate` then go to `cd searchrestaurant`
4. Install requirements `pip install -r requirements.txt`
5. Run Django site `python manage.py runserver`
6. Search on home page `http://127.0.0.1:8000` and see the result!
7. [Optional] `python manage.py makemigrations` and `python manage.py migrate`
8. Add Google Places API and Foursquare KEYS in project's settings.py `searchrestaurant/settings.py` 

<img src="../images/website.png" >


# TO-DO

1. Integrate jquery
2. Show list of the restaurants in nearby area without having to enter anything


# Contributions

Pull requests are welcomed!
