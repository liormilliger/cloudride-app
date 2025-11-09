import psycopg2
import os

def get_db_connection():
    return psycopg2.connect(
        host=os.environ.get("DB_HOST"),
        database=os.environ.get("DB_NAME"),
        user=os.environ.get("DB_USER"),
        password=os.environ.get("DB_PASSWORD"),
        port="5432"
    )
    # return psycopg2.connect(
    #     host=db_url,
    #     database=db_name,
    #     user=db_user,
    #     password=db_password,
    #     port=db_port
    # )


def fetch_restaurants(conn, cuisine=None, rating=None, kosher=None, cibus=None):
    query = "SELECT id, name, cuisine, rating, location, photo_url, kosher, accepts_cibus FROM restaurants WHERE location = 'רמת החייל'"
    params = []
    if cuisine:
        query += " AND cuisine = %s"
        params.append(cuisine)
    if rating:
        query += " AND rating >= %s"
        params.append(float(rating))
    if kosher == 'true':
        query += " AND kosher = true"
    elif kosher == 'false':
        query += " AND kosher = false"
    if cibus == 'true':
        query += " AND accepts_cibus = true"
    elif cibus == 'false':
        query += " AND accepts_cibus = false"

    with conn.cursor() as cur:
        cur.execute(query, tuple(params))
        return cur.fetchall()
