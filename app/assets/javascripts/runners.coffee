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
    # Whenever the 'remember link is clicked, run this:
    $('a[data-remember-runner]').on('click', (e) ->
      e.preventDefault()
      id = $(this).data("remember-runner")
      runner_hash = get_remembered_runners()
      if runner_hash[id]
        # Remove id from remembered runners.
        delete runner_hash[id]
      else
        name = $(this).data("remember-runner-name")
        runner_hash[id] = name
      update_remember_runner_icon(id, runner_hash, $(this).find('i'))
      update_remembered_runner_panel(runner_hash)
      Cookies.set('remembered_runners', runner_hash)
    )
    $('a[data-remember-runner]').each ->
      id = $(this).data("remember-runner")
      runner_hash = get_remembered_runners()
      update_remember_runner_icon(id, runner_hash, $(this).find('i'))
  )

  get_remembered_runners = ->
    Cookies.getJSON('remembered_runners') || {}

  update_remember_runner_icon = (id, runner_hash, icon) ->
    selected_icon = 'fa-star'
    deselected_icon = 'fa-star-o'
    if runner_hash[id]
      icon.removeClass(deselected_icon)
      icon.addClass(selected_icon)
    else
      icon.removeClass(selected_icon)
      icon.addClass(deselected_icon)

  update_remembered_runner_panel = (runner_hash) ->
    panel = $('#remembered-runners-panel .panel-body')
    dismiss_button = '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>'
    $.each(runner_hash, (id, name) ->
      panel.append('<div class="alert alert-info alert-dismissable">'+id + name + dismiss_button + '</span> ')
    )

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
