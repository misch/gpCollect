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
    $('a[data-remember-runner]').on('click', (e) ->
      e.preventDefault()
      id = $(this).data("remember-runner")
      runner_array = get_remembered_runners()
      index_of_id = runner_array.indexOf(id)
      if index_of_id != -1
        runner_array.splice(index_of_id, 1) # Removes id from array.
      else
        runner_array.push(id)
      update_remember_runner_icon(id, runner_array, $(this).find('i'))
      Cookies.set('remembered_runners', runner_array)
    )
    $('a[data-remember-runner]').each ->
      id = $(this).data("remember-runner")
      runner_array = get_remembered_runners()
      update_remember_runner_icon(id, runner_array, $(this).find('i'))
  )

  get_remembered_runners = ->
    Cookies.getJSON('remembered_runners') || []

  update_remember_runner_icon = (id, runner_array, icon) ->
    if id in runner_array
      icon.removeClass('fa-star')
      icon.addClass('fa-star-o')
    else
      icon.removeClass('fa-star-o')
      icon.addClass('fa-star')

  # Only search after a minimum of 3 characters were entered
  searchWait = 0
  searchWaitInterval = null
  $('.dataTables_filter input')
    .unbind() # Unbind previous
    .bind('keyup', (e) ->
      item = $(this)
      searchWait = 0
      if !searchWaitInterval
        searchWaitInterval = setInterval(->
          if (item.val().length > 3 or item.val() == '') and searchWait >= 3
            clearInterval(searchWaitInterval)
            searchWaitInterval = null
            searchTerm = $(item).val()
            dt.search(searchTerm).draw()
            searchWait = 0
          searchWait++
        ,200);
  )

  $('a[data-forget-runners]').on('click', (e) ->
    e.preventDefault()
    Cookies.remove('remembered_runners')
  )
