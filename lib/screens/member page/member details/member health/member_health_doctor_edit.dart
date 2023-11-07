import 'package:flutter/material.dart';

class HealthDoctorNew extends StatefulWidget {
  const HealthDoctorNew({super.key});

  @override
  State<HealthDoctorNew> createState() => _HealthDoctorNewState();
}

class _HealthDoctorNewState extends State<HealthDoctorNew> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Assign Doctor'),
      ),
    );
  }
}
