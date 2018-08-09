// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require jquery
//= require jquery_ujs
//= require ckeditor-jquery
//= require bootstrap.min 
//= require_tree ./application/
//= require bootstrap-datepicker

function onChangeCounty(from)
{
	if(from == 'forum_country')
	{
		country = $("#forum_country").val(); 
	}
	else
	{
		country = $("#search_country").val(); 
	} 
	$.ajax({
    	type: "GET",
        url: "/get_states?parent_region="+ country  ,
        dataType: "script",
    });
}

function onChangeAddressCountry(from)
{ 
	if(from == "billing")
	{
		country = $("#billing_country").val(); 
	}
	else
	{
		country = $("#billing_shipping_country").val(); 
	}
	
	$.ajax({
    	type: "GET",
        url: "/get_billing_states?parent_region="+ country+"&from="+from ,
        dataType: "script",
    });
}

function onChangeShippingAddressCountry()
{ 
	$.ajax({
    	type: "GET",
        url: "/get_shipping_states?parent_region="+ $("#billing_shipping_country").val() ,
        dataType: "script",
    }); 
}

function updateShippingAddress()
{   
	$("#firstNameField").val($("#shippingFirstName").val() );
	$("#lastNameField").val($("#shippingLastname").val());
	$("#countryField").val($("#billing_shipping_country").val());
	$("#stateField").val($("#shipping_value_state").val());
	
	$("#address1Field").val($("#shippingAddress").val());
	$("#address2Field").val($("#shippingAddress2").val());
	$("#cityField").val($("#shippingCity").val());
	$("#zipField").val($("#shippingZip").val());
	$("#phoneField").val($("#shippingPhone").val());
	onChangeEmailField();
 
	$("#shippingPrefDiv").html("");
	$("#shipment_name").val(""); 
	
	$("#shipment_car").val(""); 
}

function onChooseCarier(thiss)
{  
	$.ajax({
          type: "GET",
          url: "/set_shipping_values",
          dataType: "script",
          data:{ value: $(thiss).val()}
     	});
}	

function setCarrier()
{ 
	val = null;
	$('.shippingRateCB').each(function() {
		if(this.checked)
		{
			val = $(this).val();
		}
	});
}

function onChooseDCarier(thiss)
{  
	$.ajax({
          type: "GET",
          url: "/set_setting_carriers",
          dataType: "script",
          data:{ value: $(thiss).val()}
     	});
}

function onCheckShipSelected(e)
{   
	if($("#shipment_car").val() == "")
	{
		alert("please choose Carrier to continue");
	}
	else
	{
		$("#firstNameField").val($("#shippingFirstName").val() );
		$("#lastNameField").val($("#shippingLastname").val());
		$("#countryField").val($("#billing_shipping_country").val());
		$("#stateField").val($("#shipping_value_state").val());
		
		$("#address1Field").val($("#shippingAddress").val());
		$("#address2Field").val($("#shippingAddress2").val());
		$("#cityField").val($("#shippingCity").val());
		$("#zipField").val($("#shippingZip").val());
		$("#phoneField").val($("#shippingPhone").val());
		onChangeEmailField();
		$("#shipContinueButton").click();  
	}
}



function onClickProduct(from) 
{
  $.ajax({
    	type: "GET",
        url: "/product_details?type="+from,
        dataType: "script",
    });
}


function onClickAddToCart(input_id, e, qty) {

	if ((input_id == 'small_product_col_dp' || input_id == 'saf_col_dp' || input_id == 'swof_col_dp' || input_id == 'c2_col_dp' || input_id == 'c3_col_dp' || input_id == 'c4_col_dp' || input_id == 'combo_col_dp' || input_id == 'c5_col_dp' || input_id == 'c4_col_dp' || input_id == 'small_product_col_dp' || input_id == 'large_product_col_dp' ) && $("#" + input_id + " option:selected").text() == "Select a color") {
		alert("Please choose color");
		e.preventDefault();
	} else {
		if (input_id == "index_small" || input_id == "index_large") {
			if ($("#" + input_id + " option:selected").text() == "Select a color") {
				alert("Please choose color");
				e.preventDefault();
			} else {
				if (qty == 0) {
					alert("Please choose quantity");
					e.preventDefault();
				} else {
					document.getElementById('form_' + input_id).submit();
				}
			}
		} else {
			if (qty == 0) {
				alert("Please choose quantity");
				e.preventDefault();
			} else {
				document.getElementById('form_' + input_id).submit();
			}
		}
	}
}


function onRemoveProduct(name)
{
	var r = confirm("are you sure want to remove this product from cart?");
	if(r==true)
	{
		window.location.href = "/remove_product_from_cart?name="+name;
    }; 
}

