<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }
require_once __DIR__ . "/../ket_noi.php";

$input = json_decode(file_get_contents("php://input"), true);
if (!is_array($input)) $input = array_merge($_GET, $_POST);
$tuKhoa = trim((string)($input['tu_khoa'] ?? ''));
$khoaId = (int)($input['khoa_id'] ?? 0);
$namNhapHocRaw = trim((string)($input['nam_nhap_hoc'] ?? ''));
$trangThai = trim((string)($input['trang_thai'] ?? ''));
$trangThaiHopLe = ['', 'dang_hoc', 'da_tot_nghiep', 'tam_khoa'];

function reply(int $code, array $payload): void {
    http_response_code($code);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit();
}
if (!in_array($trangThai, $trangThaiHopLe, true)) reply(400, ['status'=>'error','message'=>'Trạng thái lớp không hợp lệ']);
$namNhapHoc = null;
if ($namNhapHocRaw !== '') {
    if (!preg_match('/^\d{4}$/', $namNhapHocRaw)) reply(400, ['status'=>'error','message'=>'Năm nhập học không hợp lệ']);
    $namNhapHoc = (int)$namNhapHocRaw;
    $maxYear = (int)date('Y') + 2;
    if ($namNhapHoc < 2000 || $namNhapHoc > $maxYear) reply(400, ['status'=>'error','message'=>'Năm nhập học không hợp lệ']);
}

try {
    $sql = "SELECT l.id,l.ma_lop,l.ten_lop,l.khoa_id,l.nam_nhap_hoc,l.trang_thai,l.ngay_tao,l.ngay_cap_nhat,
                   k.ma_khoa,k.ten_khoa,k.trang_thai AS trang_thai_khoa,k.ngay_tao AS ngay_tao_khoa,k.ngay_cap_nhat AS ngay_cap_nhat_khoa,
                   COUNT(sv.id) AS so_luong_sinh_vien
            FROM lop l
            LEFT JOIN khoa k ON k.id=l.khoa_id
            LEFT JOIN sinh_vien sv ON sv.lop_id=l.id
            WHERE l.deleted_at IS NULL";
    $params = [];
    if ($tuKhoa !== '') {
        $sql .= " AND (l.ma_lop LIKE :tk1 OR l.ten_lop LIKE :tk2 OR CAST(l.nam_nhap_hoc AS CHAR) LIKE :tk3 OR k.ma_khoa LIKE :tk4 OR k.ten_khoa LIKE :tk5)";
        for ($i=1;$i<=5;$i++) $params[":tk$i"]="%$tuKhoa%";
    }
    if ($khoaId > 0) { $sql .= " AND l.khoa_id=:khoa_id"; $params[':khoa_id']=$khoaId; }
    if ($namNhapHoc !== null) { $sql .= " AND l.nam_nhap_hoc=:nam_nhap_hoc"; $params[':nam_nhap_hoc']=$namNhapHoc; }
    if ($trangThai !== '') { $sql .= " AND l.trang_thai=:trang_thai"; $params[':trang_thai']=$trangThai; }
    $sql .= " GROUP BY l.id,l.ma_lop,l.ten_lop,l.khoa_id,l.nam_nhap_hoc,l.trang_thai,l.ngay_tao,l.ngay_cap_nhat,
                      k.ma_khoa,k.ten_khoa,k.trang_thai,k.ngay_tao,k.ngay_cap_nhat
              ORDER BY l.id DESC";
    $stmt=$conn->prepare($sql);
    foreach($params as $key=>$value) $stmt->bindValue($key,$value,in_array($key,[':khoa_id',':nam_nhap_hoc'],true)?PDO::PARAM_INT:PDO::PARAM_STR);
    $stmt->execute();
    $rows=$stmt->fetchAll(PDO::FETCH_ASSOC);
    $result=array_map(static function(array $r): array {
        return [
            'id'=>(int)$r['id'],'ma_lop'=>$r['ma_lop'],'ten_lop'=>$r['ten_lop'],'khoa_id'=>(int)$r['khoa_id'],
            'nam_nhap_hoc'=>$r['nam_nhap_hoc']!==null?(int)$r['nam_nhap_hoc']:null,'trang_thai'=>$r['trang_thai'],
            'ngay_tao'=>$r['ngay_tao'],'ngay_cap_nhat'=>$r['ngay_cap_nhat'],'so_luong_sinh_vien'=>(int)$r['so_luong_sinh_vien'],
            'ma_khoa'=>$r['ma_khoa'],'ten_khoa'=>$r['ten_khoa'],
            'khoa'=>['id'=>(int)$r['khoa_id'],'ma_khoa'=>$r['ma_khoa'],'ten_khoa'=>$r['ten_khoa'],'trang_thai'=>$r['trang_thai_khoa'],'ngay_tao'=>$r['ngay_tao_khoa'],'ngay_cap_nhat'=>$r['ngay_cap_nhat_khoa']]
        ];
    },$rows);
    reply(200,['status'=>'success','message'=>'Lấy danh sách lớp thành công','data'=>$result]);
} catch (PDOException $e) {
    reply(500,['status'=>'error','message'=>'Lỗi server khi lấy danh sách lớp','detail'=>$e->getMessage()]);
}
