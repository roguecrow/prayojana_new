import 'dart:convert';

var graphQLQuery = jsonEncode(
    {'query': r'''
  query MyQuery {
  members(order_by: {id: asc}) {
    name
    gender
    dob
    location
    phone
    whatsapp
    client_members {
      client {
        family_name
        client_plans {
          plan {
            name
            color
            id
            position
          }
        }
      }
      relationship
    }
    interaction_members {
      id
      interaction_id
      interaction {
        notes
        title
      }
    }
    task_members {
      id
      task_id
      task {
        task_notes
        task_title
      }
    }
  }
}
''', 'variables': {}});

const String updateMemberDetails = r'''
  mutation UpdateMemberDetails(
    $memberId: Int!,
    $newName: String!,
    $emergencyPhoneNumber: String!,
    $medicalHistory: String!,
    $salutation: String!,
    $gender: String!,
    $dob: String!,
    $phone: String!,
    $whatsapp: String!,
    $email: String!,
    $landline: String!,
    $alternateNumber: String!,
    $zip: String!,
    $address1: String!,
    $address2: String!,
    $address3: String!,
    $area: String!,
    $city: String!,
    $state: String!,
    $location: String!,
    $bloodGroup: String!,
    $vitacuroId: String!,
    $dependencies: String!
  ) {
    update_members(
      where: {id: {_eq: $memberId}},
      _set: {
        name: $newName,
        emergency_phone_number: $emergencyPhoneNumber,
        medical_history: $medicalHistory,
        salutation: $salutation,
        gender: $gender,
        dob: $dob,
        phone: $phone,
        whatsapp: $whatsapp,
        email: $email,
        landline: $landline,
        alternate_number: $alternateNumber,
        zip: $zip,
        address1: $address1,
        address2: $address2,
        address3: $address3,
        area: $area,
        city: $city,
        state: $state,
        location: $location,
        blood_group: $bloodGroup,
        vitacuro_id: $vitacuroId,
        dependencies: $dependencies
      }
    ) {
      returning {
        name
        emergency_phone_number
        medical_history
        dob
        gender
        salutation
        phone
        whatsapp
        email
        landline
        alternate_number
        zip
        address1
        address2
        address3
        area
        city
        state
        location
        blood_group
        vitacuro_id
        dependencies
      }
    }
  }
''';

const String updateMemberInsurancesDetails = r'''
  mutation UpdateMemberInsurances(
    $agentNumber: String!,
    $agentName: String!,
    $insurer: String!,
    $policyNumber: String!,
    $validTill: String!,
    $Id: Int!
  ) {
    update_member_insurances(
      _set: {
        agent_number: $agentNumber,
        agent_name: $agentName,
        insurer: $insurer,
        policy_number: $policyNumber,
        valid_till: $validTill
      },
      where: {id: {_eq: $Id}}
    ) {
      affected_rows
      returning {
        agent_name
        agent_number
        insurer
        policy_number
        valid_till
      }
    }
  }
''';


const String updateMemberHealthDetails = r'''
mutation UpdateMemberDetails(
    $memberId: Int!,
    $dob: String!,
    $medicalHistory: String!,
    $bloodGroup: String!,
    $vitacuroId: String!,
  ) {
    update_members(
      where: {id: {_eq: $memberId}},
      _set: {
        medical_history: $medicalHistory,
        dob: $dob,
        blood_group: $bloodGroup,
        vitacuro_id: $vitacuroId,
      }
    ) {
      returning {
        medical_history
        dob
        blood_group
        vitacuro_id
      }
    }
  }
''';




const String getTaskQuery = r'''
  query MyQuery {
  task_members(order_by: {id: desc}) {
    id
    member_id
    task_id
    task {
      id
      task_notes
      task_title
      task_status_type_id
      task_status_type {
        color
        name
      }
      user {
        name
      }
      due_date
      due_time
      task_members {
        member {
          name
        }
      }
      service_provider {
        position
        name
        service_provider_type {
          name
          position
          id
          color
        }
      }
    }
  }
}
''';