function onChangeBillingCounty(from)
{
	if(from == 'billing_country')
	{
		country = $("#billing_country_id").val(); 
	}
	else
	{
		country = $("#search_country").val(); 
	} 
	$.ajax({
    	type: "GET",
        url: "/get_states?parent_region="+ country+"from="+from ,
        dataType: "script",
    });
}

function onChangeShippingHOCB()
{
	if(document.getElementById('billing_shipping_address').checked == false)
	{ 
		$("#same_shipping_address").val("0");
		$("#shipping_firstname").removeAttr('disabled');
		$("#shipping_lastname").removeAttr('disabled');
		$("#billing_shipping_country").removeAttr('disabled');
		$("#shipping_address").removeAttr('disabled');
		$("#shipping_address_2").removeAttr('disabled');
		
		$("#shipping_city").removeAttr('disabled');
		$("#shipping_zip").removeAttr('disabled');
		$("#shipping_phone").removeAttr('disabled'); 
		$("#shipment_state").removeAttr('disabled'); 
	}
	else
	{
		$("#same_shipping_address").val("1");
		$("#shipping_firstname").attr('disabled','disabled');
		$("#shipping_lastname").attr('disabled','disabled');
		$("#billing_shipping_country").attr('disabled','disabled');
		$("#shipping_address").attr('disabled','disabled');
		$("#shipping_address_2").attr('disabled','disabled');
		
		$("#shipping_city").attr('disabled','disabled');
		$("#shipping_zip").attr('disabled','disabled');
		$("#shipping_phone").attr('disabled','disabled');
		$("#shipment_state").attr('disabled','disabled'); 
	} 
}
 
function onChangeShippingCB()
{	
	if(document.getElementById('billing_shipping_address').checked == false)
	{  		 
		$("#billing_firstname").val("");
		$("#billing_lastname").val(""); 
		$("#billing_country").val("");
		$("#billing_state").val("");
		$("#billing_address").val("");
		$("#billing_address_2").val("");
		$("#billing_city").val("");
		$("#billing_zip").val("");
		$("#billing_phone").val("");
		
		$("#same_shipping_address").val("0");
		$("#billing_firstname").removeAttr('disabled');
		$("#billing_lastname").removeAttr('disabled');
		$("#billing_country").removeAttr('disabled');
		$("#billing_address").removeAttr('disabled');
		$("#billing_address_2").removeAttr('disabled');
		
		$("#billing_city").removeAttr('disabled');
		$("#billing_zip").removeAttr('disabled');
		$("#billing_phone").removeAttr('disabled'); 
		$("#billing_state").removeAttr('disabled'); 
	}
	else
	{  
		$("#billing_firstname").val($("#shippingFirstName").val());
		$("#billing_lastname").val($("#shippingLastname").val()); 
		$("#billing_country").val($("#billing_shipping_country").val());
		$("#billing_state").val($("#shipping_value_state").val()); 
		$("#billing_address").val($("#shippingAddress").val());
		$("#billing_address_2").val($("#shippingAddress2").val()); 
		$("#billing_city").val($("#shippingCity").val());
		$("#billing_zip").val($("#shippingZip").val());		  
		$("#billing_phone").val($("#shippingPhone").val());				
	
		$("#same_shipping_address").val("1");
		$("#billing_firstname").attr('disabled','disabled');
		$("#billing_lastname").attr('disabled','disabled');
		$("#billing_country").attr('disabled','disabled');
		$("#billing_address").attr('disabled','disabled');
		$("#billing_address_2").attr('disabled','disabled');
		
		$("#billing_city").attr('disabled','disabled');
		$("#billing_zip").attr('disabled','disabled');
		$("#billing_phone").attr('disabled','disabled');
		$("#billing_state").attr('disabled','disabled'); 
	} 
}

function onChangeEmailField()
{
	$("#emailField").val($("#billing_email").val());
}

