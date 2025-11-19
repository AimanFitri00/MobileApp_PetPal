part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingsRequested extends BookingEvent {
  const BookingsRequested(this.ownerId);

  final String ownerId;

  @override
  List<Object?> get props => [ownerId];
}

class BookingCreated extends BookingEvent {
  const BookingCreated(this.booking);

  final Booking booking;

  @override
  List<Object?> get props => [booking];
}

class BookingStatusUpdated extends BookingEvent {
  const BookingStatusUpdated(this.booking, this.status);

  final Booking booking;
  final BookingStatus status;

  @override
  List<Object?> get props => [booking, status];
}
