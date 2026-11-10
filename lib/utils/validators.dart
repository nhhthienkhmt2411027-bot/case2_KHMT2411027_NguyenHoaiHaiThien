class Validators {
  static String? required(String? v, [String label = 'Trường này']) =>
      (v == null || v.trim().isEmpty) ? '$label không được để trống' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email không được để trống';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Email không hợp lệ';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Mật khẩu không được để trống';
    if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) =>
      (v) => v != original() ? 'Mật khẩu xác nhận không khớp' : null;
}
