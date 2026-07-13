# Deploy Railway

Du an nay gom 2 phan:

- `backend/`: PHP API thuan, chay voi MySQL.
- `ckc_class_app/`: Flutter app, goi API qua URL `/backend`.

## 1. Deploy backend PHP

1. Push code len GitHub.
2. Tren Railway, service `ckc_class_mobile` se build bang `Dockerfile` o root repo.
3. Vao service `ckc_class_mobile` -> Settings -> Networking -> Generate Domain.
4. URL API sau khi deploy se co dang:

```text
https://<domain-railway>/backend
```

Vi du test nhanh:

```text
https://<domain-railway>/backend/dang_nhap.php
```

Neu GET endpoint login se tra JSON bao chi ho tro POST la backend da chay.

## 2. Ket noi MySQL Railway

Project da co MySQL service. Import file `ckc_class_web_mobile.sql` vao database cua MySQL service.

Trong service `ckc_class_mobile` -> Variables, them cac bien sau bang autocomplete/reference toi service MySQL cua ban:

```env
MYSQLHOST=${{ MySQL-Main.MYSQLHOST }}
MYSQLPORT=${{ MySQL-Main.MYSQLPORT }}
MYSQLUSER=${{ MySQL-Main.MYSQLUSER }}
MYSQLPASSWORD=${{ MySQL-Main.MYSQLPASSWORD }}
MYSQLDATABASE=${{ MySQL-Main.MYSQLDATABASE }}
MYSQL_URL=${{ MySQL-Main.MYSQL_URL }}
APP_DEBUG=false
```

Neu ten MySQL service khac `MySQL-Main`, chon dung ten service trong Railway UI.

## 3. Cau hinh Cloudinary neu dung upload file

Khong dua `backend/upload/cloudinary_local.php` len image production. Docker da ignore file nay.

Them mot trong cac cach sau vao Variables cua service backend:

```env
CLOUDINARY_URL=cloudinary://API_KEY:API_SECRET@CLOUD_NAME
```

Hoac:

```env
CLOUDINARY_CLOUD_NAME=...
CLOUDINARY_API_KEY=...
CLOUDINARY_API_SECRET=...
```

## 4. Build Flutter app tro ve backend live

Khi build web/apk/release, truyen URL backend Railway:

```bash
flutter build web --dart-define=API_BASE_URL=https://<domain-railway>/backend
flutter build apk --release --dart-define=API_BASE_URL=https://<domain-railway>/backend
```

Neu khong truyen `API_BASE_URL`, app van dung fallback local:

- Flutter Web: `http://localhost/backend`
- Android Emulator: `http://10.0.2.2/backend`
- Desktop: `http://localhost/backend`

## 5. Loi build hien tai tren Railway

Log cu bao:

```text
Script start.sh not found
Railpack could not determine how to build the app.
```

Nguyen nhan la root repo co ca Flutter va PHP thuan, Railway/Railpack khong tu doan duoc app can build. `Dockerfile` moi o root repo giai quyet viec nay bang cach chay Apache + PHP va copy `backend/` vao `/var/www/html/backend`.
