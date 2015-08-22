class RunnerDatatable < AjaxDatatablesRails::Base
  def_delegators :@view, :runner_path, :link_to

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['Runner.first_name', 'Runner.last_name', 'Runner.club_or_hometown', 'Runner.sex']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['Runner.first_name', 'Runner.last_name', 'Runner.club_or_hometown']
  end

  private

  def data
    records.map do |record|
      [
        record.first_name,
        record.last_name,
        record.club_or_hometown,
        record.sex,
        record.runs.size,
        link_to('Show', runner_path(record))
      ]
    end
  end

  def get_raw_records
    Runner.all.includes(:runs)
  end

  # ==== Insert 'presenter'-like methods below if necessary
end
