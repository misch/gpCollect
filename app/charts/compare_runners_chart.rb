class CompareRunnersChart < LazyHighCharts::HighChart
  def initialize(runners)
    super('graph')
    set_options

    ## Fill with data
    all_run_days = RunDay.all
    runners.each do |runner|
      data = all_run_days.map do |rd|
        run = runner.runs.find { |r| r.run_day == rd }
        duration = run.try(:duration)
        [LazyHighCharts::OptionsKeyFilter.date_to_js_code(rd.date), duration]
      end
      self.series(name: runner.name,
                  data: data)
    end
    # Show additionally category mean for every year we have runs for.
    if runners.size == 1
      self.series(name: 'Category mean',
                  data: runners.first.runs.map { |r| [LazyHighCharts::OptionsKeyFilter.date_to_js_code(r.run_day.date),
                                                      r.run_day_category_aggregate.mean_duration] })
    end
  end

  private

  def set_options
    self.title(text: nil)
    x_axis_ticks = RunDay.all.pluck(:date).map { |run_day_date| LazyHighCharts::OptionsKeyFilter.date_to_js_code(run_day_date) }
    self.xAxis(type: "datetime",
               tickPositioner: "function() {
                 var ticks = [#{generate_json_from_array(x_axis_ticks)}];
                    //dates.info defines what to show in labels
                    //apparently dateTimeLabelFormats is always ignored when specifying tickPosistioner
                    ticks.info = {
                   unitName: 'year', //unitName: 'day',
                       higherRanks: {} // Omitting this would break things
                    };
                    return ticks;
                }".js_code)
    self.yAxis(type: 'datetime', # y-axis will be in milliseconds
               dateTimeLabelFormats: {
                   # force all formats to be hour:minute:second
                   second: '%H:%M:%S',
                   minute: '%H:%M:%S',
                   hour: '%H:%M:%S',
                   day: '%H:%M:%S',
                   week: '%H:%M:%S',
                   month: '%H:%M:%S',
                   year: '%H:%M:%S'
               },
               shared: true)
    self.tooltip(
        useHTML: true,
        formatter: "function() {
          return '<b>' + this.series.name +'</b><br/>' +
              Highcharts.dateFormat('%e. %b. %Y', new Date(this.x)) + '<br/>' +
              Highcharts.dateFormat('%H:%M:%S', new Date(this.y));
        }".js_code
    )
    self.legend(layout: 'horizontal')
  end

  ### Copied private helpers from lazy_high_charts/lib/lazy_high_charts/layout_helper.rb

  def generate_json_from_value value
    if value.is_a? Hash
      %|{ #{generate_json_from_hash value} }|
    elsif value.is_a? Array
      %|[ #{generate_json_from_array value} ]|
    elsif value.respond_to?(:js_code) && value.js_code?
      value
    else
      value.to_json
    end
  end

  def generate_json_from_array array
    array.map { |value| generate_json_from_value(value) }.join(",")
  end
end