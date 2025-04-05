import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youth_guide/service/api_service.dart';
import 'package:youth_guide/utils.dart';

class AppForeward extends StatefulWidget {
  const AppForeward({super.key});

  @override
  State<AppForeward> createState() => _AppForewardState();
}

class _AppForewardState extends State<AppForeward> {
  List<Map<String, dynamic>>? foreward;

  Future<void> _fetchBishopsSpeech() async {
    try {
      foreward = await FirestoreService().getCollection('foreward');
      log('${foreward?[0]['main']}');
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    _fetchBishopsSpeech();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Methodist Church Nigeria \nDirectorate of Evangelism and Discipleship'
                  .toUpperCase(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Foreward', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: FirestoreService().getCollection('foreward'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No foreward available.'));
          } else {
            foreward = snapshot.data;
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TextToSpeech.textToSpeech,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      foreward?[0]['name'] ?? '',
                      style: GoogleFonts.acme(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      foreward?[0]['address'] ?? '',
                      style: GoogleFonts.acme(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      foreward?[0]['position'] ?? '',
                      style: GoogleFonts.acme(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
