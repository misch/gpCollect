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
    )
  )

  # Only search after a minimum of 3 characters were entered
  $(".dataTables_filter input")
  .unbind() # Unbind previous default bindings
  .bind("input", (e) ->  # Bind our desired behavior
    # If the length is 3 or more characters, or the user pressed ENTER, search
    if(this.value.length >= 3 || e.keyCode == 13)
      # Call the API search function
      dt.search(this.value).draw()
    # Ensure we clear the search if they backspace far enough
    if(this.value == "")
      dt.search("").draw()
  )
  $('a[data-forget-runners]').on('click', (e) ->
    e.preventDefault()
    Cookies.remove('remembered_runners')
  )
