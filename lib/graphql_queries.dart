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
      returning {
       due_date
       due_time
       id
       service_provider_id
       task_notes
       task_title
       task_status_type_id
       task_status_type {
         name
       }
       task_attachements {
         file_type
         id
         url
       }
     }
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
mutation UpdateInteractionAttachments(
  $interactionId: Int!,
  $fileType: String!,
  $url: String!
) {
  update_interaction_attachements(
    where: { interaction_id: { _eq: $interactionId } },
    _set: { file_type: $fileType, url: $url }
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

const String updateUserProfilePhoto = r'''
mutation MyMutation($user_id: Int! ,$url: String!) {
  update_people(
    where: { user_id: { _eq: $user_id } }, 
    _set: { profile_photo: $url }
  ) {
    affected_rows
    returning {
      id
      user_id
      user {
        name
      }
      profile_photo
    }
  }
}

''';

const String updateTaskAttachmentsQuery = r'''
  mutation UpdateTaskAttachments(
    $taskId: Int!,
    $fileType: String!,
    $url: String!
  ) {
    update_task_attachements(
      where: { task_id: { _eq: $taskId } },
      _set: { file_type: $fileType, url: $url }
    ) {
      affected_rows
      returning {
        id
        task_id
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

const String getMemberStatusTypesQuery = '''
query MyQuery {
  member_status_types {
    id
    color
    name
  }
}
''';

const String getPlansQuery = '''
query MyQuery {
  plans {
    name
    color
    id
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

const String insertNotificationDevices = '''
  mutation MyMutation(\$device: String!, \$isNotExpired: Boolean!, \$regId: String!, \$userId: Int!) {
    insert_notification_devices(objects: {
      device: \$device,
      is_not_expired: \$isNotExpired,
      reg_id: \$regId,
      user_id: \$userId
    }) {
      affected_rows
      returning {
        device
        id
        is_active
        is_not_expired
        reg_id
        user_id
      }
    }
  }
''';

const String updateNotificationDevices = '''
mutation MyMutation(\$regId: String!, \$isNotExpired: Boolean!, \$userId: Int!) {
  update_notification_devices(
    where: { reg_id: { _eq: \$regId }, user_id: { _eq: \$userId } },
    _set: { is_not_expired: \$isNotExpired }
  ) {
    affected_rows
    returning {
      device
      expired_at
      id
      is_active
      is_not_expired
      reg_id
      user_id
    }
  }
}

''';

const String updatePeopleMutation = '''
mutation MyMutation(\$userId: Int!, \$dob: String!, \$city: String!, \$country: String!, \$email: String!, \$whatsapp: String!) {
  update_people(
    where: {user_id: {_eq: \$userId}},
    _set: {
      dob: \$dob,
      city: \$city,
      country: \$country,
      email: \$email,
      whatsapp: \$whatsapp
    }
  ) {
    affected_rows
    returning {
      city
      country
      dob
      email
      phone
      state
      user_id
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
  members(where: {id: {_eq: $id }}) {
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
    member_medical_centers(where: {is_active: {_eq: true}}) {
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
    member_doctors(where: {is_active: {_eq: true}}) {
      doctor {
        id
        name
        mobile_number
        notes
        doctor_addresses {
          id
          address
        }
      }
      id
      doctor_address_id
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
  member_documents(where: {member_id: {_eq: $id },is_active: {_eq: true}}) {
    id
    image
    member_id
    name
    type
  }
}
  ''';
}

String deleteMemberDocumentsMutation(int memberId, int documentId) {
  return '''
mutation MyMutation {
  delete_member_documents(where: {member_id: {_eq: $memberId}, id: {_eq: $documentId}}) {
    affected_rows
  }
}
  ''';
}

String insertMemberDocumentMutation(int memberId, String image, String name) {
  return '''
mutation MyMutation {
  insert_member_documents(objects: {image: "$image", name: "$name", member_id: $memberId}) {
    affected_rows
    returning {
      id
      image
      name
      member_id
    }
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

const String doctorIds = r'''
query MyQuery {
  doctors {
    id
    name
    doctor_addresses {
      id
      address
    }
  }
}
''';

const String notificationTokenIds = r'''
query MyQuery {
  notification_devices {
    id
    reg_id
    user_id
  }
}

''';

const String updateMemberMedicalCenterDetails = r'''
mutation MyMutation($id: Int!, $member_id: Int!, $medical_center_id: Int!, $is_active: Boolean!) {
  update_member_medical_center(
  where: {id: {_eq: $id}, member_id: {_eq: $member_id}},
   _set: {medical_center_id: $medical_center_id, is_active: $is_active}) {
    affected_rows
    returning {
      medical_center_id
      medical_center {
        name
      }
      is_active
    }
  }
}
''';


const String insertDoctorsDetails = r'''
mutation MyMutation($member_id: Int!, $doctor_id: Int!, $doctor_address_id: Int!) {
  insert_member_doctors(objects: {member_id: $member_id, doctor_id: $doctor_id, doctor_address_id: $doctor_address_id}) {
    affected_rows
    returning {
      id
      member_id
      doctor_id
      doctor {
        name
      }
      doctor_address_id
    }
  }
}
''';


const String insertMemberMedicalCenter = r'''
mutation MyMutation($medical_center_id: Int!, $member_id: Int!) {
  insert_member_medical_center(objects: {medical_center_id: $medical_center_id, member_id: $member_id}) {
    affected_rows
    returning {
      id
      medical_center_id
      member_id
      medical_center {
        name
      }
    }
  }
}
''';

String getDoctorAddressDetails(int id) {
  return '''
query MyQuery {
  doctor_addresses(where: {doctor_id: {_eq: $id }}) {
    id
    address
  }
}
''';
}

const String updateDoctorDetails = r'''
mutation MyMutation($id: Int!, $member_id: Int!, $doctor_address_id: Int!, $doctor_id: Int!, $is_active: Boolean!) {
  update_member_doctors(where: {id: {_eq: $id}, member_id: {_eq: $member_id}}, _set: {doctor_address_id: $doctor_address_id, doctor_id: $doctor_id, is_active: $is_active}) {
    affected_rows
    returning {
      id
      doctor_id
      member_id
      doctor_address_id
      doctor_address {
        address
      }
      is_active
    }
  }
}

''';

const String insertNewTask = r'''
mutation MyMutation($carebuddy_id: Int!, $task_title: String!, $task_notes: String!, $service_provider_id: Int!, $task_status_type_id: Int!, $created_by: Int!, $file_type: String!, $url: String!, $due_date: date!, $due_time: time!, $member_id: Int!) {
  insert_task_members(objects: {task: {data: {carebuddy_id: $carebuddy_id, task_title: $task_title, task_notes: $task_notes, service_provider_id: $service_provider_id, task_status_type_id: $task_status_type_id, created_by: $created_by, task_attachements: {data: {file_type: $file_type, url: $url}}, due_date: $due_date, due_time: $due_time}}, member_id: $member_id}) {
    affected_rows
    returning {
      task {
        carebuddy_id
        task_title
        interaction_id
        service_provider_id
        task_status_type_id
        created_by
        user {
          name
        }
        task_attachements {
          file_type
          url
          task_id
        }
        id
        due_date
        due_time
        task_status_type {
          name
        }
        service_provider {
          name
          service_provider_type_id
          service_provider_type {
            name
          }
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



String taskDetailsQuery(int taskId) {
  return '''
query MyQuery {
  tasks(order_by: {id: desc}, where: {id: {_eq: $taskId}}) {
      carebuddy_id
      due_date
      due_time
      created_by
      id
      task_notes
      task_title
      task_status_type_id
      interaction_id
      service_provider_id
      service_provider {
        name
        service_provider_type {
          name
        }
      }
      task_attachements {
        file_type
        url
      },
      user {
        name
      }
      task_status_type {
        name
        color
      }
      member_summaries {
        id
        member_id
        notes
        task_id
      }
    task_members{
      member_id
      member{
        name
      }
    }
    
  }
}

''';
}


String interactionDetailsQuery(int interactionId) {
  return '''
 query MyQuery {
    interaction_members(
        where: {
          interaction: { id: { _eq: $interactionId } }
        }
    ) {
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
        member_summaries {
          interaction_id
          member_id
          notes
        }
        interaction_attachements {
          id
          url
        }
        interaction_status_type {
          color
          name
        }
        interaction_type {
          id
          name
        }
      }
      member_id
      member {
        name
      }
    }
  }
''';
}

String getUserProfile(int userId) {
  return '''
query MyQuery(\$userId: Int!) {
  users(where: {id: {_eq: \$userId}}) {
    id
    name
    mobile_number
    people {
      city
      country
      dob
      email
      profile_photo
      state
      whatsapp
      gender
    }
  }
}
''';
}




