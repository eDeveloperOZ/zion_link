import 'package:flutter/material.dart';
import 'dart:io';
import 'app.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure plugin services are initialized
  // Initialize Supabase client
  Supabase.initialize(
    url: 'https://xuqlsduamvqnxcsxaezf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1cWxzZHVhbXZxbnhjc3hhZXpmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTAzNDk0NjYsImV4cCI6MjAyNTkyNTQ2Nn0.Ev1CC78jMcoXtbaUgh2ngWybjKZzsFmTf4hTHee-mx0', // Replace with your Supabase anon key
  );

  try {
    runApp(App());
  } catch (e) {
    print('An error occurred: $e');
    exit(1);
  }
}
