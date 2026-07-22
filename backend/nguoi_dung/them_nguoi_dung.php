<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Max-Age: 3600");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    echo json_encode([
        "status" => "error",
        "message" => "Chỉ hỗ trợ phương thức POST"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

function tra_loi_nguoi_dung(int $code, string $status, string $message, ?array $data = null): void
{
    http_response_code($code);
    $payload = ["status" => $status, "message" => $message];
    if ($data !== null) {
        $payload["data"] = $data;
    }
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit();
}

function ckc_co_cot_nguoi_dung(PDO $conn, string $table, string $column): bool
{
    $db = (string)$conn->query("SELECT DATABASE()")?->fetchColumn();
    $stmt = $conn->prepare(
        "SELECT COUNT(*)
         FROM INFORMATION_SCHEMA.COLUMNS
         WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND COLUMN_NAME = ?"
    );
    $stmt->execute([$db, $table, $column]);
    return (int)$stmt->fetchColumn() > 0;
}

$input = json_decode(file_get_contents("php://input"), true);
if (!is_array($input)) {
    $input = $_POST;
}

$hoTen = trim((string)($input["ho_ten"] ?? ""));
$email = strtolower(trim((string)($input["email"] ?? "")));
$matKhau = trim((string)($input["mat_khau"] ?? ""));
$vaiTroId = (int)($input["vai_tro_id"] ?? 0);
$trangThai = trim((string)($input["trang_thai"] ?? "dang_hoat_dong"));

$maSinhVien = trim((string)($input["ma_sinh_vien"] ?? ""));
$lopId = (int)($input["lop_id"] ?? 0);
$khoaId = (int)($input["khoa_id"] ?? 0);

$maGiangVien = trim((string)($input["ma_giang_vien"] ?? ""));
$boMonId = (int)($input["bo_mon_id"] ?? 0);

if ($hoTen === "") {
    tra_loi_nguoi_dung(400, "error", "Họ tên không được để trống");
}
if ($email === "" || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    tra_loi_nguoi_dung(400, "error", "Email không hợp lệ");
}
if (strlen($matKhau) < 6) {
    tra_loi_nguoi_dung(400, "error", "Mật khẩu phải có ít nhất 6 ký tự");
}
if ($vaiTroId <= 0) {
    tra_loi_nguoi_dung(400, "error", "Vui lòng chọn vai trò");
}
if (!in_array($trangThai, ["dang_hoat_dong", "bi_khoa"], true)) {
    tra_loi_nguoi_dung(400, "error", "Trạng thái người dùng không hợp lệ");
}

