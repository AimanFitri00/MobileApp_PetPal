import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/app_user.dart';
import '../../repositories/vet_repository.dart';

part 'vet_event.dart';
part 'vet_state.dart';

class VetBloc extends Bloc<VetEvent, VetState> {
  VetBloc(this._vetRepository) : super(const VetState.initial()) {
    on<VetsRequested>(_onRequested);
  }

  final VetRepository _vetRepository;

  Future<void> _onRequested(VetsRequested event, Emitter<VetState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final vets = await _vetRepository.fetchVets(
        location: event.location,
        specialization: event.specialization,
      );
      emit(state.copyWith(isLoading: false, vets: vets));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }
}
