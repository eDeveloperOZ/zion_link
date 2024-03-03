import 'package:flutter/material.dart';
import 'dart:io';
import 'app.dart';

void main() {
  try {
    runApp(App());
  } catch (e) {
    print('An error occurred: $e');
    exit(1);
  }
}