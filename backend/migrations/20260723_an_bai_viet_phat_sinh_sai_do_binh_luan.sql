-- CHỈ chạy file này nếu CSDL đã có các bài viết/thông báo bị sinh ra
-- đúng vào thời điểm sinh viên bình luận một thông báo cũ.
-- Điều kiện dưới đây chỉ ẩn bản sao không có file, nội dung trùng hoàn toàn
-- và được tạo muộn hơn thông báo gốc ít nhất 5 phút.

UPDATE bai_viet bv
JOIN thong_bao tb ON tb.bai_viet_id = bv.id
LEFT JOIN tep_tin_bai_viet tbv ON tbv.bai_viet_id = bv.id
SET bv.trang_thai = 'an',
    tb.bai_viet_id = NULL
WHERE tbv.id IS NULL
  AND bv.loai_bai_viet = 'thong_bao'
  AND COALESCE(bv.tieu_de, '') = COALESCE(tb.tieu_de, '')
  AND COALESCE(bv.noi_dung, '') = COALESCE(tb.noi_dung, '')
  AND bv.lop_hoc_phan_id = tb.lop_hoc_phan_id
  AND bv.nguoi_tao_id = tb.nguoi_tao_id
  AND TIMESTAMPDIFF(MINUTE, tb.ngay_tao, bv.ngay_tao) >= 5;
