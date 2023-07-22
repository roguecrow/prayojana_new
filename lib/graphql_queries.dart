import 'dart:convert';

var graphQLQuery = jsonEncode(
    {'query': r'''
  query MyQuery {
    members {
      id
      name
      phone
      address1
      address2
      address3
      alternate_number
      area
      blood_group
      city
      interaction_members {
        id
        interaction_id
        member_id
        interaction {
          notes
        }
      }
      client_members {
        relationship
      }
      dob
      gender
    }
  }
''', 'variables': {}});

