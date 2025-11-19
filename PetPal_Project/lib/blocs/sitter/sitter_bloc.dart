import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/sitter_profile.dart';
import '../../repositories/sitter_repository.dart';

part 'sitter_event.dart';
part 'sitter_state.dart';

class SitterBloc extends Bloc<SitterEvent, SitterState> {
  SitterBloc(this._sitterRepository) : super(const SitterState.initial()) {
    on<SittersRequested>(_onRequested);
  }

  final SitterRepository _sitterRepository;

  Future<void> _onRequested(
    SittersRequested event,
    Emitter<SitterState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final sitters = await _sitterRepository.fetchSitters(
        location: event.location,
      );
      emit(state.copyWith(isLoading: false, sitters: sitters));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }
}
