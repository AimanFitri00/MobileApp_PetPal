part of 'activity_bloc.dart';

class ActivityState extends Equatable {
  const ActivityState({
    required this.isLoading,
    required this.logs,
    this.errorMessage,
  });

  const ActivityState.initial() : this(isLoading: false, logs: const []);

  final bool isLoading;
  final List<ActivityLog> logs;
  final String? errorMessage;

  ActivityState copyWith({
    bool? isLoading,
    List<ActivityLog>? logs,
    String? errorMessage,
  }) {
    return ActivityState(
      isLoading: isLoading ?? this.isLoading,
      logs: logs ?? this.logs,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, logs, errorMessage];
}
