(function($SPA, $) {
	var countryStates = {
		CA: [
			{code: 'AB', name: 'Alberta'},
			{code: 'BC', name: 'British Columbia'},
			{code: 'MB', name: 'Manitoba'},
			{code: 'NB', name: 'New Brunswick'},
			{code: 'NL', name: 'Newfoundland and Labrador'},
			{code: 'NT', name: 'Northwest Territories'},
			{code: 'NS', name: 'Nova Scotia'},
			{code: 'NU', name: 'Nunavut'},
			{code: 'ON', name: 'Ontario'},
			{code: 'PE', name: 'Prince Edward Island'},
			{code: 'QC', name: 'Quebec'},
			{code: 'SK', name: 'Saskatchewan'},
			{code: 'YT', name: 'Yukon'}
		],
		US: [
			{code: 'AL', name: 'Alabama'},
			{code: 'AK', name: 'Alaska'},
			{code: 'AZ', name: 'Arizona'},
			{code: 'AR', name: 'Arkansas'},
			{code: 'CA', name: 'California'},
			{code: 'CO', name: 'Colorado'},
			{code: 'CT', name: 'Connecticut'},
			{code: 'DE', name: 'Delaware'},
			{code: 'FL', name: 'Florida'},
			{code: 'GA', name: 'Georgia'},
			{code: 'HI', name: 'Hawaii'},
			{code: 'ID', name: 'Idaho'},
			{code: 'IL', name: 'Illinois'},
			{code: 'IN', name: 'Indiana'},
			{code: 'IA', name: 'Iowa'},
			{code: 'KS', name: 'Kansas'},
			{code: 'KY', name: 'Kentucky'},
			{code: 'LA', name: 'Louisiana'},
			{code: 'ME', name: 'Maine'},
			{code: 'MD', name: 'Maryland'},
			{code: 'MA', name: 'Massachusetts'},
			{code: 'MI', name: 'Michigan'},
			{code: 'MN', name: 'Minnesota'},
			{code: 'MS', name: 'Mississippi'},
			{code: 'MO', name: 'Missouri'},
			{code: 'MT', name: 'Montana'},
			{code: 'NE', name: 'Nebraska'},
			{code: 'NV', name: 'Nevada'},
			{code: 'NH', name: 'New Hampshire'},
			{code: 'NJ', name: 'New Jersey'},
			{code: 'NM', name: 'New Mexico'},
			{code: 'NY', name: 'New York'},
			{code: 'NC', name: 'North Carolina'},
			{code: 'ND', name: 'North Dakota'},
			{code: 'OH', name: 'Ohio'},
			{code: 'OK', name: 'Oklahoma'},
			{code: 'OR', name: 'Oregon'},
			{code: 'PA', name: 'Pennsylvania'},
			{code: 'RI', name: 'Rhode Island'},
			{code: 'SC', name: 'South Carolina'},
			{code: 'SD', name: 'South Dakota'},
			{code: 'TN', name: 'Tennessee'},
			{code: 'TX', name: 'Texas'},
			{code: 'UT', name: 'Utah'},
			{code: 'VT', name: 'Vermont'},
			{code: 'VA', name: 'Virginia'},
			{code: 'WA', name: 'Washington'},
			{code: 'WV', name: 'West Virginia'},
			{code: 'WI', name: 'Wisconsin'},
			{code: 'WY', name: 'Wyoming'}
		]
	};

    $(document).ready(function() {
        var error_fields = {
            first_name: 'First name',
            last_name: 'Last name',
            email: 'Email address',
            number: 'Credit Card number',
            postal_code: 'Postal Code',
            month: 'Expiration Month',
            year: 'Expiration Year',
            cvv: 'CVV',
            country: 'Country Code',
            address1: 'Billing Street Address 1',
			address2: 'Billing Street Address 2',
            city: 'Billing City'
        };
        
        // Use the Global recurly object and setup the configuration
        recurly.configure({
            publicKey: $SPA.key,
            style: {
                all: {
                    font: '100% / 1.5 "Salesforce Sans", Arial, sans-serif;',
                    fontColor: '#16325c'
                },
                month: {
                    placeholder: 'mm'
                },
                year: {
                    placeholder: 'yyyy'
                },
                cvv: {
                    placeholder: 'cvv'
                }
            }
        });

        $('#cancel').click(function(){
            event.preventDefault();
            window.location = '/' + $SPA.accountId;
        });
        
        // On form submit, we stop submission to go get the token
        $('form').on('submit', function(event) {
            var form = this;

			var country = $('#country').val();
			var state = ((country == 'CA' || country == 'US') ? $('#stateSelect').val() : $('#stateInput').val());

            var formData = {
                "first_name": $('input[name="first_name"]').val(),
                "last_name": $('input[name="last_name"]').val(),
                "country": $('select[name="country"]').val(),
                "address1": $('input[name="address1"]').val(),
				"address2": $('input[name="address2"]').val(),
                "city": $('input[name="city"]').val(),
                "state": state,
                "postal_code": $('input[name="postal_code"]').val()
            };

            // ===========================
            // DO STUFF on Submit
            // Stop the form submission so we can submit it with AJAX
            event.preventDefault();

            // Reset the errors display
			$('.form-errors').addClass('errors__hidden');
			$('.token-errors').addClass('errors__hidden');
            $('#errors').text('');
            $('input').removeClass('error');
            $('.form-input').removeClass('form-input__error');

            // Disable the submit button
            $('.btn-submit').prop('disabled', true);

            // Now we call recurly.token with the form. It goes to Recurly servers
            // to tokenize the credit card information, then injects the token into the
            // data-recurly="token" field above
            recurly.token(formData, function(err, token) {
                if (err) {
                    error(err);
                } else {
                    var data = {
                        token_id: token.id
                    };

                    $.jsr({
                        method: $SPA.jsr.updateBillingInfo,
                        args: [$SPA.accountId, data]
                    }).then(function() {
                        window.location = '/' + $SPA.accountId;
                    }, function(err) {
                        alert('error' + err.message);
                    });
                }
            });
            // End of onSubmit
            // ===========================
        });

        // Identity card type
        $('#number').on('change', function(event) {
            // Whenever the Credit Card number changes, we want to do some stuff
            var card_number = $("#number").val();
            var card_type = recurly.validate.cardType(card_number);
            var card_is_valid = recurly.validate.cardNumber(card_number);
            var number_field = $('.customer-fields--card-number .form-input');

            // Display Validation to the user to tell them if it's a valid card number or not
            if (card_is_valid) {
                $(number_field).removeClass('form-input__error');
                $("#number").mask('0000 0000 0000 0000');
            }
            else {
                $(number_field).addClass('form-input__error');
            }
            // Change the icon type to be something cool.
            if ((card_type == 'default') || (card_type == 'unknown')) {
                $('.icon-card').addClass('icon-card__generic');
                $('.icon-card').removeClass('icon-card__visa icon-card__mastercard icon-card__amex icon-card__visa discover');
            }
            else {
                $('.icon-card').removeClass('icon-card__generic');
                $('.icon-card').addClass('icon-card__' + card_type);
            }
        });

		$('#country').change(function() {
			var country = $(this).val();
			if (country != '' && countryStates[country]) {
				$('#stateSelect option').remove();
				
				$('#stateSelect').append('<option/>');

				$.each(countryStates[country], function(index, state) {
					$('#stateSelect').append('<option value="' + state.code + '">' + state.name + '</option>');
				});
				
				$('#stateSelect').closest('.slds-form-element__control').show();
				$('#stateInput').hide();
			} else {
				$('#stateSelect').closest('.slds-form-element__control').hide();
				$('#stateInput').show();
			}
		});
		
        function error(err) {
			if (err.fields) {
				// For each field that has an error on it, add the error class to the element
				//  and create list items for each error
				var errors_markup = $.map(err.fields, function(field) {
					$('.form-input__' + field).addClass('form-input__error');
					return '<li class="form-errors--invalid-field">' + error_fields[field] + '</li>';
				}).join('');

				// We then add the errors to the wrapper
				$('.form-errors').removeClass('errors__hidden');
				$('.form-errors ul')
					.empty()
					.append(errors_markup);

				// Add an error class to each field, selected by the data- attribute
				$.each(err.fields, function(i, field) {
					$('[data-recurly=' + field + ']').addClass('error');
				});
			} else {
				var message = err.message ? err.message : 'Unknown error!';
				$('.token-errors')
					.html(message)
					.removeClass('errors__hidden');
			}

			// We enble the submit button
			$('input[type="submit"]').prop('disabled', false);
		}
		
    });

} (window.$SPA, window.jQuery));