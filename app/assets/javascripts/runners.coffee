$ ->
  source = $('#runners-datatable').data('source')
  dt = $('#runners-datatable').DataTable({
    processing: true,
    serverSide: true,
    ajax: source,
    columns: [
      null,
      null,
      null,
      null,
      null,
      null,
      { orderable: false },
      { orderable: false }
    ]
  })