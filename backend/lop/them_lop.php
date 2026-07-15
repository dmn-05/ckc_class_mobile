<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if ($_SERVER['REQUEST_METHOD']==='OPTIONS'){http_response_code(200);exit();}
if ($_SERVER['REQUEST_METHOD']!=='POST'){http_response_code(405);echo json_encode(['status'=>'error','message'=>'Chỉ hỗ trợ phương thức POST'],JSON_UNESCAPED_UNICODE);exit();}
require_once __DIR__.'/../ket_noi.php';
function reply(int $code,array $payload):void{http_response_code($code);echo json_encode($payload,JSON_UNESCAPED_UNICODE);exit();}
$input=json_decode(file_get_contents('php://input'),true); if(!is_array($input))$input=$_POST;
$maLop=strtoupper(trim((string)($input['ma_lop']??'')));
$tenLop=trim((string)($input['ten_lop']??''));
$khoaId=(int)($input['khoa_id']??0);
$namNhapHoc=(int)($input['nam_nhap_hoc']??0);
$trangThai=trim((string)($input['trang_thai']??'dang_hoc'));
if($maLop==='')reply(400,['status'=>'error','message'=>'Mã lớp không được để trống']);
if($tenLop==='')reply(400,['status'=>'error','message'=>'Tên lớp không được để trống']);
if($khoaId<=0)reply(400,['status'=>'error','message'=>'Vui lòng chọn khoa']);
$maxYear=(int)date('Y')+2;
if($namNhapHoc<2000||$namNhapHoc>$maxYear)reply(400,['status'=>'error','message'=>'Năm nhập học không hợp lệ']);
if(!in_array($trangThai,['dang_hoc','da_tot_nghiep','tam_khoa'],true))reply(400,['status'=>'error','message'=>'Trạng thái lớp không hợp lệ']);
try{
    $stmt=$conn->prepare("SELECT id,trang_thai FROM khoa WHERE id=:id LIMIT 1");$stmt->execute([':id'=>$khoaId]);$khoa=$stmt->fetch(PDO::FETCH_ASSOC);
    if(!$khoa)reply(404,['status'=>'error','message'=>'Không tìm thấy khoa đã chọn']);
    if($khoa['trang_thai']!=='dang_hoat_dong')reply(400,['status'=>'error','message'=>'Không thể thêm lớp vào khoa đã ngừng hoạt động']);
    $stmt=$conn->prepare("SELECT id FROM lop WHERE ma_lop=:ma AND deleted_at IS NULL LIMIT 1");$stmt->execute([':ma'=>$maLop]);
    if($stmt->fetch())reply(409,['status'=>'error','message'=>'Mã lớp đã tồn tại']);
    $stmt=$conn->prepare("INSERT INTO lop(ma_lop,ten_lop,khoa_id,nam_nhap_hoc,trang_thai) VALUES(:ma,:ten,:khoa,:nam,:tt)");
    $stmt->execute([':ma'=>$maLop,':ten'=>$tenLop,':khoa'=>$khoaId,':nam'=>$namNhapHoc,':tt'=>$trangThai]);
    reply(201,['status'=>'success','message'=>'Thêm lớp thành công','data'=>['id'=>(int)$conn->lastInsertId(),'ma_lop'=>$maLop,'ten_lop'=>$tenLop,'khoa_id'=>$khoaId,'nam_nhap_hoc'=>$namNhapHoc,'trang_thai'=>$trangThai]]);
}catch(PDOException $e){reply(500,['status'=>'error','message'=>'Lỗi server khi thêm lớp','detail'=>$e->getMessage()]);}
