import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../models/activity_log.dart';
import '../../repositories/activity_repository.dart';

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  ActivityBloc(this._repository) : super(const ActivityState.initial()) {
    on<ActivityLogsRequested>(_onRequested);
    on<ActivityLogged>(_onLogged);
  }

  final ActivityRepository _repository;
  final _uuid = const Uuid();

  Future<void> _onRequested(
    ActivityLogsRequested event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final logs = await _repository.fetchLogs(event.petId);
      emit(state.copyWith(isLoading: false, logs: logs));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onLogged(
    ActivityLogged event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final log = event.log.copyWith(id: _uuid.v4());
      await _repository.logActivity(log);
      emit(state.copyWith(isLoading: false, logs: [...state.logs, log]));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }
}