function onSubmitClubOrderCheckout(event)
{ 
	event.preventDefault();  
	$("#submitButton").attr('disabled','disabled');
	color = $("#color-field").val(); 
	if(!color)
	{
		alert("Please choose color");
		$("#submitButton").removeAttr('disabled');
		return;
	}
	else
	{
		if(document.getElementById('same_address').checked == false)
		{ 
			if( !$("#billing_firstname").val() || !$("#billing_lastname").val() || !$("#billing_country_code").val() || !$("#billing_address").val() || !$("#billing_city").val() || !$("#billing_state").val() || !$("#billing_zip").val() || !$("#billing_phone").val() || !$("#billing_email").val() || !$("#card_number").val() || !$("#card_name").val() || !$("#card_cvv").val() || !$("#card_holder_name").val() )
			{ 
				
				alert("Please fillup shipping details.");
				$("#submitButton").removeAttr('disabled');
				event.preventDefault(); 
				return;
			}
			
			if((document.getElementById('same_address').checked)) 
			{ 
				document.getElementById('scheckoutForm').submit();
				$("#submitButton").attr('disabled','disabled');
			}
			else
			{
				errors = "";
				if( !$("#shipping_firstname").val() )
				{
					errors += "Please enter shipping first name \n";
				}
				if( !$("#shipping_lastname").val() )
				{
					errors += "Please enter shipping last name \n";
				}
				if( !$("#shipping_firstname").val() )
				{
					errors += "Please enter shipping first name \n";
				}
				if( !$("#shipping_firstname").val() )
				{
					errors += "Please enter shipping first name \n";
				}
				
				if(errors== "")
				{
					document.getElementById('scheckoutForm').submit();
					$("#submitButton").attr('disabled','disabled');
				}
				else
				{
					alert(errors);
					event.preventDefault();
					$("#submitButton").attr('disabled','disabled');
					return;
				}
			} 
		}
		else
		{
			document.getElementById('scheckoutForm').submit();
			$("#submitButton").attr('disabled','disabled');
		}
	} 
}


function onClickSignUpGuest(e, user_id)
{
	if (document.getElementById('as_guest').checked == true || user_id)
	{
		$("#continueButton").click(); 
	}
	else
	{
		window.location.href = "/login?from=checkout";
	}
	
}

function PaymentCB(e, type)
{   
	if( type== "paypal" )
		{   
			$('#payment_method').val('paypal');  
			$("#cardDiv").hide();
			$("#formSubButton").hide();
			$(".paypalButton").show();
			
			$("#card_holder_name").attr('disabled','disabled');
			$("#card_number").attr('disabled','disabled');
			$("#CardExpirationMonth").attr('disabled','disabled');
			$("#CardExpirationYear").attr('disabled','disabled');
			$("#card_cvv").attr('disabled','disabled'); 
		}
		else
		{  
			$("#cardDiv").show();
			$('#payment_method').val('card'); 
			$("#formSubButton").show();
			$(".paypalButton").hide();
			
			$('#card_holder_name').prop('disabled', false); 
			$('#card_number').prop('disabled', false);
			$('#CardExpirationMonth').prop('disabled', false);
			$('#CardExpirationYear').prop('disabled', false);
			$('#card_cvv').prop('disabled', false); 
		}  
}


function checkIfFormValid(e)
{
	errors = "";
	if( $("#shippingFirstName").val() == '' || $("#shippingLastName").val() == '' || $("#shippingAddress").val() == '' || $("#shipping_value_state").val() == '' || $("#billing_shipping_country").val() == ''|| $("#billing_shipping_country").val() == '' || $("#shippingCity").val() == ''|| $("#shippingZip").val() == '' )
	{
		errors = "Please fill shipping details before proceeding.";
	}
 
	if( errors == '' )
	{
		document.getElementById("getShippingButton").value = "Fetching..Please Wait..."; 
	}
	else
	{
		//alert(errors)
		//e.preventDefault();
	}
}

function checkValidation(that)
{ 
	if($(that).val().length>0)
	{ 
		$(that).css('border-color', '#ccc');
		$(that).css('border-width', '1px');
	}
	else
	{ 
		$(that).css('border-color', 'red');
		$(that).css('border-width', '2px');
	}
	
}

function onInvalidTxt(that)
{
	$(that).css('border-color', 'red');
	$(that).css('border-width', '2px');
}

function adminShippingCarrieClick(event)
{
	if (parseInt($("#totalPrice").val()) < 150) {
				alert("Wholesalers must order at least $150 worth of combine product");
				event.preventDefault();
			} 
			else
			{ 
				document.getElementById("get_shipping").value = true; 
				document.getElementById("distShipButton").value = "Fetching..Please Wait..."; 
			}
}

function getDiscount(event)
 {
 	event.preventDefault();
 	code = $("#coupon_code_ti").val();
 	if(!code)
 	{
 		alert("Please enter coupon code");
 	}
 	else
 	{
 		$.ajax({
	    	type: "GET",
	        url: "/get_discount?code="+ code,
	        dataType: "script",
	    });
 	}
 	
 }
 
 function onClickUpdateColor(order_id)
 {
 	code = $("#new_color").val();
 	if(!code)
 	{
 		alert("Please choose new color");
 	}
 	else
 	{
 		$.ajax({
	    	type: "GET",
	        url: "/update_color?code="+ code+"&order_id="+order_id,
	        dataType: "script",
	    });
 	}
 }
