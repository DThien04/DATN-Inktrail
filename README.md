# InkTrail

InkTrail là đồ án nền tảng đọc truyện gồm 3 phần:

- `inktrail_client`: ứng dụng Flutter cho người dùng đọc truyện
- `inktrail_admin`: trang quản trị web dùng Next.js
- `inktrail_server`: API server dùng Node.js, Express và Prisma

Repo hiện được tổ chức theo kiểu monorepo để quản lý chung toàn bộ hệ thống trong một nơi.

## Mục tiêu đồ án

Hệ thống phục vụ các nhu cầu chính:

- người dùng duyệt truyện, đọc truyện, lưu lịch sử đọc, tải offline
- người dùng đánh giá, bình luận, báo cáo nội dung vi phạm
- tác giả quản lý truyện và chương của mình
- quản trị viên theo dõi thông báo, broadcast, xử lý báo cáo và kiểm duyệt nội dung
- server hỗ trợ realtime, queue, AI moderation và lưu trữ dữ liệu tập trung

## Cấu trúc thư mục

```text
InkTrail/
├─ inktrail_admin/    # Next.js admin dashboard
├─ inktrail_client/   # Flutter mobile client
├─ inktrail_server/   # Node.js + Express + Prisma backend
└─ .gitignore
```

## Yêu cầu môi trường

### Chung

- Git
- Node.js 20+ và npm

### Cho `inktrail_client`

- Flutter SDK 3.10+
- Android Studio hoặc VS Code với Flutter plugin
- Android SDK hoặc thiết bị/emulator

### Cho `inktrail_server`

- PostgreSQL hoặc Supabase Postgres
- Redis nếu bật queue/realtime adapter

## Thiết lập nhanh

### 1. Clone repo

```bash
git clone https://github.com/DThien04/DATN-Inktrail.git
cd DATN-Inktrail
```

### 2. Tạo file môi trường

#### Server

Từ file mẫu:

```bash
cp inktrail_server/.env.example inktrail_server/.env
```

Điền các biến quan trọng:

- `DATABASE_URL`
- `DIRECT_URL`
- `JWT_ACCESS_SECRET`
- `JWT_REFRESH_SECRET`
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SMTP_USER`
- `SMTP_PASS`
- `GEMINI_API_KEY`
- `ONESIGNAL_APP_ID`
- `ONESIGNAL_REST_API_KEY`
- `REDIS_URL`

#### Admin

```bash
cp inktrail_admin/.env.example inktrail_admin/.env.local
```

Biến bắt buộc:

- `NEXT_PUBLIC_API_BASE_URL`

#### Client

Hiện tại client không dùng `.env.example` riêng trong repo này. Nếu cần đổi API endpoint hoặc config build, hãy kiểm tra lại phần cấu hình hiện có trong source trước khi chạy bản phát hành.

## Cách chạy từng phần

## Chạy backend server

```bash
cd inktrail_server
npm install
npm run build
npm run dev
```

Server production:

```bash
npm start
```

Chạy worker riêng:

```bash
npm run worker
```

Worker cho môi trường dev:

```bash
npm run worker:dev
```

Prisma migrate deploy:

```bash
npm run prisma:migrate
```

Mặc định server dùng:

- `HOST=0.0.0.0`
- `PORT=8080`

## Chạy admin web

```bash
cd inktrail_admin
npm install
npm run dev
```

Build production:

```bash
npm run build
npm start
```

Mặc định Next.js chạy tại:

- `http://localhost:3000`

## Chạy Flutter client

```bash
cd inktrail_client
flutter pub get
flutter run
```

Nếu build apk:

```bash
flutter build apk
```

## Thứ tự chạy khuyến nghị khi demo

1. Chạy `inktrail_server`
2. Chạy `inktrail_admin`
3. Chạy `inktrail_client`
4. Nếu demo queue hoặc notification nền, chạy thêm `inktrail_server` worker

## Mô tả sử dụng

## 1. Người dùng đọc truyện

Luồng cơ bản:

- mở ứng dụng client
- đăng ký hoặc đăng nhập
- duyệt truyện ở trang chủ, tags hoặc tìm kiếm
- vào trang chi tiết truyện
- mở reader để đọc theo chương
- lịch sử đọc sẽ được lưu trong thư viện

## 2. Đánh giá, bình luận, báo cáo

Người dùng có thể:

- đánh giá truyện
- bình luận ở phần đọc chương
- báo cáo truyện, chương hoặc bình luận vi phạm

## 3. Tác giả quản lý nội dung

Trong client:

- tác giả có thể tạo truyện
- cập nhật thông tin truyện
- tạo, sửa, xuất bản hoặc gỡ xuất bản chương

## 4. Quản trị viên

Trong admin:

- theo dõi dữ liệu quản trị
- xử lý báo cáo
- phát broadcast
- kiểm tra nội dung cần kiểm duyệt

## Công nghệ sử dụng

### Client

- Flutter
- Bloc/Cubit
- Dio
- Drift
- OneSignal

### Admin

- Next.js
- React
- TypeScript

### Server

- Node.js
- Express
- Prisma
- PostgreSQL
- Redis
- BullMQ
- Socket.IO

## Tệp môi trường mẫu

- Server: [inktrail_server/.env.example](./inktrail_server/.env.example)
- Admin: [inktrail_admin/.env.example](./inktrail_admin/.env.example)

## Ghi chú bảo mật

- Không commit file `.env` thật
- Không commit secret Supabase, JWT, SMTP, Gemini, OneSignal, Redis
- Nếu secret từng bị lộ, cần rotate trước khi deploy thật

## Gợi ý deploy

### Server

Có thể deploy riêng `inktrail_server` lên Render:

- chọn đúng `Root Directory = inktrail_server`
- build command: `npm install`
- start command: `npm start`

Nếu dùng queue:

- có thể chạy thêm worker như một service riêng

### Admin

Có thể deploy `inktrail_admin` lên Vercel hoặc Render.

### Client

Client build và phát hành riêng bằng Flutter.

## Thành phần cần chú ý khi chấm/demo

- đăng nhập và khôi phục phiên
- trang chi tiết truyện và reader
- thư viện và đọc offline
- flow báo cáo và xử lý báo cáo
- quản lý truyện/chương của tác giả
- trang quản trị admin

## Tác giả

Repo: https://github.com/DThien04/DATN-Inktrail

