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
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}

function db_has_column(PDO $conn, string $table, string $column): bool {
    $db = $conn->query("SELECT DATABASE()")->fetchColumn();
    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=? AND TABLE_NAME=? AND COLUMN_NAME=?");
    $stmt->execute([$db, $table, $column]);
    return (int)$stmt->fetchColumn() > 0;
}

function ensure_submission_schema(PDO $conn): void {
    if (!db_has_column($conn, 'bai_nop', 'ten_file_goc')) {
        $conn->exec("ALTER TABLE bai_nop ADD COLUMN ten_file_goc VARCHAR(50) NULL AFTER sinh_vien_id");
    }
}

function file_name_from_url(?string $url): string {
    $url = trim((string)$url);
    if ($url === '') return 'file_nop_bai';
    $path = parse_url($url, PHP_URL_PATH) ?: $url;
    $base = basename(str_replace('\\', '/', $path));
    return $base !== '' ? $base : 'file_nop_bai';
}

function file_ext_from_name(string $name): string {
    return strtolower(pathinfo($name, PATHINFO_EXTENSION));
}


function decode_submission_files($raw, $fallbackName, int $baiNopId, $ngayNop = null): array {
    $raw = trim((string)$raw);
    if ($raw === '') return [];

    $decoded = json_decode($raw, true);
    $items = is_array($decoded) && array_is_list($decoded) ? $decoded : null;
    if ($items === null) {
        $name = trim((string)$fallbackName);
        if ($name === '') $name = file_name_from_url($raw);
        return [[
            'id' => $baiNopId,
            'bai_nop_id' => $baiNopId,
            'ten_file_goc' => $name,
            'duong_dan_file' => $raw,
            'loai_file' => file_ext_from_name($name !== '' ? $name : $raw),
            'kich_thuoc' => 0,
            'public_id' => null,
            'ngay_tao' => $ngayNop,
        ]];
    }

    $result = [];
    foreach ($items as $index => $item) {
        if (!is_array($item)) continue;
        $url = trim((string)($item['duong_dan_file'] ?? $item['duong_dan'] ?? $item['secure_url'] ?? $item['url'] ?? ''));
        if ($url === '') continue;
        $name = trim((string)($item['ten_file_goc'] ?? $item['ten_file'] ?? ''));
        if ($name === '') $name = file_name_from_url($url);
        $result[] = [
            'id' => (int)($item['id'] ?? ($baiNopId * 100 + $index + 1)),
            'bai_nop_id' => $baiNopId,
            'ten_file_goc' => $name,
            'duong_dan_file' => $url,
            'loai_file' => strtolower((string)($item['loai_file'] ?? file_ext_from_name($name))),
            'kich_thuoc' => (int)($item['kich_thuoc'] ?? $item['bytes'] ?? 0),
            'public_id' => $item['public_id'] ?? null,
            'ngay_tao' => $item['ngay_tao'] ?? $ngayNop,
        ];
    }
    return $result;
}

