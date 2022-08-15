import pandas as pd
from sqlalchemy import create_engine

with open('auth', 'r') as auth_file:
    user = auth_file.readline().strip()
    password = auth_file.readline().strip()
    database = auth_file.readline().strip()

connection_url = f'mysql://{user}:{password}@localhost/{database}'
print(connection_url)
engine = create_engine(connection_url)
con = engine.connect()

number_chunks = 1
csv_data_frame = pd.read_csv('all_c_cpp_release2.0.csv', chunksize=10, encoding='ISO-8859-1', error_bad_lines=False)

for chunk in csv_data_frame:
    try:
        chunk.to_sql(name='dados', con=con, schema='msr_dump', if_exists='append', chunksize=10)
        print(f'Number of rows inserted: {number_chunks}')
        number_chunks = number_chunks + 1
    except Exception:
        pass

con.close()