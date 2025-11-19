part of 'booking_bloc.dart';

class BookingState extends Equatable {
  const BookingState({
    required this.isLoading,
    required this.bookings,
    this.errorMessage,
  });

  const BookingState.initial() : this(isLoading: false, bookings: const []);

  final bool isLoading;
  final List<Booking> bookings;
  final String? errorMessage;

  BookingState copyWith({
    bool? isLoading,
    List<Booking>? bookings,
    String? errorMessage,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      bookings: bookings ?? this.bookings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, bookings, errorMessage];
}
