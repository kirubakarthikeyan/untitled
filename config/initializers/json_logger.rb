class JsonLogger < Logger
  def initialize file_path, *args
    super
    validate_file_path!(file_path)
    @tag_data = {}
    self.formatter = json_formatter
  end

  def tag data
    @tag_data = data
    self
  end

  def validate_file_path! file_path
    if !file_path.end_with?(".log")
      raise "Log file name '#{file_path}' should end with '.log'"
    end
  end

  def json_formatter
    proc do |severity, time, progname, msg|
      hash = {
        level: severity,
        timestamp: time.strftime("%Y-%m-%d %H:%M:%S.%3N"),
        pid: $$,
      }
      if progname.present?
        hash[:program] = progname
      end
      hash[:data] = msg
      if @tag_data.present?
        hash[:tags] = @tag_data
      end
      "#{hash.to_json}\n"
    end
  end

  def exception e
    error({exception: e.get_log_data})
  end
end
