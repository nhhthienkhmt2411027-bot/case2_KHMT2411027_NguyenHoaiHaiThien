# TaskManager (Flutter)

- MSSV: <điền MSSV>
- Họ tên: <điền họ tên>

Frontend cho Case Study 2 — ứng dụng quản lý và giao công việc nhóm.

## Chạy ứng dụng

```bash
flutter pub get
# Android emulator (mặc định http://10.0.2.2:3000/api)
flutter run
# Thiết bị thật / địa chỉ khác
flutter run --dart-define=API_URL=http://192.168.1.10:3000/api
```

## Hợp đồng API mà app mong đợi

| Endpoint | Response |
| --- | --- |
| `POST /auth/login`, `POST /auth/register` | `{ token, user }` |
| `GET/PUT /auth/me` | user |
| `PUT /auth/change-password` | body `{ currentPassword, newPassword }` |
| `GET /tasks` | mảng task (hoặc `{ tasks: [...] }`), populate `createdBy`, `assigneeIds`; nên có `permission`: `owner` / `editor` / `viewer` |
| `POST /tasks/:id/assignees` | body `{ userIds: [...] }` |
| `PATCH /tasks/:id/assignees/:userId` | body `{ isPrimary: true }` |
| `POST /tasks/:id/shares` | body `{ shares: [{ userId, permission }] }` |
| `GET /notifications/unread-count` | `{ count }` |
| `GET /statistics/tasks` | `{ total, todo, in_progress, completed }` |
| `GET /statistics/assignments` | `{ assigned, primary }` |
| `GET /statistics/deadlines` | `{ upcoming, overdue }` |

Response có thể bọc trong `{ "data": ... }`, app tự bóc. Lỗi trả về dạng `{ "message": "..." }`.
