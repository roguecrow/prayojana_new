import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20Notes/member_notes_edit.dart';

import '../../../../services/api_service.dart';

class MemberNotes extends StatefulWidget {
  const MemberNotes({Key? key, required this.member}) : super(key: key);

  final Map<String, dynamic> member;


  @override
  State<MemberNotes> createState() => _MemberNotesState();
}

class _MemberNotesState extends State<MemberNotes> {
  List<dynamic> memberNotesDetails = []; // Add this line
  List<dynamic> interactions = []; // Add this line
  List<dynamic> tasks = []; // Add this line


  late BuildContext _storedContext;
  bool isLoading = true; // Add this line
  String? planName; // Make planName nullable

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _fetchMemberNotesDetails();
    } else {
      print('Error: widget.member is null');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<void> _fetchMemberNotesDetails() async {
    var memberId = widget.member['id'];
    print('Clicked Member ID: $memberId');
    List<dynamic>? noteDetails = await MemberApi().fetchMemberNotesDetails(memberId);
    if (noteDetails != null && noteDetails.isNotEmpty) {
      List<dynamic> interactionsList = noteDetails[0]['interaction_members'];
      List<dynamic> tasksList = noteDetails[0]['task_members'];
      setState(() {
        memberNotesDetails = noteDetails;
        print('memberNotesDetails - $memberNotesDetails');
        interactions = interactionsList;
        tasks = tasksList;
        print('interactions - $interactions');
        print('tasks - $tasks');

        isLoading = false;
      });
    } else {
      print('Error fetching member details');
    }
  }

  String _formatTime(String? timeString) {
    if (timeString != null) {
      List<String> parts = timeString.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      String period = hours >= 12 ? 'PM' : 'AM';
      hours = hours % 12;
      hours = hours != 0 ? hours : 12; // Handle midnight (0 hours)

      return '$hours:${parts[1]} $period';
    }
    return 'N/A';
  }





  void _showInteractionInfo(BuildContext context, dynamic interaction) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Divider(
                height: 30.0,
                thickness: 1,
              ),
              ListTile(
                leading: const Icon(Icons.title),
                title: const Text('Title'),
                subtitle: Text(interaction['interaction']['title'] ?? 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Interaction Date'),
                subtitle: Text(
                  interaction['interaction']['interaction_date'] != null
                      ? DateFormat('dd MMM yyyy').format(DateTime.parse(interaction['interaction']['interaction_date']))
                      : 'N/A',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notes),
                title: const Text('Notes'),
                subtitle: Text(
                  interaction['interaction']['member_summaries'] != null && interaction['interaction']['member_summaries'].isNotEmpty
                      ? interaction['interaction']['member_summaries'][0]['notes']
                      : 'N/A',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.candlestick_chart),
                title: const Text('Status Type'),
                subtitle: Text(interaction['interaction']['interaction_status_type']['name'] ?? 'N/A'),
              ),
            ],
          ),
        );
      },
    );
  }


  void _showTaskInfo(BuildContext context, dynamic task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Divider(
                height: 30.0,
                thickness: 1,
              ),
              ListTile(
                leading: const Icon(Icons.title),
                title: const Text('Task Title'),
                subtitle: Text(task['task']?['task_title'] ?? 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Due Date'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(DateTime.parse(task['task']?['due_date'])) ?? 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Due Time'),
                subtitle: Text(_formatTime(task['task']?['due_time'])),
              ),
              ListTile(
                leading: const Icon(Icons.notes),
                title: const Text('Notes'),
                subtitle: Text(task['task']?['member_summaries']?.isNotEmpty == true ? task['task']['member_summaries'][0]['notes'] ?? 'N/A' : 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.candlestick_chart),
                title: const Text('Task Status Type'),
                subtitle: Text(task['task']?['task_status_type']?['name'] ?? 'N/A'),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
        child:  SizedBox(
          height: 50,
          width: 50,
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulseSync, /// Required, The loading type of the widget
            colors: [Color(0xff006bbf)],       /// Optional, The color collections
          ),
        ),
      )
          : ListView(
        children: [
          const SizedBox(height: 20,),
          Padding(
            padding:  EdgeInsets.only(left: 22.0.w),
            child: Text(
              'Interaction Summaries',
              style: TextStyle(color: Colors.grey[600], fontSize: 16.0.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 200.0.h, // Set a fixed height
            margin: EdgeInsets.all(10.0.h),
            padding: EdgeInsets.all(8.0.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0.r),
            ),
            child: Scrollbar(
              child: interactions.isEmpty
                  ? Center(
                child: Text(
                  'No interactions information available',
                  style: TextStyle(fontSize: 14.sp),
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: interactions.length,
                itemBuilder: (context, index) {
                  dynamic interaction = interactions[index];
                  return InkWell(
                    onTap: () {
                      _showInteractionInfo(context, interaction);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.transparent, // Border color
                          width: 0.1, // Border width
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          interaction['interaction']['title'] ?? 'N/A',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_outlined,
                          size: 12.0.h,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 22.0.w),
            child: Text(
              'Task Summaries',
              style: TextStyle(color: Colors.grey[600],fontSize: 16.0.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 200.0.h, // Set a fixed height
            margin: EdgeInsets.all(10.0.h),
            padding: EdgeInsets.all(8.0.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0.r),
            ),
            child: Scrollbar(
              child: tasks.isEmpty
                  ? Center(
                child: Text(
                  'No tasks information available',
                  style: TextStyle(fontSize: 14.sp),
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  dynamic task = tasks[index];
                  return InkWell(
                    onTap: () {
                      _showTaskInfo(context, task);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.transparent, // Border color
                          width: 0.1, // Border width
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          task['task']['task_title'] ?? 'N/A',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_outlined,
                          size: 12.0.h,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     _navigateToMemberNoteEdit();
      //   },
      //   label: const Text('EDIT'),
      //   icon: const Icon(Icons.edit_outlined),
      //   backgroundColor: const Color(0xff018fff),
      // ),
    );
  }

  void  _navigateToMemberNoteEdit() async {
    final shouldCreate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMemberNote(memberNotesDetails: memberNotesDetails),
      ),
    );

    if (shouldCreate == true) {
      // Refresh the task data after updating
      _fetchMemberNotesDetails();
    }
  }
}