const String updateTaskQuery = r'''
  mutation UpdateTask($taskId: Int!, $taskTitle: String!, $dueDate: date!, $dueTime: time!, $taskNotes: String!, $taskStatusTypeId: Int!, $serviceProviderId: Int!) {
    update_tasks(
      where: {id: {_eq: $taskId}},
      _set: {
        task_title: $taskTitle, 
        due_date: $dueDate,
        due_time: $dueTime,
        task_notes: $taskNotes,
        task_status_type_id: $taskStatusTypeId,
        service_provider_id: $serviceProviderId,
      }
    ) {
      affected_rows
    }
  }
''';


const String updateInteractionQuery =r'''
      mutation MyMutation($id: Int!, $interactionTypeId: Int, $interactionStatusTypeId: Int, $newNotes: String, $newTitle: String, $newInteractionDate: date) {
        update_interactions(where: {id: {_eq: $id}}, _set: {interaction_type_id: $interactionTypeId, interaction_status_type_id: $interactionStatusTypeId, notes: $newNotes, title: $newTitle, interaction_date: $newInteractionDate}) {
          returning {
            interaction_type_id
            interaction_status_type_id
            notes
            title
            interaction_date
          }
        }
      }
    ''';



const String updateInteractionAttachmentsQuery = r'''
  mutation UpdateAttachment(\$interactionId: Int!, \$fileType: String!, \$url: String!) {
            update_interaction_attachements(
              where: { interaction_id: { _eq: \$interactionId } },
              _set: { file_type: \$fileType, url: \$url }
            ) {
              affected_rows
              returning {
                id
                interaction_id
                file_type
                url
              }
            }
          }
''';



const String getTaskStatusTypesQuery = '''
  query MyQuery {
    task_status_types {
      id
      color
      name
    }
  }
''';

const String getInteractionTypesQuery = '''
query MyQuery {
  interaction_types {
    color
    id
    name
  }
}

''';

const String getInteractionStatusTypesQuery = '''
query MyQuery {
  interaction_status_types {
    color
    id
    name
  }
}

''';

const String getServiceProviderTypesQuery = '''
   query MyQuery {
  service_providers {
    service_provider_type_id
    id
    service_provider_type {
      id
      name
    }
  }
}
''';

const String getAllMembersQuery = '''
  query MyQuery {
      members {
        id
        name
      }
    }
''';


const String insertTaskMembersMutation = r'''
  mutation MyMutation(
    $carebuddyId: String
    $taskTitle: String
    $taskNotes: String
    $serviceProviderId: String
    $taskStatusTypeId: String
    $createdBy: String
    $interactionId: String
    $dueDate: String
    $url: String
    $fileType: String
    $memberId: String
  ) {
    insert_task_members(
      objects: {
        task: {
          data: {
            carebuddy_id: $carebuddyId
            task_title: $taskTitle
            task_notes: $taskNotes
            service_provider_id: $serviceProviderId
            task_status_type_id: $taskStatusTypeId
            created_by: $createdBy
            interaction_id: $interactionId
            due_date: $dueDate
            task_attachements: {
              data: { url: $url, file_type: $fileType }
            }
          }
        }
        member_id: $memberId
      }
    ) {
      returning {
        task {
          carebuddy_id
          task_title
          task_notes
          interaction_id
          service_provider_id
          task_status_type_id
          created_by
          user {
            name
          }
          id
          task_attachements {
            file_type
            task_id
            url
          }
        }
        member_id
        member {
          name
        }
      }
    }
  }
''';

