require 'pg'

db_config = {
  host: 'postgres-redo',
  user: 'admin',
  password: 'password',
  dbname: 'rebase_redo'
}

connect_pg = PG.connect(db_config)

# connect_pg.exec("DROP TABLE IF EXISTS tests CASCADE;")
# connect_pg.exec("DROP TABLE IF EXISTS exams CASCADE;")
# connect_pg.exec("DROP TABLE IF EXISTS doctors CASCADE;")
# connect_pg.exec("DROP TABLE IF EXISTS patients CASCADE;")

connect_pg.exec("CREATE TABLE IF NOT EXISTS patients (
  id SERIAL PRIMARY KEY,
  cpf VARCHAR(30) UNIQUE,
  name VARCHAR(100),
  email VARCHAR(100),
  birthday DATE,
  address VARCHAR(300),
  city VARCHAR(100),
  state VARCHAR(30)
)")

connect_pg.exec("CREATE TABLE IF NOT EXISTS doctors (
  id SERIAL PRIMARY KEY,
  crm VARCHAR(20) UNIQUE,
  crm_state VARCHAR(2),
  name VARCHAR(80),
  email VARCHAR(100)
)")

connect_pg.exec("CREATE TABLE IF NOT EXISTS exams (
  id SERIAL PRIMARY KEY,
  token VARCHAR(6) UNIQUE,
  result_date DATE,
  patient_id INTEGER REFERENCES patients(id),
  doctor_id INTEGER REFERENCES doctors(id)
)")

connect_pg.exec("CREATE TABLE IF NOT EXISTS tests (
  id SERIAL PRIMARY KEY,
  test_type VARCHAR(30),
  limits VARCHAR(30),
  result INTEGER,
  token_id VARCHAR(6) REFERENCES exams(token)
)")