try {
    if ($action === 'cham_diem') {
        ckc_require_lhp_mutable($conn, ckc_lhp_id_from_bai_nop($conn, (int)($data['id'] ?? 0)));
    }

    ensure_submission_schema($conn);

    if ($action === "danh_sach") {
        $baiTapId = (int)($data["bai_tap_id"] ?? 0);
        $trangThai = trim($data["trang_thai"] ?? "");

        if ($baiTapId <= 0) respond("error", "ID bài tập không hợp lệ");

        $sql = "
            SELECT
                bn.id,
                bn.bai_tap_id,
                bn.sinh_vien_id,
                bn.ten_file_goc,
                sv.ma_sinh_vien,
                nd.ho_ten AS ten_sinh_vien,
                nd.email AS email_sinh_vien,
                bn.duong_dan_file,
                bn.diem,
                bn.nhan_xet,
                bn.trang_thai,
                bn.ngay_cham,
                bn.giang_vien_cham_id,
                gvnd.ho_ten AS ten_giang_vien_cham,
                bn.ngay_nop,
                bn.ngay_cap_nhat
            FROM bai_nop bn
            LEFT JOIN sinh_vien sv ON bn.sinh_vien_id = sv.id
            LEFT JOIN nguoi_dung nd ON sv.nguoi_dung_id = nd.id
            LEFT JOIN giang_vien gv ON bn.giang_vien_cham_id = gv.id
            LEFT JOIN nguoi_dung gvnd ON gv.nguoi_dung_id = gvnd.id
            WHERE bn.bai_tap_id = :bt
        ";
        $params = [":bt" => $baiTapId];

        if ($trangThai !== "") {
            $sql .= " AND bn.trang_thai = :tt";
            $params[":tt"] = $trangThai;
        }

        $sql .= " ORDER BY bn.ngay_nop DESC";

        $stmt = $conn->prepare($sql);
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v, is_int($v) ? PDO::PARAM_INT : PDO::PARAM_STR);
        }
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $result = array_map(function ($r) {
            $id = (int)$r["id"];
            $files = decode_submission_files(
                $r["duong_dan_file"] ?? '',
                $r["ten_file_goc"] ?? '',
                $id,
                $r["ngay_nop"] ?? null
            );
            $firstFile = !empty($files) ? $files[0] : null;
            $fileUrl = $firstFile['duong_dan_file'] ?? null;
            $tenFile = $firstFile['ten_file_goc'] ?? trim((string)($r["ten_file_goc"] ?? ''));
            return [
                "id" => $id,
                "bai_tap_id" => (int)$r["bai_tap_id"],
                "sinh_vien_id" => (int)$r["sinh_vien_id"],
                "ma_sinh_vien" => $r["ma_sinh_vien"] ?? "",
                "ten_sinh_vien" => $r["ten_sinh_vien"] ?? "",
                "email_sinh_vien" => $r["email_sinh_vien"] ?? "",
                "ten_file_goc" => $tenFile,
                "duong_dan_file" => $fileUrl,
                "files" => $files,
                "diem" => $r["diem"] !== null ? (float)$r["diem"] : null,
                "nhan_xet" => $r["nhan_xet"],
                "trang_thai" => $r["trang_thai"],
                "ngay_cham" => $r["ngay_cham"],
                "giang_vien_cham_id" => $r["giang_vien_cham_id"] !== null ? (int)$r["giang_vien_cham_id"] : null,
                "ten_giang_vien_cham" => $r["ten_giang_vien_cham"],
                "ngay_nop" => $r["ngay_nop"],
                "ngay_cap_nhat" => $r["ngay_cap_nhat"],
            ];
        }, $rows);

        respond("success", "Lấy danh sách bài nộp thành công", ["data" => $result]);
    }

    if ($action === "cham_diem") {
        $id = (int)($data["id"] ?? 0);
        $diem = isset($data["diem"]) && $data["diem"] !== "" ? (float)$data["diem"] : null;
        $nhanXet = trim($data["nhan_xet"] ?? "");
        $giangVienChamId = (int)($data["giang_vien_cham_id"] ?? 0);

        if ($id <= 0) respond("error", "ID bài nộp không hợp lệ");
        if ($diem !== null && ($diem < 0 || $diem > 10)) respond("error", "Điểm phải từ 0 đến 10");
        if ($giangVienChamId <= 0) respond("error", "ID giảng viên chấm không hợp lệ");

        $stmt = $conn->prepare("
            UPDATE bai_nop
            SET diem = ?,
                nhan_xet = ?,
                trang_thai = 'da_cham',
                ngay_cham = NOW(),
                giang_vien_cham_id = ?,
                ngay_cap_nhat = NOW()
            WHERE id = ?
        ");
        $stmt->execute([$diem, $nhanXet, $giangVienChamId, $id]);

        respond("success", "Chấm điểm thành công");
    }

    http_response_code(400);
    respond("error", "Hành động không hợp lệ");

} catch (Throwable $e) {
    http_response_code(500);
    respond("error", "Lỗi server: " . $e->getMessage());
}
?>
