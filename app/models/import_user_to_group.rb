class ImportUserToGroup < Import
  attr_accessor :extname, :original_file, :users_saved, :users_failed

  def call(group)
    @users_saved = []
    @users_failed = []
    read_items do |row, i|
      user = User.where('LOWER(login) = ? ', row[0].to_s.downcase).first
      if user
        unless user.groups.include?(group)
          user.groups << group
        end
        @users_saved<< row[0]
      else
        @users_failed<< "line: #{i}: #{row[0]}"
      end
    end
  end

  def read_items
    i = 0
    read_rows do |row|
      i+= 1
      yield row, i if block_given?
    end
  end

  def is_csv?
    @extname == '.csv'
  end

  def is_xls?
    @extname == '.xls'
  end

  def is_xlsx?
    @extname == '.xlsx'
  end

  def read_rows
    if is_csv?
      csv_options = {:headers => false}
      csv_options[:encoding] = settings['encoding'].to_s.presence || 'UTF-8'
      separator = settings['separator'].to_s
      csv_options[:col_sep] = separator if separator.size == 1
      wrapper = settings['wrapper'].to_s
      csv_options[:quote_char] = wrapper if wrapper.size == 1

      CSV.foreach(filepath, csv_options) do |row|
        yield row if block_given?
      end
    elsif is_xls? || is_xlsx?
      roo_csv = is_xls?  ? Roo::Excel.new(original_file.tempfile) : Roo::Excelx.new(original_file.tempfile)
      sheet = roo_csv.sheet(0)
      sheet.each_with_index do |row, idx|
        yield row if block_given?
      end
    else
      return
    end
  end
end