const String getInteractionQuery = '''
    query MyQuery {
      interaction_members(order_by: {id: desc}, limit: 40) {
        interaction {
          carebuddy_id
          id
          interaction_date
          carebuddy_id
          interaction_status_type_id
          interaction_type_id
          interaction_time
          is_active
          notes
          title
          member_summaries{
                  interaction_id
                  member_id
                  notes
                }
          interaction_attachements {
            file_type
            url
          }
          interaction_status_type {
            id
            color
            name
          }
          interaction_type {
            name
            id
          }
        }
        member_id
        member {
          name
        }
      }
    }
  ''';

const String insertInChatSummaries = '''
      mutation MyMutation(\$memberId: Int!, \$notes: String!, \$interactionId: Int!) {
        insert_member_summaries(objects: {
          member_id: \$memberId,
          notes: \$notes,
          interaction_id: \$interactionId
        }) {
          affected_rows
          returning {
            id
            interaction_id
            member_id
            notes
          }
        }
      }
    ''';

const String insertTaskChatSummaries = '''
      mutation MyMutation(\$memberId: Int!, \$notes: String!, \$taskId: Int!) {
        insert_member_summaries(objects: {
          member_id: \$memberId,
          notes: \$notes,
          task_id: \$taskId
        }) {
          affected_rows
          returning {
            id
            task_id
            member_id
            notes
          }
        }
      }
    ''';

const String getInterestTypes = '''
query MyQuery {
  interest_types {
    id
    name
    is_active
    position
  }
}
''';



const String getPlans = '''
 query MyQuery {
  plans {
    id
    color
    name
    position
  }
}
''';


String getMemberQuery(int id) {
  return '''
    query MyQuery {
      members(where: {id: {_eq: $id}}) {
        id
        name
        salutation
        gender
        dob
        medical_history
        phone
        whatsapp
        email
        landline
        alternate_number
        emergency_phone_number
        zip
        address1
        address2
        address3
        area
        city
        state
        location
        blood_group
        dependencies
        vitacuro_id
        note1
        note2
        member_carebuddies {
          user {
            name
          }
        }
        member_assistances {
          alternate_number
          phone
        }
        client_members {
          relationship
          client {
            id
            family_name
            name
            prid
            client_plans {
              plan {
                id
                name
                color
              }
            }
            client_members {
              client_id
              relationship
              client {
                client_plans {
                  plan {
                    id
                    name
                    color
                  }
                }
              }
              member {
                name
                dob
                gender
                location
              }
            }
          }
        }
      }
    }
  ''';
  }
String getMemberHealthQuery(int id) {
  return '''
    query MyQuery {
          members(where: { id: { _eq: $id } }) {
            id
            name
            dob
            blood_group
            medical_history
            vitacuro_id
            member_insurances {
              id
              insurer
              policy_number
              valid_till
              agent_number
              agent_name
              member_insurance_images {
                id
                name
              }
            }
            member_medical_centers {
              medical_center {
                id
                name
                phone
                address
                medical_center_type {
                  name
                }
              }
              id
            }
            member_doctors {
              doctor {
                name
                mobile_number
                notes
                doctor_addresses {
                  address
                }
              }
            }
          }
        }
  ''';
}

String getMemberNotesQuery(int id) {
  return '''
    query MyQuery {
  members(where: { id: { _eq: $id } }) {
    name
    id
    interaction_members {
      interaction {
        id
        title
        interaction_date
        interaction_time
        member_summaries {
          notes
        }
        interaction_status_type {
          name
        }
      }
    }
    task_members {
      task {
        id
        task_title
        due_date
        due_time
        member_summaries {
          notes
        }
        task_status_type {
          name
        }
      }
    }
  }
}

  ''';
}

String getMemberAssistanceQuery(int id) {
  return '''
  query MyQuery {
  members(where: {id: {_eq: $id }}) {
    id
    name
    member_assistances(order_by: {id: asc}) {
      name
      member_id
      id
      is_emergency
      is_proxy_access
      location
      phone
      relation
    }
  }
}
  ''';
}

String getMemberDocumentsQuery(int id) {
  return '''
query MyQuery {
  member_documents(where: {member_id: {_eq: $id }}) {
    id
    image
    member_id
    name
    type
  }
}
  ''';
}

