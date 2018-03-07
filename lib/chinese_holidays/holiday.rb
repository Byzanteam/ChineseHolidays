module ChineseHolidays
  class Holiday
    attr_reader :name, :freedays, :workdays

    def initialize(name, freedays_range, workdays)
      @name = name
      @workdays = workdays.map { |day| parse_day(day) }
      @freedays = cal_freedays(freedays_range)
    end

    def cal_freedays(freedays_range)
      if freedays_range.size == 1
        [parse_day(freedays_range[0])]
      elsif freedays_range.size == 2
        (parse_day(freedays_range[0])..parse_day(freedays_range[1])).to_a
      end
    end

    def parse_day(day)
      Date.strptime(day, '%F')
    end
  end
end
