require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    question_marks = params.keys.map{ |key| "#{key} = ?" }
    question_marks = question_marks.join(" AND ")
    rows = DBConnection.execute(<<-SQL, params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{question_marks}
    SQL
    self.parse_all(rows)
  end
end

class SQLObject
  extend Searchable
end
