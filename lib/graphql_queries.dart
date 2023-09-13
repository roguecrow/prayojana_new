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

const String combinedMutation = r'''
  mutation UpdateMemberDetailsAndNotes(
    $id: Int!,
    $name: String!,
    $phone: String!,
    $interactionNotes: String!,
    $taskNotes: String!,
    $taskId: Int,           
    $interactionId: Int   
  ) {
    update_members_by_pk(
      pk_columns: { id: $id },
      _set: {
        name: $name,
        phone: $phone
      }
    ) {
      id
      name
      phone
    }
    update_task_by_pk(
      pk_columns: { id: $taskId }
      _set: { task_notes: $taskNotes }
    ) {
      task_notes
    }
    update_interaction_by_pk(
      pk_columns: { id: $interactionId }
      _set: { notes: $interactionNotes }
    ) {
      notes
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



