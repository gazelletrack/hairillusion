$ ->
  $('.grid-table').each (index, table) =>
    if ($(table).data('skip-load') != true)
      gridTable = new GridTable()
      gridTable.loadGridTable(table)

class window.GridTable
  sortIcons = {
    default: 'glyphicon glyphicon-sort',
    asc: 'glyphicon glyphicon-arrow-down',
    desc: 'glyphicon glyphicon-arrow-up',
  }

  @url = null
  gridTableParams = null
  gridTable = null
  loadDataCompleteCallback = null

  constructor: (params) ->
    gridTableParams = new GridTableParams(params)

  loadGridTable: (table, params = {}) ->
    gridTable = $(table)
    GridTable.url = gridTable.data('url')

    gridTable.find('thead th[data-sort="true"], .thead [data-sort="true"]').each (index, column) =>
      # Decorate the columns
      $column = $(column)
      $column.append(" <i class='#{sortIcons['default']}'></i>")

      if $column.data('default-sort')
        gridTableParams.setSort($column.data('field'), $column.data('default-sort'))

      # bind the click event
      $column.bind 'click', (event) =>
        gridTableParams.setSort($(event.currentTarget).data('field'), null)
        loadData()

    # monitor the filter controls for changes
    gridTable.find('select.row-filter').each (index, filter) =>
      $(filter).bind "change", (event) =>
        gridTableParams.setFilter($(filter).data('field'), $(filter).val())
        loadData()

    gridTable.find('input.row-filter').each (index, filter) =>
      timeout = null
      $(filter).bind "propertychange keyup input paste", (event) =>
        clearTimeout(timeout)
        timeout = setTimeout ( ->
          gridTableParams.setFilter($(filter).data('field'), $(filter).val())
          loadData()
        ), 500

    gridTable.find('.grid-pager #pagesize').each (index, elem) =>
      pageSizeSelect =
          '<select id="page-size-select">' +
          '<option value="5">5</option>' +
          '<option selected value="10">10</option>' +
          '<option value="25">25</option>' +
          '<option value="50">50</option>' +
          '<option value="100">100</option>' +
          '</select>'
      $(elem).append(pageSizeSelect)

      $(elem).find('#page-size-select').bind "change", (event) =>
        setPageSize($(event.currentTarget).val())

    loadData(params)

  @refresh: (callback) ->
    callback? callback
    loadData()

  setFilter: (key, value) ->
    gridTableParams.setFilter(key, value)
    if (gridTable != null)
      loadData()

  setSort: (column, direction) ->
    gridTableParams.setSort(column, direction)
    if (gridTable != null)
      loadData()

  loadDataComplete: (callback) ->
    loadDataCompleteCallback = callback

  setPage = (page) ->
    gridTableParams.page = page
    loadData()

  setPageSize = (size) ->
    gridTableParams.pageSize = size
    loadData()

  loadData = (params = {}) ->
    params.globalAjax ?= true

    $.ajax gridTableParams.buildUrl(GridTable.url),
      type: 'GET'
      global: params.globalAjax
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) -> 
      success: (data, textStatus, jqXHR) ->
        gridTable.find('tbody, .tbody').children().remove()

        if data.totals
          gridTable.find('thead tr.totals, .thead tr.totals').html(data.totals)

        for row in data.rows
          gridTable.find('tbody, .tbody').append(row)

        updateSortDisplay()
        updatePagerDisplay(data.total_rows)

        if (typeof(loadDataCompleteCallback) == "function")
          loadDataCompleteCallback()

  updatePagerDisplay = (total_rows) ->
    pager = gridTable.find('.grid-pager')
    first = $(pager).find('#first')
    previous = $(pager).find('#previous')
    next = $(pager).find('#next')
    last = $(pager).find('#last')
    display = $(pager).find('#pagedisplay')

    $(first).unbind 'click'
    $(previous).unbind 'click'
    $(next).unbind 'click'
    $(last).unbind 'click'

    last_page = Math.floor(total_rows / gridTableParams.pageSize)

    back_enabled = gridTableParams.page > 0
    forward_enabled = gridTableParams.page < last_page

    if (back_enabled)
      $(first).parent().removeClass('disabled');
      $(first).bind 'click', (event) =>
        event.preventDefault()
        setPage(0)

      $(previous).parent().removeClass('disabled');
      $(previous).bind 'click', (event) =>
        event.preventDefault()
        setPage(gridTableParams.page - 1)
    else
      $(first).parent().addClass('disabled');
      $(previous).parent().addClass('disabled');

    if (forward_enabled)
      $(next).parent().removeClass('disabled');
      $(next).bind 'click', (event) =>
        event.preventDefault()
        setPage(gridTableParams.page + 1)

      $(last).parent().removeClass('disabled');
      $(last).bind 'click', (event) =>
        event.preventDefault()
        setPage(last_page)
    else
      $(next).parent().addClass('disabled');
      $(last).parent().addClass('disabled');

    display.text("#{gridTableParams.page + 1} of #{last_page + 1} (#{total_rows})")

  updateSortDisplay = () ->
    field = gridTableParams.sortCol
    sortOrder = gridTableParams.sortOrder

    # update the column sort icon display for all columns
    gridTable.find('thead th[data-sort="true"], .thead [data-sort="true"]').each (i, c) =>
      value = $(c).data('field')

      if value == field
        switch sortOrder
          when 'asc'
            $(c).addClass('sorting')
            $(c).find('i').attr('class', sortIcons['asc'])
          when 'desc'
            $(c).addClass('sorting')
            $(c).find('i').attr('class', sortIcons['desc'])
          else
            $(c).removeClass('sorting')
            $(c).find('i').attr('class', sortIcons['default'])
      else
        $(c).removeClass('sorting')
        $(c).find('i').attr('class', sortIcons['default'])

  class GridTableParams
    sortCol: ''
    sortOrder: ''
    filter: {}
    page: 0
    pageSize: 10

    constructor: (params) ->
      if (params?)
        if ('sortCol' of params)
          @sortCol = params['sortCol']
        if ('sortOrder' of params)
          @sortOrder = params['sortOrder']
        if ('filter' of params)
          @filter = params['filter']
        if ('page' of params)
          @page = params['page']
        if ('pageSize' of params)
          @pageSize = params['pageSize']

    setSort: (column, direction) ->
      @page = 0
      if (@sortCol == column)
        order = if @sortOrder == 'asc' then 'desc' else 'asc'
      else
        order = 'asc'

      @sortOrder = direction || order
      @sortCol = column

    setFilter: (column, value) ->
      @page = 0

      if (value.trim().length == 0)
        delete @filter[column]
      else
        @filter[column] = value

    buildUrl: (baseUrl) ->
      url = baseUrl

      url += if (/\?/.test(url)) then '&' else '?'
      url += ('page=' + @page)
      url += ("&page_size=" + @pageSize)
      url += ("&sort=" + @sortCol)
      url += ("&sort_order=" + @sortOrder)

      for k,v of @filter
        url += ('&' + k + '=' + v)

      url
