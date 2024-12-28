import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

//Controller
class ChatPageController {
  Future<Map<String, dynamic>> addMessage(Map<String, dynamic> message) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'add_message_to_the_chat',
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: message,
      );
      return response.data;
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'result': 'error',
        'operation_message': 'Unexpected error',
      };
    }
  }

  Future<Map<String, dynamic>> deleteMessage(String messageId) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'delete_message_from_the_chat',
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: {"messageId": messageId},
      );
      return response.data;
    } catch (e) {
      return {
        'result': 'error',
        'operation_message': 'Unexpected error',
      };
    }
  }
}
