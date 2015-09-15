class CompareRunnersChart < RuntimeChart
  MAIN_COLOR = '#337ab7'
  MEAN_COLOR = '#000000'

  def initialize(runners)
    super('area')
    ## Fill with data
    # Show additionally category mean for every year we have runs for.
    runners.each do |runner|
      data = make_data(runner) do |run|
        run.duration
      end
      self.series(name: runner.name, data: data)#, color: MAIN_COLOR)
    end

    if runners.size == 1
      runner = runners.first
      data = make_data(runner) do |run|
        run.run_day_category_aggregate.mean_duration
      end
      #self.series(name: 'Category mean', data: data, color: MEAN_COLOR)

      data = make_data(runner) do |run|
        run.interim_times[1]
      end
      self.series(name: 'After 10 km', data: data, dashStyle: 'Dash')#, color: MAIN_COLOR)

      data = make_data(runner) do |run|
        run.interim_times[0]
      end
      self.series(name: 'After 5 km', data: data, dashStyle: 'Dot')#, color: MAIN_COLOR)

    end

    self.plot_options(
        area: {
            #stacking: 'normal',
            lineColor: '#666666',
            lineWidth: 1,
            marker: {
                lineWidth: 1,
                lineColor: '#666666'
            }
        }
    )
    self.chart(type: 'area')
  end

  def make_data(runner, &block)
    @all_run_days.map do |rd|
      run = runner.runs.find { |r| r.run_day == rd }
      duration = if run
                   yield(run)
                 else
                   nil
                 end
      [LazyHighCharts::OptionsKeyFilter.date_to_js_code(rd.date), duration]
    end
  end
end