import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/hotel_stay.dart';
import '../../repositories/hotel_repository.dart';

// Events
abstract class HotelEvent extends Equatable {
  const HotelEvent();

  @override
  List<Object?> get props => [];
}

class HotelStaysRequested extends HotelEvent {
  const HotelStaysRequested(this.vetId);
  final String vetId;

  @override
  List<Object?> get props => [vetId];
}

class HotelStayAdded extends HotelEvent {
  const HotelStayAdded(this.stay);
  final HotelStay stay;

  @override
  List<Object?> get props => [stay];
}

class HotelStayUpdated extends HotelEvent {
  const HotelStayUpdated(this.stay);
  final HotelStay stay;

  @override
  List<Object?> get props => [stay];
}

// State
class HotelState extends Equatable {
  const HotelState({
    this.stays = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<HotelStay> stays;
  final bool isLoading;
  final String? errorMessage;

  @override
  List<Object?> get props => [stays, isLoading, errorMessage];

  HotelState copyWith({
    List<HotelStay>? stays,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HotelState(
      stays: stays ?? this.stays,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Bloc
class HotelBloc extends Bloc<HotelEvent, HotelState> {
  HotelBloc(this._hotelRepository) : super(const HotelState()) {
    on<HotelStaysRequested>(_onStaysRequested);
    on<HotelStayAdded>(_onStayAdded);
    on<HotelStayUpdated>(_onStayUpdated);
    on<_HotelStaysUpdated>(_onStaysUpdated);
  }

  final HotelRepository _hotelRepository;
  StreamSubscription? _staysSubscription;

  Future<void> _onStaysRequested(
    HotelStaysRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await _staysSubscription?.cancel();
    _staysSubscription = _hotelRepository
        .getHotelStaysForVet(event.vetId)
        .listen((stays) {
      add(_HotelStaysUpdated(stays));
    }, onError: (error) {
       // Handle stream error if needed
    });
  }

  // Internal event to handle stream updates
  Future<void> _onStaysUpdated(
    _HotelStaysUpdated event,
    Emitter<HotelState> emit,
  ) async {
    emit(state.copyWith(stays: event.stays, isLoading: false));
  }
  
  Future<void> _onStayAdded(
    HotelStayAdded event,
    Emitter<HotelState> emit,
  ) async {
    try {
      await _hotelRepository.addHotelStay(event.stay);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onStayUpdated(
    HotelStayUpdated event,
    Emitter<HotelState> emit,
  ) async {
    try {
      await _hotelRepository.updateHotelStay(event.stay);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _staysSubscription?.cancel();
    return super.close();
  }
  
  // Registering internal event handler in constructor
  @override
  void onEvent(HotelEvent event) {
    super.onEvent(event);
    if (event is _HotelStaysUpdated) {
        // This logic is actually better placed in the constructor `on`
    }
  }
}

class _HotelStaysUpdated extends HotelEvent {
  const _HotelStaysUpdated(this.stays);
  final List<HotelStay> stays;
}
