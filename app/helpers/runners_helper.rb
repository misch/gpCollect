module RunnersHelper

  def ruby_to_java_date(date)
    "Date.UTC(#{date.year}, #{date.month}, #{date.day})"
    end
end
