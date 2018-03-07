### 数据
https://github.com/GreenNerd/ChineseHolidaysData

### 功能
- 判断一个日期是否为节假日\工作日？
```ruby
  ChineseHolidays.is_holiday?(Date.parse('2018-1-1')) # => true
  ChineseHolidays.is_holiday?(Date.parse('2018-1-4')) # => false
```
```ruby
  # 2018-4-8 is sunday
  ChineseHolidays.is_workday?(Date.parse('2018-4-8')) # => true
  ChineseHolidays.is_workday?(Date.parse('2018-1-4')) # => false
```
- 获取一年的节假日\工作日
```ruby
  ChineseHolidays.get_freedays_of(2018)
  ChineseHolidays.get_workdays_of(2018)
```
