class Dog
  attr_reader :id
  attr_accessor :name, :breed

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def save
    if @id.nil?
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      update
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  class << self
    def create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
      SQL
      DB[:conn].execute(sql)
    end

    def drop_table
      DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def create(hash)
      new(hash).save
    end

    def new_from_db(row)
      new(id: row[0], name: row[1], breed: row[2])
    end

    def find_by_id(id)
      row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id.to_i)
      new_from_db(row[0])
    end

    def find_or_create_by(hash)
      sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
      row = DB[:conn].execute(sql, hash[:name], hash[:breed])
      row.empty? ? create(hash) : new_from_db(row[0])
    end

    def find_by_name(name)
      new_from_db(
        DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name)[0]
      )
    end
  end
end