try {
    $stmt = $conn->prepare("SELECT id, ten_vai_tro FROM vai_tro WHERE id = :id LIMIT 1");
    $stmt->execute([":id" => $vaiTroId]);
    $vaiTro = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$vaiTro) {
        tra_loi_nguoi_dung(404, "error", "Vai trò không tồn tại");
    }

    $tenVaiTro = (string)$vaiTro["ten_vai_tro"];
    if (!in_array($tenVaiTro, ["quan_tri", "giang_vien", "sinh_vien"], true)) {
        tra_loi_nguoi_dung(400, "error", "Vai trò chưa được hỗ trợ");
    }

    $stmt = $conn->prepare("SELECT id FROM nguoi_dung WHERE email = :email LIMIT 1");
    $stmt->execute([":email" => $email]);
    if ($stmt->fetch()) {
        tra_loi_nguoi_dung(409, "error", "Email đã tồn tại");
    }

    $lop = null;
    $khoaHocSinhVien = null;

    if ($tenVaiTro === "sinh_vien") {
        if ($lopId <= 0) {
            tra_loi_nguoi_dung(400, "error", "Vui lòng chọn lớp hành chính cho sinh viên");
        }
        if ($khoaId <= 0) {
            tra_loi_nguoi_dung(400, "error", "Vui lòng chọn khoa cho sinh viên");
        }

        $coNamNhapHoc = ckc_co_cot_nguoi_dung($conn, "lop", "nam_nhap_hoc");
        $coKhoaHoc = ckc_co_cot_nguoi_dung($conn, "lop", "khoa_hoc");
        $coDeletedAt = ckc_co_cot_nguoi_dung($conn, "lop", "deleted_at");

        if ($coNamNhapHoc) {
            $namExpr = "nam_nhap_hoc";
        } elseif ($coKhoaHoc) {
            $namExpr = "CASE
                WHEN khoa_hoc REGEXP '^[0-9]{4}' THEN CAST(SUBSTRING(khoa_hoc, 1, 4) AS UNSIGNED)
                WHEN khoa_hoc REGEXP '^[Kk][0-9]{2}' THEN 2000 + CAST(SUBSTRING(khoa_hoc, 2, 2) AS UNSIGNED)
                ELSE NULL
            END";
        } else {
            $namExpr = "NULL";
        }

        $sqlLop = "SELECT id, khoa_id, trang_thai, {$namExpr} AS nam_nhap_hoc
                   FROM lop
                   WHERE id = :id";
        if ($coDeletedAt) {
            $sqlLop .= " AND deleted_at IS NULL";
        }
        $sqlLop .= " LIMIT 1";

        $stmt = $conn->prepare($sqlLop);
        $stmt->execute([":id" => $lopId]);
        $lop = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$lop) {
            tra_loi_nguoi_dung(404, "error", "Lớp hành chính không tồn tại");
        }
        if ((int)$lop["khoa_id"] !== $khoaId) {
            tra_loi_nguoi_dung(400, "error", "Lớp hành chính không thuộc khoa đã chọn");
        }
        if ((string)$lop["trang_thai"] !== "dang_hoc") {
            tra_loi_nguoi_dung(400, "error", "Chỉ có thể thêm sinh viên vào lớp đang học");
        }

        $stmt = $conn->prepare("SELECT id, trang_thai FROM khoa WHERE id = :id LIMIT 1");
        $stmt->execute([":id" => $khoaId]);
        $khoa = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$khoa) {
            tra_loi_nguoi_dung(404, "error", "Khoa không tồn tại");
        }

        if ($maSinhVien !== "") {
            $stmt = $conn->prepare("SELECT id FROM sinh_vien WHERE ma_sinh_vien = :ma LIMIT 1");
            $stmt->execute([":ma" => $maSinhVien]);
            if ($stmt->fetch()) {
                tra_loi_nguoi_dung(409, "error", "Mã sinh viên đã tồn tại");
            }
        }

        $namNhapHoc = (int)($lop["nam_nhap_hoc"] ?? 0);
        if ($namNhapHoc >= 2000) {
            $khoaHocSinhVien = $namNhapHoc . "-" . ($namNhapHoc + 3);
        }
    }

    if ($tenVaiTro === "giang_vien") {
        if ($boMonId > 0) {
            $stmt = $conn->prepare("SELECT id FROM bo_mon WHERE id = :id LIMIT 1");
            $stmt->execute([":id" => $boMonId]);
            if (!$stmt->fetch()) {
                tra_loi_nguoi_dung(404, "error", "Bộ môn không tồn tại");
            }
        }

        if ($maGiangVien !== "") {
            $stmt = $conn->prepare("SELECT id FROM giang_vien WHERE ma_giang_vien = :ma LIMIT 1");
            $stmt->execute([":ma" => $maGiangVien]);
            if ($stmt->fetch()) {
                tra_loi_nguoi_dung(409, "error", "Mã giảng viên đã tồn tại");
            }
        }
    }

    $matKhauHash = password_hash($matKhau, PASSWORD_DEFAULT);
    if ($matKhauHash === false) {
        tra_loi_nguoi_dung(500, "error", "Không thể mã hóa mật khẩu");
    }

    $conn->beginTransaction();

    $stmt = $conn->prepare(
        "INSERT INTO nguoi_dung (ho_ten, email, mat_khau, vai_tro_id, trang_thai)
         VALUES (:ho_ten, :email, :mat_khau, :vai_tro_id, :trang_thai)"
    );
    $stmt->execute([
        ":ho_ten" => $hoTen,
        ":email" => $email,
        ":mat_khau" => $matKhauHash,
        ":vai_tro_id" => $vaiTroId,
        ":trang_thai" => $trangThai,
    ]);

    $nguoiDungId = (int)$conn->lastInsertId();
    $ketQuaThem = [];

    if ($tenVaiTro === "sinh_vien") {
        if ($maSinhVien === "") {
            $maSinhVien = "SV" . str_pad((string)$nguoiDungId, 6, "0", STR_PAD_LEFT);
        }

        $coKhoaHocSinhVien = ckc_co_cot_nguoi_dung($conn, "sinh_vien", "khoa_hoc");
        if ($coKhoaHocSinhVien) {
            $stmt = $conn->prepare(
                "INSERT INTO sinh_vien
                    (nguoi_dung_id, ma_sinh_vien, lop_id, khoa_id, khoa_hoc, trang_thai)
                 VALUES
                    (:nguoi_dung_id, :ma_sinh_vien, :lop_id, :khoa_id, :khoa_hoc, 'dang_hoc')"
            );
            $stmt->bindValue(":khoa_hoc", $khoaHocSinhVien, $khoaHocSinhVien === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
        } else {
            $stmt = $conn->prepare(
                "INSERT INTO sinh_vien
                    (nguoi_dung_id, ma_sinh_vien, lop_id, khoa_id, trang_thai)
                 VALUES
                    (:nguoi_dung_id, :ma_sinh_vien, :lop_id, :khoa_id, 'dang_hoc')"
            );
        }

        $stmt->bindValue(":nguoi_dung_id", $nguoiDungId, PDO::PARAM_INT);
        $stmt->bindValue(":ma_sinh_vien", $maSinhVien, PDO::PARAM_STR);
        $stmt->bindValue(":lop_id", $lopId, PDO::PARAM_INT);
        $stmt->bindValue(":khoa_id", $khoaId, PDO::PARAM_INT);
        $stmt->execute();

        $ketQuaThem = [
            "sinh_vien_id" => (int)$conn->lastInsertId(),
            "ma_sinh_vien" => $maSinhVien,
            "lop_id" => $lopId,
            "khoa_id" => $khoaId,
            "khoa_hoc" => $khoaHocSinhVien,
        ];
    }

    if ($tenVaiTro === "giang_vien") {
        if ($maGiangVien === "") {
            $maGiangVien = "GV" . str_pad((string)$nguoiDungId, 6, "0", STR_PAD_LEFT);
        }

        $stmt = $conn->prepare(
            "INSERT INTO giang_vien
                (nguoi_dung_id, ma_giang_vien, bo_mon_id, trang_thai)
             VALUES
                (:nguoi_dung_id, :ma_giang_vien, :bo_mon_id, 'dang_day')"
        );
        $stmt->bindValue(":nguoi_dung_id", $nguoiDungId, PDO::PARAM_INT);
        $stmt->bindValue(":ma_giang_vien", $maGiangVien, PDO::PARAM_STR);
        $stmt->bindValue(":bo_mon_id", $boMonId > 0 ? $boMonId : null, $boMonId > 0 ? PDO::PARAM_INT : PDO::PARAM_NULL);
        $stmt->execute();

        $ketQuaThem = [
            "giang_vien_id" => (int)$conn->lastInsertId(),
            "ma_giang_vien" => $maGiangVien,
            "bo_mon_id" => $boMonId > 0 ? $boMonId : null,
        ];
    }

    $conn->commit();

    tra_loi_nguoi_dung(201, "success", "Thêm người dùng thành công", array_merge([
        "id" => $nguoiDungId,
        "ho_ten" => $hoTen,
        "email" => $email,
        "vai_tro_id" => $vaiTroId,
        "ten_vai_tro" => $tenVaiTro,
        "trang_thai" => $trangThai,
    ], $ketQuaThem));
} catch (PDOException $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }

    $message = "Lỗi server khi thêm người dùng";
    $sqlState = (string)$e->getCode();
    $detail = $e->getMessage();

    if ($sqlState === "23000" || str_contains($detail, "Duplicate entry")) {
        $message = "Email, mã sinh viên hoặc mã giảng viên đã tồn tại";
    }

    tra_loi_nguoi_dung(500, "error", $message, ["detail" => $detail]);
} catch (Throwable $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    tra_loi_nguoi_dung(500, "error", "Lỗi server khi thêm người dùng", ["detail" => $e->getMessage()]);
}
