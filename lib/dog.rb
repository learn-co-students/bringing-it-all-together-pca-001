class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name: name, breed: breed, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def save
    if id
      update
    else
      sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?,?)
      SQL
      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
    SQL
    DB[:conn].execute(sql, @name, @breed, @id)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(args)
    new(args).save
  end

  def self.new_from_db(row)
    new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT id, name, breed FROM dogs WHERE id = ?
    SQL
    DB[:conn].execute(sql, id).map { |row| new_from_db(row) }.first
  end

  def self.find(name:, breed:)
    sql = <<-SQL
    SELECT id, name, breed FROM dogs WHERE name = ? AND breed = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, name, breed).map { |row| new_from_db(row) }.first
  end

  def self.find_or_create_by(args)

    dog = find(args)

    !dog.nil? ? dog : create(args)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT id, name, breed
    FROM dogs
    WHERE name = ?
    LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map { |row| new_from_db(row) }.first
  end
end
