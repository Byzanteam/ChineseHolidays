require "spec_helper"

RSpec.describe ChineseHolidays do
  before do
    url_regex = %r(https://raw.githubusercontent.com/GreenNerd/ChineseHolidaysData/master/.*json)
    stub_request(:get, url_regex).to_return(status: 404)
  end

  let(:holiday_2018_url) { "https://raw.githubusercontent.com/GreenNerd/ChineseHolidaysData/master/2018.json" }

  before do
    api_body = <<-DOC
      {"data":[{"name":"new_year_s_day","freedays_range":["2018-01-01"],"workdays":[]},{"name":"spring_festival","freedays_range":["2018-02-15","2018-02-21"],"workdays":["2018-02-11","2018-02-24"]},{"name":"qingming_festival","freedays_range":["2018-04-05","2018-04-07"],"workdays":["2018-04-08"]},{"name":"labor_day","freedays_range":["2018-04-29","2018-05-01"],"workdays":["2018-04-28"]},{"name":"dragon_boat_festival","freedays_range":["2018-06-18"],"workdays":[]},{"name":"mid_autumn_festival","freedays_range":["2018-09-24"],"workdays":[]},{"name":"national_day","freedays_range":["2018-10-01","2018-10-07"],"workdays":["2018-09-29","2018-09-30"]}]}
    DOC

    stub_request(:get, holiday_2018_url).to_return(status: 200, body: api_body.strip)
  end

  before do
    begin
      ChineseHolidays.remove_instance_variable(:@local_freedays)
      ChineseHolidays.remove_instance_variable(:@local_workdays)
    rescue NameError
    end
  end

  context 'request remote holidays' do
    before do
      root_path = File.expand_path '../..', __FILE__
      file_path = "#{root_path}/lib/data/2018.json"
      File.delete(file_path) if File.exist?(file_path)
    end

    it 'request is made once' do
      ChineseHolidays.is_holiday?(Date.parse('2018-1-1'))
      expect(a_request(:get, holiday_2018_url)).to have_been_made.once
    end

    it 'stores data to local file' do
      ChineseHolidays.is_holiday?(Date.parse('2018-1-1'))
      file_path = "#{File.expand_path '../..', __FILE__}/lib/data/2018.json"
      expect(File.exist?(file_path)).to be_truthy
    end
  end

  it '#is_holiday? is true' do
    expect(ChineseHolidays.is_holiday?(Date.parse('2018-1-1'))).to be_truthy
  end

  it '#is_holiday? is false' do
    expect(ChineseHolidays.is_holiday?(Date.parse('2018-1-4'))).to be_falsey
  end

  it '#is_workday? is true' do
    # 2018-4-8 is sunday
    expect(ChineseHolidays.is_workday?(Date.parse('2018-4-8'))).to be_truthy
  end

  it '#is_workday? is false' do
    expect(ChineseHolidays.is_workday?(Date.parse('2018-1-1'))).to be_falsey
  end

  it 'raise exception' do
    expect {
      ChineseHolidays.is_holiday?(Date.parse('2017-1-1'))
    }.to raise_error(ChineseHolidays::NotSupportedYearError)
  end
end
