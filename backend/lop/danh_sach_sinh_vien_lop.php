<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Max-Age: 3600");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

$rawInput = file_get_contents("php://input");
$data = json_decode($rawInput, true);

if (!is_array($data)) {
    $data = array_merge($_GET, $_POST);
}

$action = trim($data["action"] ?? "");

function response_json(int $httpCode, array $payload): void {
    http_response_code($httpCode);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit();
}

function require_id(array $data, string $key, string $message): int {
    $id = (int)($data[$key] ?? 0);
    if ($id <= 0) {
        response_json(400, ["status" => "error", "message" => $message]);
    }
    return $id;
}

function bind_keyword(PDOStatement $stmt, string $keyword): void {
    $like = "%" . $keyword . "%";
    $stmt->bindValue(":tu_khoa_msv", $like, PDO::PARAM_STR);
    $stmt->bindValue(":tu_khoa_ten", $like, PDO::PARAM_STR);
    $stmt->bindValue(":tu_khoa_email", $like, PDO::PARAM_STR);
}

function ckc_lop_sv_has_column(PDO $conn, string $table, string $column): bool {
    $db = (string)$conn->query("SELECT DATABASE()")?->fetchColumn();
    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=? AND TABLE_NAME=? AND COLUMN_NAME=?");
    $stmt->execute([$db, $table, $column]);
    return (int)$stmt->fetchColumn() > 0;
}

function ckc_lop_sv_nam_expr(PDO $conn): string {
    if (ckc_lop_sv_has_column($conn, "lop", "nam_nhap_hoc")) {
        return "nam_nhap_hoc";
    }
    if (ckc_lop_sv_has_column($conn, "lop", "khoa_hoc")) {
        return "CASE WHEN khoa_hoc REGEXP '^[0-9]{4}' THEN CAST(SUBSTRING(khoa_hoc,1,4) AS UNSIGNED) WHEN khoa_hoc REGEXP '^[Kk][0-9]{2}' THEN 2000 + CAST(SUBSTRING(khoa_hoc,2,2) AS UNSIGNED) ELSE NULL END";
    }
    return "NULL";
}

$trangThaiHopLe = ["dang_hoc", "tam_nghi", "da_tot_nghiep"];

