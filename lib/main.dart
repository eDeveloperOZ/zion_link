import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'app.dart';
import 'core/utils/logger.dart';

void main() {
  try {
    Supabase.initialize(
      url: 'https://xuqlsduamvqnxcsxaezf.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1cWxzZHVhbXZxbnhjc3hhZXpmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTAzNDk0NjYsImV4cCI6MjAyNTkyNTQ2Nn0.Ev1CC78jMcoXtbaUgh2ngWybjKZzsFmTf4hTHee-mx0',
    );
    runApp(App());
  } catch (e) {
    Logger.error('Error occurred while initializing: $e');
    exit(1);
  }
}
