class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes = {})
    attributes.each do |attribute, value|
      send("#{attribute}=", value)
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
  end

  def self.create(attributes)
    new(attributes).save
  end

  def self.new_from_db(row)
    new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    new_from_db(result)
  end

  def self.find_or_create_by(attr)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, attr[:name], attr[:breed])
    dog = if !dog.empty?
            find_by_id(dog[0][0])
          else
            create(attr)
          end
    dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    new_from_db(result)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, name, breed, id)
  end
end