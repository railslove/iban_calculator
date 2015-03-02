0.2.0
-----
* [lower active_support dependency](https://github.com/railslove/iban_calculator/pull/7)

0.1.1
-----

* added missing failure code for iban checksum
* fixed error condition, so not every request is concidered an error ;)
* `#as_json` will have stringified keys
* `#valdiate_iban` and `#calculate_iban` should respond with mostly the same format
* rescue from `ArgumentError` happening when the date is present but not valid

0.1.0
-----

* Allow invalid IBANs to bubble though and not to fail spectacular

0.0.3
-----

* Raise an exception when an unexpected response is returned (i.e. invalid user and password)

0.0.2
-----

* Add support for validating IBANs and fetching related data such as legacy data

0.0.1
-----

* Initial release with support for calculating IBANs based on legacy data
