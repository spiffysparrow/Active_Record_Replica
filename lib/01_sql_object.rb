require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    first_row = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      LIMIT 1
    SQL
    first_row[0].map{ |item| item.to_sym }
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        attributes[column]
      end
      define_method("#{column}=") do |column_value|
        attributes[column] = column_value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    self.parse_all(rows)
  end

  def self.parse_all(results)
    results.map do |row|
      self.new(row)
    end
  end

  def self.find(id)
    row = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE id = ?
      LIMIT 1
    SQL
    return nil if row.empty?
    self.new(row.first)
  end

  def initialize(params = {})
    params.each do |column, value|
      raise "unknown attribute '#{column}'" unless self.class.columns.include?(column.to_sym)
      self.send("#{column}=".to_sym, value)
    end
  end

  def attributes
    @attributes ||= Hash.new
  end

  def attribute_values
    @attributes.values
  end

  def insert
    columns = attributes.keys.join(', ')
    question_marks = (["?"] * attribute_values.count).join(", ")
    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO #{self.class.table_name} (#{columns})
      VALUES (#{question_marks});
    SQL
    self.id = DBConnection.last_insert_row_id
  end


  def update
    attrs_and_question_marks = []
    values = []
    attributes.each do |attr, value|
      next if attr == :id
      values << value
      single_line = "#{attr} = ?"
      attrs_and_question_marks << single_line
    end
    attrs_and_question_marks = attrs_and_question_marks.join(', ')

    DBConnection.execute(<<-SQL, values, attributes[:id])
      UPDATE
        #{self.class.table_name}
      SET
        #{attrs_and_question_marks}
      WHERE
        id = ?
    SQL
  end

  def save
    if id
      update
    else
      insert
    end
  end
end
