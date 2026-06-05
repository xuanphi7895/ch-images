
# Giải thích BLoC trong Flutter

## 1. BLoC là gì?

BLoC hoạt động theo flow:

UI
↓
Event
↓
Bloc xử lý business logic
↓
State mới
↓
UI rebuild

Ví dụ:
User click Login button
→ LoginEvent
→ AuthBloc xử lý API login
→ LoginSuccessState
→ UI chuyển sang HomePage

---

## 2. Vai trò của từng file

### `_event.dart`

Mô tả:
“User hoặc system muốn làm gì?”

Event là INPUT của Bloc.

Ví dụ:

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  LoginEvent(this.username, this.password);
}

Ý nghĩa:
User yêu cầu login.

---

### `_bloc.dart`

Đây là nơi:
- xử lý business logic
- gọi API
- xử lý async
- emit state mới

Ví dụ:

on<LoginEvent>((event, emit) async {
   emit(AuthLoading());

   try {
      final user = await repository.login(
         event.username,
         event.password,
      );

      emit(AuthSuccess(user));
   } catch (e) {
      emit(AuthError(e.toString()));
   }
});

Bloc giống Controller / Processor.

---

### `_state.dart`

Mô tả:
“Ứng dụng hiện đang ở trạng thái nào?”

State là OUTPUT của Bloc.

Ví dụ:

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

---

## 3. Tại sao phải có Initial / Loading / Error?

### Initial
Màn hình vừa mở, chưa làm gì cả.

### Loading
Đang gọi API.
UI sẽ show loading indicator.

### Success
API thành công.
UI sẽ navigate hoặc hiển thị dữ liệu.

### Error
API thất bại.
UI sẽ hiển thị lỗi.

---

## 4. Event vs State

### Event = ACTION
User muốn làm gì?

Ví dụ:
- LoginEvent
- LoadLessonEvent
- SpeakTextEvent

### State = STATUS
App hiện đang thế nào?

Ví dụ:
- Loading
- Loaded
- Error
- Success

---

## 5. Flow thực tế

User click button
↓
Add Event
↓
Bloc xử lý
↓
Emit State
↓
UI rebuild

---

## 6. Tại sao Senior thích BLoC?

BLoC giúp:
- scalable
- predictable
- testable
- clean architecture
- enterprise-friendly

Phù hợp với:
- banking
- ERP
- healthcare
- enterprise apps

---

## 7. Kết luận

| Thành phần | Ý nghĩa |
|------------|----------|
| Event | User muốn làm gì |
| Bloc | Xử lý logic |
| State | Kết quả/trạng thái hiện tại |
