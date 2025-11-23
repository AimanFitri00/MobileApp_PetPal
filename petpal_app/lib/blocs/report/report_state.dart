part of 'report_bloc.dart';

class ReportState extends Equatable {
  const ReportState({
    required this.isLoading,
    required this.isExporting,
    this.reportData,
    this.exportedBytes,
    this.errorMessage,
  });

  const ReportState.initial() : this(isLoading: false, isExporting: false);

  final bool isLoading;
  final bool isExporting;
  final Map<String, dynamic>? reportData;
  final Uint8List? exportedBytes;
  final String? errorMessage;

  ReportState copyWith({
    bool? isLoading,
    bool? isExporting,
    Map<String, dynamic>? reportData,
    Uint8List? exportedBytes,
    String? errorMessage,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      isExporting: isExporting ?? this.isExporting,
      reportData: reportData ?? this.reportData,
      exportedBytes: exportedBytes ?? this.exportedBytes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isExporting,
    reportData,
    exportedBytes,
    errorMessage,
  ];
}
