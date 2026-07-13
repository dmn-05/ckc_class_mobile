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

$data = json_decode(file_get_contents("php://input"), true) ?? [];

$giangVienId = (int)($data["giang_vien_id"] ?? 0);
$tuKhoa      = trim((string)($data["tu_khoa"] ?? ""));
$trangThai   = trim((string)($data["trang_thai"] ?? ""));
$hocKy       = trim((string)($data["hoc_ky"] ?? ""));
$khoaHoc     = trim((string)($data["khoa_hoc"] ?? ""));
$namHoc      = trim((string)($data["nam_hoc"] ?? ""));

function phan_hoi(string $status, string $message, array $extra = []): void
{
    echo json_encode(
        array_merge(["status" => $status, "message" => $message], $extra),
        JSON_UNESCAPED_UNICODE
    );
    exit();
}

function db_has_table(PDO $conn, string $table): bool
{
    $db = $conn->query("SELECT DATABASE()")->fetchColumn();
    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=? AND TABLE_NAME=?");
    $stmt->execute([$db, $table]);
    return (int)$stmt->fetchColumn() > 0;
}

if ($giangVienId <= 0) {
    http_response_code(400);
    phan_hoi("error", "ID giảng viên không hợp lệ");
}

$trangThaiHopLe = ["", "dang_mo", "da_khoa", "da_ket_thuc"];
if (!in_array($trangThai, $trangThaiHopLe, true)) {
    http_response_code(400);
    phan_hoi("error", "Trạng thái lớp học phần không hợp lệ");
}

try {
    $sql = "SELECT
                lhp.id,
                lhp.ma_lop_hoc_phan,
                lhp.ten_lop,
                lhp.hoc_ky,
                lhp.nam_hoc,
                COALESCE(NULLIF(lhp.khoa_hoc, ''), NULLIF(lhp.nam_hoc, '')) AS khoa_hoc,
                lhp.si_so_toi_da,
                lhp.trang_thai,
                lhp.ngay_tao,
                lhp.ngay_cap_nhat,
                mh.id AS mon_hoc_id,
                mh.ma_mon,
                mh.ten_mon,
                mh.tin_chi,
                (
                    SELECT COUNT(*)
                    FROM sinh_vien_lop_hoc_phan svlhp
                    WHERE svlhp.lop_hoc_phan_id = lhp.id
                      AND svlhp.trang_thai = 'dang_hoc'
                ) AS so_sinh_vien,
                (
                    SELECT COUNT(*)
                    FROM bai_tap bt
                    WHERE bt.lop_hoc_phan_id = lhp.id
                      AND bt.trang_thai <> 'an'
                ) AS so_bai_tap,
                (
                    SELECT COUNT(*)
                    FROM tai_lieu tl
                    WHERE tl.lop_hoc_phan_id = lhp.id
                      AND tl.trang_thai = 'hien_thi'
                ) AS so_tai_lieu
            FROM lop_hoc_phan lhp
            LEFT JOIN mon_hoc mh ON mh.id = lhp.mon_hoc_id";

    $coBangPhanCongGv = db_has_table($conn, 'giang_vien_lop_hoc_phan');
    if ($coBangPhanCongGv) {
        $sql .= " LEFT JOIN giang_vien_lop_hoc_phan gvlhp
                    ON gvlhp.lop_hoc_phan_id = lhp.id
                   AND gvlhp.giang_vien_id = :giang_vien_id_map";
        $sql .= " WHERE (lhp.giang_vien_id = :giang_vien_id OR gvlhp.giang_vien_id IS NOT NULL)";
        $params = [":giang_vien_id" => $giangVienId, ":giang_vien_id_map" => $giangVienId];
    } else {
        $sql .= " WHERE lhp.giang_vien_id = :giang_vien_id";
        $params = [":giang_vien_id" => $giangVienId];
    }

    if ($tuKhoa !== "") {
        $sql .= " AND (
                    lhp.ma_lop_hoc_phan LIKE :tu_khoa_1
                    OR lhp.ten_lop LIKE :tu_khoa_2
                    OR mh.ma_mon LIKE :tu_khoa_3
                    OR mh.ten_mon LIKE :tu_khoa_4
                    OR lhp.hoc_ky LIKE :tu_khoa_5
                    OR lhp.nam_hoc LIKE :tu_khoa_6
                    OR lhp.khoa_hoc LIKE :tu_khoa_7
                )";
        for ($i = 1; $i <= 7; $i++) {
            $params[":tu_khoa_$i"] = "%$tuKhoa%";
        }
    }

    if ($trangThai !== "") {
        $sql .= " AND lhp.trang_thai = :trang_thai";
        $params[":trang_thai"] = $trangThai;
    }

    if ($hocKy !== "") {
        $sql .= " AND lhp.hoc_ky = :hoc_ky";
        $params[":hoc_ky"] = $hocKy;
    }

    if ($khoaHoc !== "") {
        $sql .= " AND COALESCE(NULLIF(lhp.khoa_hoc, ''), NULLIF(lhp.nam_hoc, '')) = :khoa_hoc";
        $params[":khoa_hoc"] = $khoaHoc;
    }

    // Giữ tham số nam_hoc cũ để không làm hỏng các phiên bản app trước.
    if ($namHoc !== "") {
        $sql .= " AND lhp.nam_hoc = :nam_hoc";
        $params[":nam_hoc"] = $namHoc;
    }

    $sql .= " ORDER BY lhp.ngay_tao DESC, lhp.id DESC";

    $stmt = $conn->prepare($sql);
    foreach ($params as $key => $value) {
        $stmt->bindValue(
            $key,
            $value,
            in_array($key, [":giang_vien_id", ":giang_vien_id_map"], true) ? PDO::PARAM_INT : PDO::PARAM_STR
        );
    }
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $result = array_map(static function (array $row): array {
        return [
            "id" => (int)$row["id"],
            "ma_lop_hoc_phan" => $row["ma_lop_hoc_phan"],
            "ten_lop" => $row["ten_lop"],
            "hoc_ky" => $row["hoc_ky"],
            "nam_hoc" => $row["nam_hoc"],
            "khoa_hoc" => $row["khoa_hoc"],
            "si_so_toi_da" => $row["si_so_toi_da"] !== null
                ? (int)$row["si_so_toi_da"]
                : null,
            "trang_thai" => $row["trang_thai"],
            "ngay_tao" => $row["ngay_tao"],
            "ngay_cap_nhat" => $row["ngay_cap_nhat"],
            "mon_hoc_id" => $row["mon_hoc_id"] !== null
                ? (int)$row["mon_hoc_id"]
                : null,
            "ma_mon" => $row["ma_mon"],
            "ten_mon" => $row["ten_mon"],
            "tin_chi" => $row["tin_chi"] !== null ? (int)$row["tin_chi"] : null,
            "so_sinh_vien" => (int)$row["so_sinh_vien"],
            "so_bai_tap" => (int)$row["so_bai_tap"],
            "so_tai_lieu" => (int)$row["so_tai_lieu"],
        ];
    }, $rows);

    phan_hoi(
        "success",
        "Lấy danh sách lớp học phần thành công",
        ["data" => $result]
    );
} catch (Throwable $e) {
    http_response_code(500);
    phan_hoi("error", "Lỗi server: " . $e->getMessage());
}
