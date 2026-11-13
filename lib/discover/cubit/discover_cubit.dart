import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myalien/discover/repository/discover_repository.dart';

part 'discover_state.dart';

class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit({required this.repo}) : super(const DiscoverInitial());
  final DiscoverRepository repo;

  Future<void> fetchDiscoverItems() async {
    emit(const DiscoverLoading());
    try {
      final items = await repo.fetchDiscoverItems();
      emit(DiscoverLoaded(items: items));
    } catch (e) {
      emit(DiscoverError(message: e.toString()));
    }
  }
}
