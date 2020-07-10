#!/bin/sh

curl --location --request GET -k 'https://fast.ilabt.imec.be/api/v6/citizens/delete'

curl --location --request POST -k 'https://fast.ilabt.imec.be/api/v6/citizens/addInfo' --header 'Content-Type: application/json' --data-raw '{ "input": { "provideCitizenFirstNameManually": "Bob" } }'

curl --location --request POST -k 'https://fast.ilabt.imec.be/api/v6/citizens/addInfo' --header 'Content-Type: application/json' --data-raw '{ "input": { "provideCitizenLastNameManually": "Smith" } }'

curl --location --request POST -k 'https://fast.ilabt.imec.be/api/v6/citizens/addInfo' --header 'Content-Type: application/json' --data-raw '{ "input": { "provideCitizenEmailManually": "johnsmith@something.be" } }'

curl --location --request POST -k 'https://fast.ilabt.imec.be/api/v6/citizens/addInfo' --header 'Content-Type: application/json' --data-raw '{ "input": { "provideCitizenMobilePhoneNumberManually": "0123456" } }'

curl --location --request POST -k 'https://fast.ilabt.imec.be/api/v6/citizens/addInfo' --header 'Content-Type: application/json' --data-raw '{ "input": { "provideCitizenPhoneNumberManually": "098765" } }'

curl --location --request POST -k 'https://fast.ilabt.imec.be/api/v6/citizens/addInfo' --header 'Content-Type: application/json' --data-raw '{ "input": { "provideCitizenAddressManually": "examplestreet 10, 9000 Gent" } }'

curl --location --request POST -k 'https://fast.ilabt.imec.be/api/v6/citizens/addInfo' --header 'Content-Type: application/json' --data-raw '{ "input": { "provideCitizenBirthDateManually": "3.8.1977" } }'

curl --location --request POST -k 'https://fast.ilabt.imec.be/api/v6/citizens/addInfo' --header 'Content-Type: application/json' --data-raw '{ "input": { "provideCitizenBirthPlaceManually": "Gent" } }'

#here is a problem

curl --location --request GET -k 'https://fast.ilabt.imec.be/api/v6/plan/journey_moving'

#curl --location --request POST -k 'https://fast.ilabt.imec.be/api/v6/citizens/addInfo' --header 'Content-Type: application/json' --data-raw '{ "input": { "provideCitizenNationalNumberManually": "99999" } }'

#curl --location --request POST -k 'https://fast.ilabt.imec.be/api/v6/citizens/addInfo' --header 'Content-Type: application/json' --data-raw '{ "input": { "provideCitizensNationalityManually": "Belgian" } }'

#curl --location --request POST -k 'https://fast.ilabt.imec.be/api/v6/citizens/addInfo' --header 'Content-Type: application/json' --data-raw '{ "input": { "provideCitizenProfessionManually": "lawyer" } }'
