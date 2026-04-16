require 'sqlite3'

db = SQLite3::Database.new("databas.db")


def seed!(db)
  puts "Using db file: db/todo.db"
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def drop_tables(db)
  db.execute('DROP TABLE IF EXISTS accounts')
  db.execute('DROP TABLE IF EXISTS pause_times')
  db.execute('DROP TABLE IF EXISTS algorithms')
end

def create_tables(db)
  db.execute('CREATE TABLE accounts (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL UNIQUE,
              password_hash TEXT NOT NULL,
              total_milliseconds INTEGER NOT NULL DEFAULT 0)')
  db.execute('CREATE TABLE pause_times (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              milliseconds INTEGER NOT NULL,
              paused_at DATETIME DEFAULT CURRENT_TIMESTAMP,
              FOREIGN KEY (user_id) REFERENCES accounts(id))')
  db.execute('CREATE TABLE algorithms (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              alg_name TEXT NOT NULL,
              alg_text TEXT NOT NULL,
              updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
              UNIQUE(user_id, alg_name),
              FOREIGN KEY (user_id) REFERENCES accounts(id))')
end

def populate_tables(db)

end


seed!(db)