try {
    switch ($action) {
        case "list": {
            $lopId = require_id($data, "lop_id", "ID lớp không hợp lệ");
            $keyword = trim($data["keyword"] ?? "");
            $trangThai = trim($data["trang_thai"] ?? "");

            if ($trangThai !== "" && !in_array($trangThai, $trangThaiHopLe, true)) {
                response_json(400, [
                    "status" => "error",
                    "message" => "Trạng thái sinh viên không hợp lệ"
                ]);
            }

            $sql = "SELECT
                        sv.id AS id,
                        sv.id AS sinh_vien_id,
                        sv.ma_sinh_vien,
                        nd.ho_ten,
                        nd.email,
                        l.ten_lop,
                        sv.khoa_hoc,
                        sv.trang_thai
                    FROM sinh_vien sv
                    INNER JOIN nguoi_dung nd ON nd.id = sv.nguoi_dung_id
                    INNER JOIN lop l ON l.id = sv.lop_id
                    WHERE sv.lop_id = :lop_id";

            if ($keyword !== "") {
                $sql .= " AND (
                    sv.ma_sinh_vien LIKE :tu_khoa_msv
                    OR nd.ho_ten LIKE :tu_khoa_ten
                    OR nd.email LIKE :tu_khoa_email
                )";
            }

            if ($trangThai !== "") {
                $sql .= " AND sv.trang_thai = :trang_thai";
            }

            $sql .= " ORDER BY sv.ma_sinh_vien ASC, nd.ho_ten ASC";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(":lop_id", $lopId, PDO::PARAM_INT);

            if ($keyword !== "") bind_keyword($stmt, $keyword);
            if ($trangThai !== "") $stmt->bindValue(":trang_thai", $trangThai, PDO::PARAM_STR);

            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            response_json(200, [
                "status" => "success",
                "message" => "Lấy danh sách sinh viên trong lớp thành công",
                "data" => $rows
            ]);
        }

        case "list_add": {
            $lopId = require_id($data, "lop_id", "ID lớp không hợp lệ");
            $keyword = trim($data["keyword"] ?? "");

            $sql = "SELECT
                        sv.id AS id,
                        sv.id AS sinh_vien_id,
                        sv.ma_sinh_vien,
                        nd.ho_ten,
                        nd.email,
                        COALESCE(l.ten_lop, 'Chưa có lớp') AS ten_lop,
                        sv.khoa_hoc,
                        sv.trang_thai
                    FROM sinh_vien sv
                    INNER JOIN nguoi_dung nd ON nd.id = sv.nguoi_dung_id
                    LEFT JOIN lop l ON l.id = sv.lop_id
                    WHERE sv.lop_id <> :lop_id
                      AND sv.trang_thai = 'dang_hoc'
                      AND nd.trang_thai = 'dang_hoat_dong'";

            if ($keyword !== "") {
                $sql .= " AND (
                    sv.ma_sinh_vien LIKE :tu_khoa_msv
                    OR nd.ho_ten LIKE :tu_khoa_ten
                    OR nd.email LIKE :tu_khoa_email
                )";
            }

            $sql .= " ORDER BY sv.ma_sinh_vien ASC, nd.ho_ten ASC";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(":lop_id", $lopId, PDO::PARAM_INT);

            if ($keyword !== "") bind_keyword($stmt, $keyword);

            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            response_json(200, [
                "status" => "success",
                "message" => "Lấy danh sách sinh viên có thể thêm thành công",
                "data" => $rows
            ]);
        }

        case "add": {
            $lopId = require_id($data, "lop_id", "ID lớp không hợp lệ");
            $sinhVienId = require_id($data, "sinh_vien_id", "ID sinh viên không hợp lệ");

            $namExpr = ckc_lop_sv_nam_expr($conn);
            $coDeletedAt = ckc_lop_sv_has_column($conn, "lop", "deleted_at");
            $sqlLop = "SELECT id, khoa_id, {$namExpr} AS nam_nhap_hoc, trang_thai FROM lop WHERE id = :id";
            if ($coDeletedAt) $sqlLop .= " AND deleted_at IS NULL";
            $sqlLop .= " LIMIT 1";
            $lopStmt = $conn->prepare($sqlLop);
            $lopStmt->bindValue(":id", $lopId, PDO::PARAM_INT);
            $lopStmt->execute();
            $lop = $lopStmt->fetch(PDO::FETCH_ASSOC);

            if (!$lop) response_json(404, ["status" => "error", "message" => "Không tìm thấy lớp"]);
            if ($lop["trang_thai"] !== "dang_hoc") {
                response_json(400, ["status" => "error", "message" => "Chỉ có thể thêm sinh viên vào lớp đang học"]);
            }
            $namNhapHoc = (int)($lop["nam_nhap_hoc"] ?? 0);
            if ($namNhapHoc < 2000) {
                response_json(400, ["status" => "error", "message" => "Lớp chưa có năm nhập học hợp lệ, vui lòng cập nhật lớp trước"]);
            }
            $khoaHocSinhVien = $namNhapHoc . "-" . ($namNhapHoc + 3);

            $svStmt = $conn->prepare("SELECT sv.id, sv.lop_id, sv.trang_thai, nd.trang_thai AS trang_thai_tai_khoan
                                      FROM sinh_vien sv
                                      INNER JOIN nguoi_dung nd ON nd.id = sv.nguoi_dung_id
                                      WHERE sv.id = :id
                                      LIMIT 1");
            $svStmt->bindValue(":id", $sinhVienId, PDO::PARAM_INT);
            $svStmt->execute();
            $sv = $svStmt->fetch(PDO::FETCH_ASSOC);

            if (!$sv) response_json(404, ["status" => "error", "message" => "Không tìm thấy sinh viên"]);
            if ($sv["trang_thai_tai_khoan"] !== "dang_hoat_dong") {
                response_json(400, ["status" => "error", "message" => "Tài khoản sinh viên đang bị khóa, không thể chuyển lớp"]);
            }
            if ($sv["trang_thai"] !== "dang_hoc") {
                response_json(400, ["status" => "error", "message" => "Chỉ sinh viên đang học mới được chuyển lớp"]);
            }

            if ((int)$sv["lop_id"] === $lopId) {
                response_json(200, ["status" => "success", "message" => "Sinh viên đã thuộc lớp này"]);
            }

            $stmt = $conn->prepare("UPDATE sinh_vien
                                    SET lop_id = :lop_id,
                                        khoa_id = :khoa_id,
                                        khoa_hoc = :khoa_hoc
                                    WHERE id = :sinh_vien_id");
            $stmt->bindValue(":lop_id", $lopId, PDO::PARAM_INT);
            $stmt->bindValue(":khoa_id", (int)$lop["khoa_id"], PDO::PARAM_INT);
            $stmt->bindValue(":khoa_hoc", $khoaHocSinhVien, PDO::PARAM_STR);
            $stmt->bindValue(":sinh_vien_id", $sinhVienId, PDO::PARAM_INT);
            $stmt->execute();

            response_json(200, [
                "status" => "success",
                "message" => "Đã chuyển sinh viên vào lớp thành công"
            ]);
        }

        case "update_status": {
            $sinhVienId = require_id($data, "id", "ID sinh viên không hợp lệ");
            $trangThai = trim($data["trang_thai"] ?? "");

            if (!in_array($trangThai, $trangThaiHopLe, true)) {
                response_json(400, ["status" => "error", "message" => "Trạng thái sinh viên không hợp lệ"]);
            }

            $stmt = $conn->prepare("UPDATE sinh_vien SET trang_thai = :trang_thai WHERE id = :id");
            $stmt->bindValue(":trang_thai", $trangThai, PDO::PARAM_STR);
            $stmt->bindValue(":id", $sinhVienId, PDO::PARAM_INT);
            $stmt->execute();

            response_json(200, ["status" => "success", "message" => "Cập nhật trạng thái sinh viên thành công"]);
        }

        case "delete": {
            $sinhVienId = require_id($data, "id", "ID sinh viên không hợp lệ");

            $stmt = $conn->prepare("UPDATE sinh_vien SET trang_thai = 'tam_nghi' WHERE id = :id");
            $stmt->bindValue(":id", $sinhVienId, PDO::PARAM_INT);
            $stmt->execute();

            response_json(200, [
                "status" => "success",
                "message" => "Đã chuyển sinh viên sang trạng thái tạm nghỉ"
            ]);
        }

        default:
            response_json(400, ["status" => "error", "message" => "Action không hợp lệ"]);
    }
} catch (PDOException $e) {
    response_json(500, [
        "status" => "error",
        "message" => "Lỗi server khi xử lý sinh viên lớp",
        "detail" => $e->getMessage()
    ]);
}
?>
