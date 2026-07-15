<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if($_SERVER['REQUEST_METHOD']==='OPTIONS'){http_response_code(200);exit();}
if($_SERVER['REQUEST_METHOD']!=='POST'){http_response_code(405);echo json_encode(['status'=>'error','message'=>'Chỉ hỗ trợ phương thức POST'],JSON_UNESCAPED_UNICODE);exit();}
require_once __DIR__.'/../ket_noi.php';
function reply(int $code,array $payload):void{http_response_code($code);echo json_encode($payload,JSON_UNESCAPED_UNICODE);exit();}
function db_has_table(PDO $conn,string $table):bool{$db=$conn->query('SELECT DATABASE()')->fetchColumn();$stmt=$conn->prepare('SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=? AND TABLE_NAME=?');$stmt->execute([$db,$table]);return (int)$stmt->fetchColumn()>0;}
function nam_hoc_hop_le(string $value):bool{if(!preg_match('/^\d{4}-\d{4}$/',$value))return false;$a=(int)substr($value,0,4);$b=(int)substr($value,5,4);return $a>=2000&&$a<=(int)date('Y')+2&&$b-$a===1;}
$input=json_decode(file_get_contents('php://input'),true);if(!is_array($input))$input=$_POST;
$id=(int)($input['id']??0);$ma=trim((string)($input['ma_lop_hoc_phan']??''));$ten=trim((string)($input['ten_lop']??''));
$monHocId=(int)($input['mon_hoc_id']??0);$giangVienId=(int)($input['giang_vien_id']??0);$hocKy=trim((string)($input['hoc_ky']??''));
$namHoc=trim((string)($input['nam_hoc']??''));$siSo=isset($input['si_so_toi_da'])&&$input['si_so_toi_da']!==''?(int)$input['si_so_toi_da']:null;
$trangThai=trim((string)($input['trang_thai']??'dang_mo'));
if($id<=0)reply(400,['status'=>'error','message'=>'ID lớp học phần không hợp lệ']);
if($ma===''||$ten==='')reply(400,['status'=>'error','message'=>'Mã và tên lớp học phần không được để trống']);
if($monHocId<=0)reply(400,['status'=>'error','message'=>'Vui lòng chọn môn học']);
if($giangVienId<=0)reply(400,['status'=>'error','message'=>'Vui lòng chọn giảng viên']);
if(!in_array($hocKy,['HK1','HK2','HK3','HK4','HK5','HK6'],true))reply(400,['status'=>'error','message'=>'Học kỳ không hợp lệ']);
if(!nam_hoc_hop_le($namHoc))reply(400,['status'=>'error','message'=>'Năm học không hợp lệ. Ví dụ đúng: 2025-2026']);
if($siSo!==null&&($siSo<=0||$siSo>500))reply(400,['status'=>'error','message'=>'Sĩ số tối đa phải từ 1 đến 500']);
if(!in_array($trangThai,['dang_mo','da_khoa','da_ket_thuc'],true))reply(400,['status'=>'error','message'=>'Trạng thái lớp học phần không hợp lệ']);
try{
 $stmt=$conn->prepare('SELECT id FROM lop_hoc_phan WHERE id=:id LIMIT 1');$stmt->execute([':id'=>$id]);if(!$stmt->fetch())reply(404,['status'=>'error','message'=>'Không tìm thấy lớp học phần cần sửa']);
 $stmt=$conn->prepare('SELECT id,trang_thai FROM mon_hoc WHERE id=:id LIMIT 1');$stmt->execute([':id'=>$monHocId]);$mh=$stmt->fetch(PDO::FETCH_ASSOC);if(!$mh)reply(404,['status'=>'error','message'=>'Không tìm thấy môn học đã chọn']);
 $stmt=$conn->prepare("SELECT gv.id,gv.trang_thai,nd.trang_thai AS tai_khoan FROM giang_vien gv JOIN nguoi_dung nd ON nd.id=gv.nguoi_dung_id WHERE gv.id=:id LIMIT 1");$stmt->execute([':id'=>$giangVienId]);$gv=$stmt->fetch(PDO::FETCH_ASSOC);if(!$gv)reply(404,['status'=>'error','message'=>'Không tìm thấy giảng viên đã chọn']);
 if($gv['trang_thai']!=='dang_day')reply(400,['status'=>'error','message'=>'Giảng viên đã ngừng dạy']);
 if($gv['tai_khoan']!=='dang_hoat_dong')reply(400,['status'=>'error','message'=>'Tài khoản giảng viên đang bị khóa']);
 $stmt=$conn->prepare('SELECT id FROM lop_hoc_phan WHERE ma_lop_hoc_phan=:ma AND id<>:id LIMIT 1');$stmt->execute([':ma'=>$ma,':id'=>$id]);if($stmt->fetch())reply(409,['status'=>'error','message'=>'Mã lớp học phần đã tồn tại']);
 $conn->beginTransaction();
 $stmt=$conn->prepare('UPDATE lop_hoc_phan SET ma_lop_hoc_phan=:ma,ten_lop=:ten,mon_hoc_id=:mh,giang_vien_id=:gv,hoc_ky=:hk,nam_hoc=:nh,si_so_toi_da=:ss,trang_thai=:tt,ngay_cap_nhat=NOW() WHERE id=:id');
 $stmt->bindValue(':ma',$ma);$stmt->bindValue(':ten',$ten);$stmt->bindValue(':mh',$monHocId,PDO::PARAM_INT);$stmt->bindValue(':gv',$giangVienId,PDO::PARAM_INT);$stmt->bindValue(':hk',$hocKy);$stmt->bindValue(':nh',$namHoc);
 $siSo===null?$stmt->bindValue(':ss',null,PDO::PARAM_NULL):$stmt->bindValue(':ss',$siSo,PDO::PARAM_INT);$stmt->bindValue(':tt',$trangThai);$stmt->bindValue(':id',$id,PDO::PARAM_INT);$stmt->execute();
 if(db_has_table($conn,'giang_vien_lop_hoc_phan')){$stmt=$conn->prepare("DELETE FROM giang_vien_lop_hoc_phan WHERE lop_hoc_phan_id=? AND vai_tro='chinh'");$stmt->execute([$id]);$stmt=$conn->prepare("INSERT IGNORE INTO giang_vien_lop_hoc_phan(lop_hoc_phan_id,giang_vien_id,vai_tro,ngay_tao,ngay_cap_nhat) VALUES(?,?,'chinh',NOW(),NOW())");$stmt->execute([$id,$giangVienId]);}
 $conn->commit();
 reply(200,['status'=>'success','message'=>'Cập nhật lớp học phần thành công','data'=>['id'=>$id,'ma_lop_hoc_phan'=>$ma,'ten_lop'=>$ten,'mon_hoc_id'=>$monHocId,'giang_vien_id'=>$giangVienId,'hoc_ky'=>$hocKy,'nam_hoc'=>$namHoc,'si_so_toi_da'=>$siSo,'trang_thai'=>$trangThai]]);
}catch(PDOException $e){if($conn->inTransaction())$conn->rollBack();reply(500,['status'=>'error','message'=>'Lỗi server khi cập nhật lớp học phần','detail'=>$e->getMessage()]);}
