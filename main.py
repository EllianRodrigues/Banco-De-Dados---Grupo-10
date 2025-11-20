import os
from dotenv import load_dotenv
import psycopg2
from psycopg2.extras import RealDictCursor
import traceback

load_dotenv()

DB_USER = os.getenv("POSTGRES_USER", "postgres")
DB_PASS = os.getenv("POSTGRES_PASSWORD", "senha")
DB_NAME = os.getenv("POSTGRES_DB", "postgres")
DB_HOST = os.getenv("POSTGRES_HOST", "localhost")
DB_PORT = int(os.getenv("POSTGRES_PORT_EXTERNAL", 64321))

def get_connection():
    return psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        host=DB_HOST,
        port=DB_PORT
    )

def query_all(sql, params=None):
    with get_connection() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:

            if params is None:
                results = []
                statements = [s.strip() for s in sql.split(';') if s.strip()]
                for stmt in statements:
                    cur.execute(stmt)
                    try:
                        rows = cur.fetchall()
                    except psycopg2.ProgrammingError:
                        rows = []
                    results.extend(rows)
                return results
            else:
                cur.execute(sql, params)
                return cur.fetchall()

def _read_query_path_from_toml(config_file="config.toml"):
    if not os.path.exists(config_file):
        return None
    with open(config_file, "r", encoding="utf-8") as f:
        for raw in f:
            line = raw.strip()
            if not line or line.startswith("#") or line.startswith("["):
                continue
            if "=" in line:
                key, val = line.split("=", 1)
                key = key.strip()
                val = val.strip()
                if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
                    val = val[1:-1]
                if key == "query_path":
                    return val
    return None

def _load_sql_from_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def main():
    config_file = "config.toml"
    query_path = _read_query_path_from_toml(config_file)
    if not query_path:
        raise ValueError(f"Chave 'query_path' não encontrada ou vazia em {config_file}")

    sql = _load_sql_from_file(query_path)

    print(f"Tentando conectar em {DB_HOST}:{DB_PORT} como {DB_USER} (db={DB_NAME})")
    try:
        rows = query_all(sql)
        for r in rows:
            print(r)
    except Exception as e:
        print("Falha na consulta:")
        traceback.print_exc()


if __name__ == "__main__":
    main()