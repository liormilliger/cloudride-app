from flask import Flask, render_template, request
from models import get_db_connection, fetch_restaurants
import os

app = Flask(__name__)

from flask import Flask, render_template, request
from models import get_db_connection, fetch_restaurants

app = Flask(__name__)

@app.route("/")
def index():
    cuisine = request.args.get("cuisine")
    rating = request.args.get("rating")
    kosher = request.args.get("kosher")
    cibus = request.args.get("cibus")
    dark_mode = os.environ.get("DARK_MODE", "").lower() == "true"

    conn = get_db_connection()
    restaurants = fetch_restaurants(conn, cuisine, rating, kosher, cibus)
    conn.close()
    return render_template("index.html",
                           restaurants=restaurants,
                           selected_cuisine=cuisine,
                           selected_rating=rating,
                           selected_kosher=kosher,
                           selected_cibus=cibus,
                           is_dark=dark_mode)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
