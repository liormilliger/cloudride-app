import psycopg2
import os

def get_db_connection():
    # Retrieve connection details from environment variables
    # These must be set in your Kubernetes Deployment (Step 3)
    DB_HOST = os.environ.get('DB_HOST') 
    DB_NAME = os.environ.get('DB_NAME')
    DB_USER = os.environ.get('DB_USER')
    DB_PASSWORD = os.environ.get('DB_PASSWORD') 

    if not all([DB_HOST, DB_NAME, DB_USER, DB_PASSWORD]):
        raise EnvironmentError("Missing required database environment variables (DB_HOST, DB_NAME, DB_USER, DB_PASSWORD).")

    try:
        # Crucial: Explicitly pass the hostname (DB_HOST) for network connection
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            port='5432' # Default port
        )
        return conn
    except psycopg2.OperationalError as e:
        # Print the error for debugging, then re-raise
        print(f"Database connection failed: {e}")
        raise

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
