import 'package:bloc/bloc.dart';

class ChatState {}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatState());

  // TODO: fetch conversation, send messages, listen for updates
}
