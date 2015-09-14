class CompareRunnersChart < RuntimeChart
  def initialize(runners)
    super()
    ## Fill with data
    runners.each do |runner|
      data = @all_run_days.map do |rd|
        run = runner.runs.find { |r| r.run_day == rd }
        duration = run.try(:duration)
        [LazyHighCharts::OptionsKeyFilter.date_to_js_code(rd.date), duration]
      end
      self.series(name: runner.name,
                  data: data)
    end
    # Show additionally category mean for every year we have runs for.
    if runners.size == 1
      runner = runners.first
      data = @all_run_days.map do |rd|
        run = runner.runs.find { |r| r.run_day == rd }
        duration = if run
                     run.run_day_category_aggregate.mean_duration
                   else
                     nil
                   end
        [LazyHighCharts::OptionsKeyFilter.date_to_js_code(rd.date), duration]
      end
      self.series(name: 'Category mean',
                  data: data)
    end
  end
end