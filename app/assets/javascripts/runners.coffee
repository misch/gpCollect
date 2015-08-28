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

  dt.on('draw', ->
    console.log('draw')
    $('a[data-remember-runner]').on('click', (e) ->
      e.preventDefault()
      id = $(this).data("remember-runner")
      runner_array = Cookies.getJSON('remembered_runners')
      if (!runner_array?)
        runner_array = []
      runner_array.push(id)
      Cookies.set('remembered_runners', runner_array)
      console.log(runner_array)
    )
  )