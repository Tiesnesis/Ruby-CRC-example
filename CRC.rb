require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

class CrcValidator
   attr_accessor :message, :generator, :appendable
   @message = []
   @generator = []
   @appendable = []

  def initialize(message, generator, appendable)
    @message = message
    @generator = generator
    @appendable = appendable
  end

  def run
    data = []
    data_in_buffer = 0
    (0...@message.size).each do |index|
      data.insert(data_in_buffer, @message[index].to_i)
      data_in_buffer += 1
      if data.size == @generator.size
        print "\n\nCurrent data: #{data} end pos #{index}"
        print "\ndivide with: #{@generator}"
        tmp_result = []
        (0...data.size).each do |tmp_index|
          value = ((data[tmp_index].to_i != @generator[tmp_index].to_i) ? 1 : 0)
          tmp_result.insert(tmp_index, value)
        end
        # Remove zeros from the beginning
        print "\ntmp result: #{tmp_result}"
        x_index = 0
        while x_index < tmp_result.size && tmp_result[x_index] == 0
          x_index += 1
        end
        data = []
        d_index = 0
        (x_index...tmp_result.size).each do |y_index|
          data.insert(d_index, tmp_result[y_index])
          d_index += 1
        end
        data_in_buffer = data.size
        print "\ntmp result stripped: #{data}"
      end
    end
    delta = (data.size - @appendable.size).abs
    crc = []
    (1..delta).each do |x_index|
      crc.insert(x_index-1, 0)
    end
    print "\nCRC: #{crc}\n"
    xi_index = crc.size
    (0...data.size).each do |x_index|
      crc.insert(xi_index, data[x_index])
      xi_index += 1
    end
    print "\nCRC: #{crc}\n"
  end



end

def string_to_array(string)
  array = []
  (0...string.size).each do |index|
    array.insert(index, string[index].to_i)
  end
  array
end

def array_append_array(a, b)
  index = 0
  (a.size...(a.size + b.size)).each do |x_index|
    a.insert(x_index, b[index].to_i)
    index += 1
  end
  a
end

class Optparse
  CODES = %w(iso-2022-jp shift_jis euc-jp utf8 binary).freeze
  CODE_ALIASES = { 'jis' => 'iso-2022-jp', 'sjis' => 'shift_jis' }.freeze

  def self.parse(args)
    options = OpenStruct.new

    options.m = '111100101'
    options.g = '101101'
    options.a = '01010'

    opt_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: testRun.rb [options]'

      opts.separator ''
      opts.separator 'Specific options:'

      opts.on('-m', '--message [string]',
              'Message') do |m|
        options.m = m
      end

      opts.on('-g', '--generator [string]',
              'Generator') do |g|
        options.g = g
      end

      opts.on('-a', '--appendable [string]',
              'Appendable') do |a|
        options.a = a
      end

      opts.separator ''
      opts.separator 'Common options:'
      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end
end

options = Optparse.parse(ARGV)
message = string_to_array(options.m)
generator = string_to_array(options.g)
appendable = string_to_array(options.a)

message = array_append_array(message, appendable)

print "\nMessage" + message.to_s
print "\nGenerator" + generator.to_s
print "\nAppendable" + appendable.to_s

crc_validator = CrcValidator.new(message, generator, appendable)
crc_validator.run
