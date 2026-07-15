<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if($_SERVER['REQUEST_METHOD']==='OPTIONS'){http_response_code(200);exit();}
if($_SERVER['REQUEST_METHOD']!=='POST'){http_response_code(405);echo json_encode(['status'=>'error','message'=>'Chỉ hỗ trợ phương thức POST'],JSON_UNESCAPED_UNICODE);exit();}
require_once __DIR__.'/../ket_noi.php';
function reply(int $code,array $payload):void{http_response_code($code);echo json_encode($payload,JSON_UNESCAPED_UNICODE);exit();}
$input=json_decode(file_get_contents('php://input'),true);if(!is_array($input))$input=$_POST;
$id=(int)($input['id']??0);$maLop=strtoupper(trim((string)($input['ma_lop']??'')));$tenLop=trim((string)($input['ten_lop']??''));
$khoaId=(int)($input['khoa_id']??0);$namNhapHoc=(int)($input['nam_nhap_hoc']??0);$trangThai=trim((string)($input['trang_thai']??''));
if($id<=0)reply(400,['status'=>'error','message'=>'ID lớp không hợp lệ']);
if($maLop===''||$tenLop==='')reply(400,['status'=>'error','message'=>'Mã lớp và tên lớp không được để trống']);
if($khoaId<=0)reply(400,['status'=>'error','message'=>'Vui lòng chọn khoa']);
$maxYear=(int)date('Y')+2;if($namNhapHoc<2000||$namNhapHoc>$maxYear)reply(400,['status'=>'error','message'=>'Năm nhập học không hợp lệ']);
if(!in_array($trangThai,['dang_hoc','da_tot_nghiep','tam_khoa'],true))reply(400,['status'=>'error','message'=>'Trạng thái lớp không hợp lệ']);
try{
    $stmt=$conn->prepare("SELECT id FROM lop WHERE id=:id AND deleted_at IS NULL LIMIT 1");$stmt->execute([':id'=>$id]);if(!$stmt->fetch())reply(404,['status'=>'error','message'=>'Không tìm thấy lớp']);
    $stmt=$conn->prepare("SELECT id,trang_thai FROM khoa WHERE id=:id LIMIT 1");$stmt->execute([':id'=>$khoaId]);$khoa=$stmt->fetch(PDO::FETCH_ASSOC);if(!$khoa)reply(404,['status'=>'error','message'=>'Không tìm thấy khoa đã chọn']);
    $stmt=$conn->prepare("SELECT id FROM lop WHERE ma_lop=:ma AND id<>:id AND deleted_at IS NULL LIMIT 1");$stmt->execute([':ma'=>$maLop,':id'=>$id]);if($stmt->fetch())reply(409,['status'=>'error','message'=>'Mã lớp đã tồn tại']);
    $conn->beginTransaction();
    $stmt=$conn->prepare("UPDATE lop SET ma_lop=:ma,ten_lop=:ten,khoa_id=:khoa,nam_nhap_hoc=:nam,trang_thai=:tt,ngay_cap_nhat=NOW() WHERE id=:id");
    $stmt->execute([':ma'=>$maLop,':ten'=>$tenLop,':khoa'=>$khoaId,':nam'=>$namNhapHoc,':tt'=>$trangThai,':id'=>$id]);
    // Sinh viên vẫn dùng khóa học; đồng bộ khóa 3 năm từ năm nhập học của lớp hành chính.
    $khoaHocSinhVien=$namNhapHoc.'-'.($namNhapHoc+3);
    $stmt=$conn->prepare("UPDATE sinh_vien SET khoa_id=:khoa,khoa_hoc=:kh,ngay_cap_nhat=NOW() WHERE lop_id=:lop_id");
    $stmt->execute([':khoa'=>$khoaId,':kh'=>$khoaHocSinhVien,':lop_id'=>$id]);
    $conn->commit();
    reply(200,['status'=>'success','message'=>'Cập nhật lớp thành công','data'=>['id'=>$id,'ma_lop'=>$maLop,'ten_lop'=>$tenLop,'khoa_id'=>$khoaId,'nam_nhap_hoc'=>$namNhapHoc,'trang_thai'=>$trangThai]]);
}catch(PDOException $e){if($conn->inTransaction())$conn->rollBack();reply(500,['status'=>'error','message'=>'Lỗi server khi cập nhật lớp','detail'=>$e->getMessage()]);}
