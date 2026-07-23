<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . "/../ket_noi.php";

$data = json_decode(file_get_contents("php://input"), true) ?? [];
$action = trim($data["action"] ?? "");
$lopHocPhanId = (int)($data["lop_hoc_phan_id"] ?? 0);
$tuKhoa = trim($data["tu_khoa"] ?? "");

function respond($status, $message, $extra = []) {
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}

function ensure_thong_bao_schema_sv(PDO $conn) {
    $db = (string)$conn->query("SELECT DATABASE()")->fetchColumn();

    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=? AND TABLE_NAME='thong_bao' AND COLUMN_NAME='bai_viet_id'");
    $stmt->execute([$db]);
    if ((int)$stmt->fetchColumn() === 0) {
        $conn->exec("ALTER TABLE thong_bao ADD COLUMN bai_viet_id INT NULL AFTER nguoi_tao_id");
        try { $conn->exec("ALTER TABLE thong_bao ADD INDEX idx_thong_bao_bai_viet (bai_viet_id)"); } catch (Throwable $e) {}
    }

    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=? AND TABLE_NAME='binh_luan' AND COLUMN_NAME='thong_bao_id'");
    $stmt->execute([$db]);
    if ((int)$stmt->fetchColumn() === 0) {
        $conn->exec("ALTER TABLE binh_luan ADD COLUMN thong_bao_id INT NULL AFTER bai_viet_id");
        try { $conn->exec("ALTER TABLE binh_luan ADD INDEX idx_binh_luan_thong_bao (thong_bao_id)"); } catch (Throwable $e) {}
    }

    $conn->exec("UPDATE binh_luan bl
        JOIN thong_bao tb ON tb.bai_viet_id = bl.bai_viet_id
        SET bl.thong_bao_id = tb.id
        WHERE bl.thong_bao_id IS NULL");
}

function lay_files_thong_bao_sv(PDO $conn, ?int $baiVietId): array {
    if (!$baiVietId) return [];
    $stmt = $conn->prepare("SELECT tt.id, tt.ten_file, tt.ten_file_luu, tt.duong_dan, tt.loai_file, tt.kich_thuoc, tt.ngay_tao
        FROM tep_tin_bai_viet tbv
        JOIN tep_tin tt ON tt.id = tbv.tep_tin_id
        WHERE tbv.bai_viet_id = ? AND tt.trang_thai <> 'da_xoa'
        ORDER BY tbv.id ASC");
    $stmt->execute([$baiVietId]);
    return array_map(fn($r) => [
        'id' => (int)$r['id'],
        'ten_file' => $r['ten_file'],
        'ten_file_goc' => $r['ten_file'],
        'duong_dan' => $r['duong_dan'],
        'duong_dan_file' => $r['duong_dan'],
        'loai_file' => $r['loai_file'],
        'kich_thuoc' => (int)$r['kich_thuoc'],
        'ngay_tao' => $r['ngay_tao'],
    ], $stmt->fetchAll(PDO::FETCH_ASSOC));
}

if ($lopHocPhanId <= 0) { http_response_code(400); respond("error", "ID lớp học phần không hợp lệ"); }

try {
    ensure_thong_bao_schema_sv($conn);

    if ($action === "tai_lieu") {
        $sql = "SELECT tl.*, nd.ho_ten AS ten_nguoi_tao
                FROM tai_lieu tl
                LEFT JOIN nguoi_dung nd ON tl.nguoi_tao_id = nd.id
                WHERE tl.lop_hoc_phan_id = :lhp AND tl.trang_thai = 'hien_thi'";
        $params = [":lhp" => $lopHocPhanId];
        if ($tuKhoa !== "") { $sql .= " AND tl.tieu_de LIKE :tk"; $params[":tk"] = "%$tuKhoa%"; }
        $sql .= " ORDER BY tl.ngay_tao DESC";

        $stmt = $conn->prepare($sql);
        $stmt->bindValue(":lhp", $lopHocPhanId, PDO::PARAM_INT);
        if ($tuKhoa !== "") $stmt->bindValue(":tk", "%$tuKhoa%", PDO::PARAM_STR);
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $result = array_map(fn($r) => [
            "id" => (int)$r["id"],
            "tieu_de" => $r["tieu_de"],
            "mo_ta" => $r["mo_ta"],
            "duong_dan_file" => $r["duong_dan_file"],
            "ten_nguoi_tao" => $r["ten_nguoi_tao"],
            "ngay_tao" => $r["ngay_tao"],
            "ngay_cap_nhat" => $r["ngay_cap_nhat"],
        ], $rows);
        respond("success", "Lấy danh sách tài liệu thành công", ["data" => $result]);
    }

    if ($action === "thong_bao") {
        $sql = "SELECT tb.*, nd.ho_ten AS ten_nguoi_tao,
                    (SELECT COUNT(*) FROM binh_luan bl
                     WHERE bl.trang_thai = 'hien_thi'
                       AND (
                         bl.thong_bao_id = tb.id
                         OR (tb.bai_viet_id IS NOT NULL AND bl.bai_viet_id = tb.bai_viet_id)
                       )) AS so_binh_luan
                FROM thong_bao tb
                LEFT JOIN nguoi_dung nd ON tb.nguoi_tao_id = nd.id
                WHERE tb.lop_hoc_phan_id = :lhp
                  AND tb.trang_thai = 'hien_thi'
                  AND (tb.thoi_gian_gui IS NULL OR tb.thoi_gian_gui <= NOW())
                ORDER BY COALESCE(tb.thoi_gian_gui, tb.ngay_tao) DESC, tb.ngay_tao DESC";
        $stmt = $conn->prepare($sql);
        $stmt->bindValue(":lhp", $lopHocPhanId, PDO::PARAM_INT);
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $result = [];
        foreach ($rows as $r) {
            $baiVietId = !empty($r['bai_viet_id']) ? (int)$r['bai_viet_id'] : null;
            $result[] = [
                "id" => (int)$r["id"],
                "bai_viet_id" => $baiVietId,
                "tieu_de" => $r["tieu_de"],
                "noi_dung" => $r["noi_dung"],
                "thoi_gian_gui" => $r["thoi_gian_gui"],
                "ten_nguoi_tao" => $r["ten_nguoi_tao"],
                "ngay_tao" => $r["ngay_tao"],
                "ngay_cap_nhat" => $r["ngay_cap_nhat"],
                "so_binh_luan" => (int)$r["so_binh_luan"],
                "files" => lay_files_thong_bao_sv($conn, $baiVietId),
            ];
        }
        respond("success", "Lấy danh sách thông báo thành công", ["data" => $result]);
    }

    http_response_code(400);
    respond("error", "Hành động không hợp lệ. Dùng 'tai_lieu' hoặc 'thong_bao'");
} catch (Throwable $e) {
    http_response_code(500);
    respond("error", "Lỗi server: " . $e->getMessage());
}
?>
