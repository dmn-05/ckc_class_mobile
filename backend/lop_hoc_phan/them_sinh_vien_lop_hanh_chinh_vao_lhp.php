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

$rawInput = file_get_contents("php://input");
$data = json_decode($rawInput, true);

$lopHocPhanId = 0;
$lopId = 0;

if (is_array($data)) {
    $lopHocPhanId = (int)($data["lop_hoc_phan_id"] ?? 0);
    $lopId = (int)($data["lop_id"] ?? 0);
} else {
    $lopHocPhanId = (int)($_POST["lop_hoc_phan_id"] ?? 0);
    $lopId = (int)($_POST["lop_id"] ?? 0);
}

if ($lopHocPhanId <= 0 || $lopId <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "ID lớp học phần hoặc lớp hành chính không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $conn->beginTransaction();

    $checkLhpSql = "SELECT id, ma_lop_hoc_phan, ten_lop, si_so_toi_da, trang_thai
                    FROM lop_hoc_phan
                    WHERE id = :lop_hoc_phan_id
                    LIMIT 1
                    FOR UPDATE";
    $checkLhpStmt = $conn->prepare($checkLhpSql);
    $checkLhpStmt->bindValue(":lop_hoc_phan_id", $lopHocPhanId, PDO::PARAM_INT);
    $checkLhpStmt->execute();
    $lopHocPhan = $checkLhpStmt->fetch(PDO::FETCH_ASSOC);

    if (!$lopHocPhan) {
        $conn->rollBack();
        http_response_code(404);
        echo json_encode(["status" => "error", "message" => "Không tìm thấy lớp học phần"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($lopHocPhan["trang_thai"] !== "dang_mo") {
        $conn->rollBack();
        http_response_code(400);
        echo json_encode(["status" => "error", "message" => "Chỉ được thêm sinh viên vào lớp học phần đang mở"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $checkLopSql = "SELECT id, ma_lop, ten_lop, trang_thai
                    FROM lop
                    WHERE id = :lop_id
                    LIMIT 1";
    $checkLopStmt = $conn->prepare($checkLopSql);
    $checkLopStmt->bindValue(":lop_id", $lopId, PDO::PARAM_INT);
    $checkLopStmt->execute();
    $lop = $checkLopStmt->fetch(PDO::FETCH_ASSOC);

    if (!$lop) {
        $conn->rollBack();
        http_response_code(404);
        echo json_encode(["status" => "error", "message" => "Không tìm thấy lớp hành chính"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($lop["trang_thai"] !== "dang_hoc") {
        $conn->rollBack();
        http_response_code(400);
        echo json_encode(["status" => "error", "message" => "Chỉ được thêm sinh viên từ lớp hành chính đang học"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $dsSvSql = "SELECT sv.id AS sinh_vien_id
                FROM sinh_vien sv
                INNER JOIN nguoi_dung nd ON nd.id = sv.nguoi_dung_id
                WHERE sv.lop_id = :lop_id
                  AND sv.trang_thai = 'dang_hoc'
                  AND nd.trang_thai = 'dang_hoat_dong'
                ORDER BY sv.ma_sinh_vien ASC";
    $dsSvStmt = $conn->prepare($dsSvSql);
    $dsSvStmt->bindValue(":lop_id", $lopId, PDO::PARAM_INT);
    $dsSvStmt->execute();
    $dsSinhVien = $dsSvStmt->fetchAll(PDO::FETCH_ASSOC);

    if (empty($dsSinhVien)) {
        $conn->rollBack();
        echo json_encode(["status" => "error", "message" => "Lớp hành chính không có sinh viên đang học để thêm"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $countSql = "SELECT COUNT(*)
                 FROM sinh_vien_lop_hoc_phan
                 WHERE lop_hoc_phan_id = :lop_hoc_phan_id
                   AND trang_thai = 'dang_hoc'";
    $countStmt = $conn->prepare($countSql);
    $countStmt->bindValue(":lop_hoc_phan_id", $lopHocPhanId, PDO::PARAM_INT);
    $countStmt->execute();
    $soDangHoc = (int)$countStmt->fetchColumn();

    $siSoToiDa = $lopHocPhan["si_so_toi_da"] !== null ? (int)$lopHocPhan["si_so_toi_da"] : null;

    $checkDangKyStmt = $conn->prepare("SELECT id, trang_thai
                                       FROM sinh_vien_lop_hoc_phan
                                       WHERE sinh_vien_id = :sinh_vien_id
                                         AND lop_hoc_phan_id = :lop_hoc_phan_id
                                       LIMIT 1
                                       FOR UPDATE");

    $insertStmt = $conn->prepare("INSERT INTO sinh_vien_lop_hoc_phan (sinh_vien_id, lop_hoc_phan_id, trang_thai)
                                  VALUES (:sinh_vien_id, :lop_hoc_phan_id, 'dang_hoc')");

    $updateStmt = $conn->prepare("UPDATE sinh_vien_lop_hoc_phan
                                  SET trang_thai = 'dang_hoc', ngay_dang_ky = CURRENT_TIMESTAMP
                                  WHERE id = :id");

    $daThemMoi = 0;
    $daKichHoatLai = 0;
    $boQuaDaCo = 0;
    $boQuaHoanThanh = 0;
    $boQuaHetCho = 0;

    foreach ($dsSinhVien as $sv) {
        if ($siSoToiDa !== null && $soDangHoc >= $siSoToiDa) {
            $boQuaHetCho++;
            continue;
        }

        $sinhVienId = (int)$sv["sinh_vien_id"];

        $checkDangKyStmt->bindValue(":sinh_vien_id", $sinhVienId, PDO::PARAM_INT);
        $checkDangKyStmt->bindValue(":lop_hoc_phan_id", $lopHocPhanId, PDO::PARAM_INT);
        $checkDangKyStmt->execute();
        $dangKy = $checkDangKyStmt->fetch(PDO::FETCH_ASSOC);

        if ($dangKy) {
            if ($dangKy["trang_thai"] === "dang_hoc") {
                $boQuaDaCo++;
                continue;
            }

            if ($dangKy["trang_thai"] === "hoan_thanh") {
                $boQuaHoanThanh++;
                continue;
            }

            if ($dangKy["trang_thai"] === "da_huy") {
                $updateStmt->bindValue(":id", (int)$dangKy["id"], PDO::PARAM_INT);
                $updateStmt->execute();
                $daKichHoatLai++;
                $soDangHoc++;
                continue;
            }
        }

        $insertStmt->bindValue(":sinh_vien_id", $sinhVienId, PDO::PARAM_INT);
        $insertStmt->bindValue(":lop_hoc_phan_id", $lopHocPhanId, PDO::PARAM_INT);
        $insertStmt->execute();
        $daThemMoi++;
        $soDangHoc++;
    }

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "Thêm sinh viên từ lớp hành chính hoàn tất",
        "data" => [
            "tong_sinh_vien_lop_hanh_chinh" => count($dsSinhVien),
            "da_them_moi" => $daThemMoi,
            "da_kich_hoat_lai" => $daKichHoatLai,
            "bo_qua_da_co" => $boQuaDaCo,
            "bo_qua_da_hoan_thanh" => $boQuaHoanThanh,
            "bo_qua_het_cho" => $boQuaHetCho
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }

    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi thêm sinh viên từ lớp hành chính",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
