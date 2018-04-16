require "chinese_holidays/version"
require "chinese_holidays/holiday"
require "rest-client"
require 'json'
require 'date'

module ChineseHolidays
  class NotSupportedYearError < Exception; end

  class << self
    def is_holiday?(date)
      get_freedays_of(date.year).include?(date)
    end

    def is_workday?(date)
      return false if is_holiday?(date)
      get_workdays_of(date.year).include?(date) || !(date.saturday? || date.sunday?)
    end

    def get_freedays_of(year)
      load_local_holidays

      if @local_workdays[year].empty?
        request_remote_holidays(year)
      end

      @local_freedays[year]
    end

    def get_workdays_of(year)
      load_local_holidays

      if @local_workdays[year].empty?
        request_remote_holidays(year)
      end

      @local_workdays[year]
    end

    def remove_local_cache
      root_path = File.expand_path '../..', __FILE__
      Dir.glob(root_path + '/lib/data/*.json').each do |cache_file|
        File.delete(cache_file)
      end
      true
    end

    private

    def load_local_holidays
      return if defined?(@local_freedays)

      @local_freedays = Hash.new([])
      @local_workdays = Hash.new([])

      Dir.glob(File.expand_path('../data/*.json', __FILE__)).flat_map do |file|
        year = file[/\d+\.json$/].to_i
        holidays_data = File.open(file) { |f| JSON.parse(f.read)['data'] }
        parse_holidays year, holidays_data
      end
    end

    def request_remote_holidays(year)
      begin
        response = RestClient.get(remote_holidays_url(year))
      rescue RestClient::Exception => e
        raise NotSupportedYearError.new("year: #{year}")
      end

      body = response.body
      holidays_data = JSON.parse(body)['data']
      parse_holidays year, holidays_data

      store_holidays(year, body)
    end

    def parse_holidays(year, holidays_data)
      holidays_data.map do |holiday_data|
        holiday = Holiday.new(holiday_data['name'], holiday_data['freedays_range'], holiday_data['workdays'])
        @local_freedays[year] |= holiday.freedays
        @local_workdays[year] |= holiday.workdays
      end
    end

    def store_holidays(year, data)
      root_path = File.expand_path '../..', __FILE__

      File.open(root_path + "/lib/data/#{year}.json", 'w') do |f|
        f.puts data
      end
    end

    def remote_holidays_url(year)
      "https://raw.githubusercontent.com/GreenNerd/ChineseHolidaysData/master/#{year}.json"
    end
  end
end
