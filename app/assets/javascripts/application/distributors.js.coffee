$ ->
  $('#new_distributor').submit ->
    $(this).find(':submit').hide()
    $(this).find('#distributor-submit-spinner').show()

  $('#login_distributor').submit ->
    $(this).find(':submit').hide()
    $(this).find('#login-submit-spinner').show()
  
  $('select#distributor_country').change (event) -> 
    select_wrapper = $('#distributor_state_code_wrapper')

    $('select', select_wrapper).attr('disabled', true)

    country_code = $(this).val()

    url = "/distributors/subregion_options?parent_region=#{country_code}"
    select_wrapper.load(url)