String getPrayojanaProfileQuery(int id) {
  return '''
    query MyQuery {
      members(where: { id: { _eq: $id } }) {
        id
        name
        salutation
        gender
        dob
        member_carebuddies {
          user {
            name
          }
        }
        client_members {
          client {
            id
            name
            salutation
            gender
            dob
            prid
            family_name
            client_statuses {
              client_status_type {
                name
              }
            }
            client_plan_histories {
              start_date
              end_date
              plan {
                id
                name
                color
              }
              plan_amount
              amount_paid
              payment_date
              link
              payment_type
              payment_id
            }
          }
        }
      }
    }
  ''';
}

String getMemberInterestQuery(int id) {
  return '''
query MyQuery {
  members(where: {id: {_eq: $id}}) {
    id
    name
    interests(order_by: {id: asc},  where: { is_active: { _eq: true } }) {
      id
      is_active
      interest_type_id
      interest_type {
        name
      }
    }
  }
}
  ''';
}

const String updateMemberInterestDetails = r'''
mutation UpdateInterest($id: Int!, $isActive: Boolean!) {
  update_interests(
    where: {id: {_eq: $id}},
    _set: {is_active: $isActive}
  ) {
    affected_rows
    returning {
      id
      is_active
    }
  }
}
''';


const String insertMemberAssistanceDetails = r'''
 mutation MyMutation(
  $name: String,
  $phone: String,
  $relation: String,
  $is_proxy_access: Boolean,
  $is_emergency: Boolean,
  $location: String,
  $member_id: Int
) {
  insert_member_assistances(
    objects: {
      name: $name,
      phone: $phone,
      relation: $relation,
      is_proxy_access: $is_proxy_access,
      is_emergency: $is_emergency,
      location: $location,
      member_id: $member_id
    }
  ) {
    affected_rows
    returning {
      alternate_number
      id
      is_emergency
      is_proxy_access
      location
      member_id
      name
      phone
      relation
    }
  }
}
''';

const String updateMemberAssistanceDetails = r'''
mutation MyMutation(
  $id: Int!,
  $name: String!,
  $phone: String!,
  $relation: String!,
  $is_emergency: Boolean!,
  $is_proxy_access: Boolean!,
  $location: String!
) {
  update_member_assistances(
    where: { id: { _eq: $id }},
    _set: {
      name: $name,
      phone: $phone,
      relation: $relation,
      is_emergency: $is_emergency,
      is_proxy_access: $is_proxy_access,
      location: $location
    }
  ) {
    affected_rows
    returning {
      id
      is_emergency
      is_proxy_access
      location
      name
      phone
      relation
      member_id
    }
  }
}

''';

const String insertMemberHealthDetails = r'''
mutation MyMutation(
  $agent_name: String!,
  $agent_number: String!,
  $insurer: String!,
  $member_id: Int!,
  $policy_number: String!,
  $valid_till: String!
) {
  insert_member_insurances(
    objects: {
      agent_name: $agent_name,
      agent_number: $agent_number,
      insurer: $insurer,
      member_id: $member_id,
      policy_number: $policy_number,
      valid_till: $valid_till
    }
  ) {
    affected_rows
    returning {
      agent_name
      agent_number
      id
      insurer
      member_id
      policy_number
      valid_till
    }
  }
}

''';

const String medicalCenterIds = r'''
query MyQuery {
  medical_centers {
    id
    name
  }
}
''';

const String updateMemberMedicalCenterDetails = r'''
mutation MyMutation($id: Int!, $member_id: Int!, $medical_center_id: Int!) {
  update_member_medical_center(
    where: {id: {_eq: $id}, member_id: {_eq: $member_id}}, 
    _set: {medical_center_id: $medical_center_id}
  ) {
    affected_rows
    returning {
      medical_center_id
      medical_center {
        name
      }
    }
  }
}

''';


