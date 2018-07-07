require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    return @columns unless @columns.nil?
    
      cols = DBConnection.execute2(<<-SQL).first
        SELECT
          *
        FROM
          #{self.table_name}
      SQL
      
      @columns = cols.map(&:to_sym)
        
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do
        self.attributes[col] 
      end
      define_method("#{col}=") do |val|
        self.attributes[col] = val
      end 
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name ||= self.name.underscore.pluralize
  end

  def self.all
    # ...
    self.parse_all(DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    )
  end

  def self.parse_all(results)
    # ...
    results.map{|hash| self.new(hash)}
  end

  def self.find(id)
    # ...
    result = (DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = #{id}
    SQL
  ).first
  return result.nil? ? nil : self.new(result)
  end

  def initialize(params = {})
    # ...
    params.each do |k, v|
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k.to_sym)
      send("#{k}=", v)
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    # @attributes.values
    self.class.columns.map do |col|
      @attributes[col]
    end
  end
  # 
  # def missing_method(name, *args)
  #   str = name.
  # end

  def insert
    # debugger
    col_names = self.class.columns.drop(1).join(',')
    # question_marks = ["?"] * col_names.length].join(',')
    DBConnection.execute(<<-SQL)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{attribute_values.drop(1).to_s[1...-1]})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
    values = self.class.columns.map do |col|
      "#{col} = #{@attributes[col]}"
    end.join(',')
    # debugger
    DBConnection.execute(<<-SQL)
    UPDATE
      #{self.class.table_name}
    SET
      #{values}
    WHERE
      #{self.id} = #{self.class.table_name}.id
    SQL
  end

  def save
    # ...
    row = self.class.find(self.id)
    if row
      update
      true
    else
      insert
      true
    end
    false
  end
end
