module RunnersHelper
  def ruby_to_javascript_date(date)
    # Tricky: months are 1 based in ruby, but 0 based in javascript
    "Date.UTC(#{date.year}, #{date.month - 1}, #{date.day})"
  end
end
