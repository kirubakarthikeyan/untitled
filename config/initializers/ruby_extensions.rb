class String
  def to_bool
    !(blank? or eql?('false') or eql?('0'))
  end
  def parse_json
    JSON.parse(self)
  end

  def dj
    begin
      self.parse_json.dj
    rescue JSON::ParserError
      if time = (Time.parse(self) rescue nil)
        return time.dj
      end
      puts self
    end
  rescue => e
    e.dj
    puts self
  end

  def to_slug
    return parameterize.underscore
  end

  def is_valid_email?
    match?(URI::MailTo::EMAIL_REGEXP)
  end
end

module Boolean
  def to_bool
    self
  end

  def is_bool?
    true
  end
end
TrueClass.class_eval do
  include Boolean
end
FalseClass.class_eval do
  include Boolean
end
NilClass.class_eval do
  def to_bool
    false
  end
end

Object.class_eval do
  def to_bool
    true
  end

  def is_bool?
    false
  end
end

class Hash
  def fetch! key, *args, &block
    value = fetch(key, *args, &block)
    if !self.has_key?(key)
      self[key] = value
    end
    value
  end

  def bury!(keys, value)
    key = keys.first
    if keys.length == 1
      self[key] = value
    else
      self[key] = {} unless self[key]
      self[key].bury!(keys.slice(1..-1), value)
    end
    self
  end
end

class Array
  def subset? input_array
    (input_array - self).empty?
  end

  def similar? input_array
    size = self.size
    (input_array.size.eql?(size) && (self & input_array).size.eql?(size))
  end

  def except *values
    (self - values)
  end

  def deep_stringify_keys
    object = {array: self}
    object.deep_stringify_keys['array']
  end

  def strip
    select {|e| e }
  end

  def avg
    sum / size.to_f
  end

  def has_any_of? array
    self.any? {|item| array.include?(item) }
  end

  def pop_random
    self.delete_at(rand(self.size))
  end

  def with_indifferent_access
    {array: self}.with_indifferent_access[:array]
  end
end

class Object
  def dj
    puts to_json
  end

  def ps
    puts(self)
  end

  def get_instance_variable name
    instance_variable_get("@#{name}")
  end
  def slice_instance_variables *names
    hash = {}
    names.each do |name|
      hash[name] = get_instance_variable(name)
    end
    hash
  end
end

class Time
  def ist
    self.in_time_zone('Asia/Kolkata')
  end

  def dj
    # self.class may not be equal to 'Time'
    time_instance = self.to_time

    puts "UTC: #{time_instance.utc.to_s(:debug)}"
    puts "IST: #{time_instance.ist.to_s(:debug)}"
  end

  def elapsed_time
    ActiveSupport::Duration.since(self)
  end

  def to_relative
    now = Time.now
    if self < now
      ActiveSupport::Duration.build(now-self)
    else
      ActiveSupport::Duration.build(self-now)
    end
  end

  def is_before? time
    self < time
  end
  def is_after? time
    self > time
  end
  def on_or_before? time
    self <= time
  end
  def on_or_after? time
    self >= time
  end
  def is_within? from, to
    self.on_or_after?(from) && self.on_or_before?(to)
  end
  def is_between? from, to
    self.is_after?(from) && self.is_before?(to)
  end
end

ActiveSupport::TimeWithZone.class_eval do
  def dj
    to_time.dj
  end
end

ActiveSupport::Duration.class_eval do
  def self.since time
    ActiveSupport::Duration.build(Time.now-time)
  end

  # To milliseconds
  def to_ms
    (to_f * 1000).round(2)
  end
end

class URI::Generic
  def is_link?
    self.kind_of?(URI::HTTP) or self.kind_of?(URI::HTTPS)
  end
end

# if defined?(IRB::Irb)
#   IRB::Irb.class_eval do
#     alias_method :original_handle_exception, :handle_exception
#     def handle_exception e
#       if e.backtrace.any? {|path| path.include?('slate') }
#         e.dj
#       else
#         original_handle_exception(e)
#       end
#     end
#   end
# end

Class.class_eval do
  def subclass_of? klass
    self < klass
  end

  def self.exists?(class_name)
    klass = Module.const_get(class_name)
    return klass.is_a?(Class)
  rescue NameError
    return false
  end
end

Exception.class_eval do
  def log
    log_data = {
      exception: get_log_data
    }
    Logger.new('log/exceptions.log').error(log_data)
  end

  def get_log_data
    {
      message: message,
      klass: self.class.name,
      backtrace: backtrace
    }
  end

  def notify_slack message = "Oops, what was that?", context: {}
    payload_data = {
      message: message,
      exception: get_log_data,
      context: context
    }
    code_block = Slack.get_code_block(payload_data.to_json)
    Dobby.slack(code_block)
  end
end

ActiveRecord::Migration.class_eval do
  def create_table *args, **params
    params[:id] = :uuid
    super
  end

  def create_join_table *args, **params
    params[:column_options] = { type: :uuid }
    super
  end
end

Tempfile.class_eval do
  def name
    File.basename(path)
  end
end

ActiveModel::Errors.class_eval do
  def to_h *args
    to_hash(*args)
  end

  def get_form_data
    hash = to_hash(true)
    hash.each do |key, value|
      if value.is_a?(Array)
        hash[key] = value.first
      end
    end
    hash
  end
end
