import psycopg2
import os

def get_db_connection():
    db_url = os.environ.get("DB_ENDPOINT", "pgdb")
    db_password = os.environ.get("DB_PASSWORD", "example")
    db_user = os.environ.get("DB_USER", "postgres")
    db_port = os.environ.get("DB_PORT", "5432")
    db_name = os.environ.get("DB_NAME", "restaurants")
    return psycopg2.connect(
        host=db_url,
        database=db_name,
        user=db_user,
        password=db_password,
        port=db_port
    )


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
