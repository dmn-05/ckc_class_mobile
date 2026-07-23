-- Liên kết bình luận trực tiếp với thông báo.
-- Bản vá PHP cũng tự bổ sung cột này khi endpoint được gọi,
-- nhưng có thể chạy file này thủ công trước khi deploy.

ALTER TABLE binh_luan
    ADD COLUMN IF NOT EXISTS thong_bao_id INT NULL AFTER bai_viet_id;

CREATE INDEX idx_binh_luan_thong_bao
    ON binh_luan (thong_bao_id);

-- Gắn dữ liệu bình luận cũ với thông báo tương ứng.
UPDATE binh_luan bl
JOIN thong_bao tb ON tb.bai_viet_id = bl.bai_viet_id
SET bl.thong_bao_id = tb.id
WHERE bl.thong_bao_id IS NULL;
