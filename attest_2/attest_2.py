import psycopg2
from psycopg2 import OperationalError

conn = psycopg2.connect(host="127.0.0.1", port="5454", user="postgres", password="VJZk.,bvfzvfvf1310++", dbname="demo")

def execute_read_query(conn, query):
    cursor = conn.cursor()
    result = None
    try:
        cursor.execute(query)
        result = cursor.fetchall()
        return result
    except OperationalError as e:
        print(f"The error '{e}' occurred")

select_view = "select * from The_last_7_tickets_are_cheaper_than_10000"
view = execute_read_query(conn, select_view)

for view in view:
    print(view)