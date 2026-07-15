<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";
require_once __DIR__ . "/../_lop_hoc_phan_guard.php";

$data = json_decode(file_get_contents("php://input"), true) ?? [];
$action = trim($data["action"] ?? "");

function respond($status, $message, $extra = []) {
    echo json_encode(
        array_merge(["status" => $status, "message" => $message], $extra),
        JSON_UNESCAPED_UNICODE
    );
    exit();
}

function int_val($data, $key, $default = 0) {
    return isset($data[$key]) ? (int)$data[$key] : $default;
}

function str_val($data, $key, $default = "") {
    return trim((string)($data[$key] ?? $default));
}

try {
    if ($action === 'them') {
        ckc_require_lhp_mutable($conn, (int)($data['lop_hoc_phan_id'] ?? 0));
    } elseif (in_array($action, ['sua', 'xoa'], true)) {
        ckc_require_lhp_mutable($conn, ckc_lhp_id_from_chu_de($conn, (int)($data['chu_de_id'] ?? 0)));
    }

    switch ($action) {

        case "danh_sach": {
            $lopHocPhanId = int_val($data, "lop_hoc_phan_id");

            if ($lopHocPhanId <= 0) {
                respond("error", "ID lớp học phần không hợp lệ");
            }

            $stmt = $conn->prepare("
                SELECT 
                    cd.id,
                    cd.ten_chu_de,
                    cd.lop_hoc_phan_id,
                    cd.thu_tu,
                    cd.trang_thai,
                    cd.ngay_tao,
                    cd.ngay_cap_nhat,
                    COUNT(bt.id) AS so_bai_tap
                FROM chu_de cd
                LEFT JOIN bai_tap bt 
                    ON bt.chu_de_id = cd.id
                    AND bt.trang_thai IN ('dang_mo', 'da_dong')
                WHERE cd.lop_hoc_phan_id = ?
                  AND cd.trang_thai = 'dang_mo'
                GROUP BY 
                    cd.id,
                    cd.ten_chu_de,
                    cd.lop_hoc_phan_id,
                    cd.thu_tu,
                    cd.trang_thai,
                    cd.ngay_tao,
                    cd.ngay_cap_nhat
                ORDER BY cd.thu_tu ASC, cd.id ASC
            ");
            $stmt->execute([$lopHocPhanId]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $result = array_map(fn($r) => [
                "id"              => (int)$r["id"],
                "ten_chu_de"      => $r["ten_chu_de"],
                "lop_hoc_phan_id" => (int)$r["lop_hoc_phan_id"],
                "thu_tu"          => (int)$r["thu_tu"],
                "trang_thai"      => $r["trang_thai"],
                "ngay_tao"        => $r["ngay_tao"],
                "ngay_cap_nhat"   => $r["ngay_cap_nhat"],
                "so_bai_tap"      => (int)$r["so_bai_tap"],
            ], $rows);

            respond("success", "Lấy danh sách chủ đề thành công", [
                "data" => $result
            ]);
        }

        case "them": {
            $lopHocPhanId = int_val($data, "lop_hoc_phan_id");
            $tenChuDe = str_val($data, "ten_chu_de");

            if ($lopHocPhanId <= 0) {
                respond("error", "ID lớp học phần không hợp lệ");
            }

            if ($tenChuDe === "") {
                respond("error", "Tên chủ đề không được để trống");
            }

            $stmtCheck = $conn->prepare("
                SELECT id 
                FROM chu_de 
                WHERE lop_hoc_phan_id = ?
                  AND ten_chu_de = ?
                  AND trang_thai = 'dang_mo'
                LIMIT 1
            ");
            $stmtCheck->execute([$lopHocPhanId, $tenChuDe]);

            if ($stmtCheck->fetch(PDO::FETCH_ASSOC)) {
                respond("error", "Chủ đề này đã tồn tại trong lớp");
            }

            $stmtMax = $conn->prepare("
                SELECT COALESCE(MAX(thu_tu), 0) + 1
                FROM chu_de
                WHERE lop_hoc_phan_id = ?
            ");
            $stmtMax->execute([$lopHocPhanId]);
            $thuTu = (int)$stmtMax->fetchColumn();

            $stmt = $conn->prepare("
                INSERT INTO chu_de 
                    (ten_chu_de, lop_hoc_phan_id, thu_tu, trang_thai)
                VALUES 
                    (?, ?, ?, 'dang_mo')
            ");
            $stmt->execute([$tenChuDe, $lopHocPhanId, $thuTu]);

            respond("success", "Thêm chủ đề thành công", [
                "id" => (int)$conn->lastInsertId()
            ]);
        }

        case "sua": {
            $chuDeId = int_val($data, "chu_de_id");
            $tenChuDe = str_val($data, "ten_chu_de");

            if ($chuDeId <= 0) {
                respond("error", "ID chủ đề không hợp lệ");
            }

            if ($tenChuDe === "") {
                respond("error", "Tên chủ đề không được để trống");
            }

            $stmtOld = $conn->prepare("
                SELECT lop_hoc_phan_id
                FROM chu_de
                WHERE id = ?
                  AND trang_thai = 'dang_mo'
                LIMIT 1
            ");
            $stmtOld->execute([$chuDeId]);
            $old = $stmtOld->fetch(PDO::FETCH_ASSOC);

            if (!$old) {
                respond("error", "Không tìm thấy chủ đề");
            }

            $lopHocPhanId = (int)$old["lop_hoc_phan_id"];

            $stmtCheck = $conn->prepare("
                SELECT id
                FROM chu_de
                WHERE lop_hoc_phan_id = ?
                  AND ten_chu_de = ?
                  AND id <> ?
                  AND trang_thai = 'dang_mo'
                LIMIT 1
            ");
            $stmtCheck->execute([$lopHocPhanId, $tenChuDe, $chuDeId]);

            if ($stmtCheck->fetch(PDO::FETCH_ASSOC)) {
                respond("error", "Tên chủ đề đã tồn tại");
            }

            $stmt = $conn->prepare("
                UPDATE chu_de
                SET ten_chu_de = ?,
                    ngay_cap_nhat = NOW()
                WHERE id = ?
            ");
            $stmt->execute([$tenChuDe, $chuDeId]);

            respond("success", "Cập nhật chủ đề thành công");
        }

        case "xoa": {
            $chuDeId = int_val($data, "chu_de_id");

            if ($chuDeId <= 0) {
                respond("error", "ID chủ đề không hợp lệ");
            }

            $stmtOld = $conn->prepare("
                SELECT id
                FROM chu_de
                WHERE id = ?
                  AND trang_thai = 'dang_mo'
                LIMIT 1
            ");
            $stmtOld->execute([$chuDeId]);

            if (!$stmtOld->fetch(PDO::FETCH_ASSOC)) {
                respond("error", "Không tìm thấy chủ đề");
            }

            $conn->beginTransaction();

            $stmt1 = $conn->prepare("
                UPDATE bai_tap
                SET chu_de_id = NULL,
                    ngay_cap_nhat = NOW()
                WHERE chu_de_id = ?
            ");
            $stmt1->execute([$chuDeId]);

            $stmt2 = $conn->prepare("
                UPDATE chu_de
                SET trang_thai = 'da_dong',
                    ngay_cap_nhat = NOW()
                WHERE id = ?
            ");
            $stmt2->execute([$chuDeId]);

            $conn->commit();

            respond("success", "Xóa chủ đề thành công");
        }

        default:
            respond("error", "Hành động không hợp lệ");
    }

} catch (PDOException $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }

    http_response_code(500);
    respond("error", "Lỗi server: " . $e->getMessage());
}
?>