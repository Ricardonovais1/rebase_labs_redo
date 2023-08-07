require 'pg'

class ResetDatabase
  def self.reset
    db_config = {
      host: 'postgres-redo',
      user: 'admin',
      password: 'password',
      dbname: 'rebase_redo'
    }

    self.reset_database(db_config)
  end

  def self.reset_database(db_config)
    db = PG.connect(db_config)

    # db.exec("DELETE FROM tests;")
    # db.exec("DELETE FROM exams;")
    # db.exec("DELETE FROM doctors;")
    # db.exec("DELETE FROM patients;")

    db.exec("DROP TABLE IF EXISTS tests CASCADE;")
    db.exec("DROP TABLE IF EXISTS exams CASCADE;")
    db.exec("DROP TABLE IF EXISTS doctors CASCADE;")
    db.exec("DROP TABLE IF EXISTS patients CASCADE;")

    db.close
  end
end
