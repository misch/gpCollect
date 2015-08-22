$ ->
  $('#runners-datatable').DataTable({
    processing: true,
    serverSide: true,
    pageLength: 50,
    ajax: $('#users-table').data('source')
    pagingType: 'full_numbers'
  });