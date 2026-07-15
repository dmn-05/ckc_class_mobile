<?php
/**
 * Chặn mọi thao tác ghi khi lớp học phần đã khóa/kết thúc.
 * Các API danh sách/chi tiết vẫn được phép để hỗ trợ mục "Đã lưu".
 */

if (!function_exists('ckc_guard_respond')) {
    function ckc_guard_respond(string $message, int $httpCode = 423): void
    {
        http_response_code($httpCode);
        echo json_encode([
            'status' => 'error',
            'success' => false,
            'message' => $message,
            'read_only' => true,
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
}

if (!function_exists('ckc_lhp_status')) {
    function ckc_lhp_status(PDO $conn, int $lopHocPhanId): ?string
    {
        if ($lopHocPhanId <= 0) return null;
        $stmt = $conn->prepare('SELECT trang_thai FROM lop_hoc_phan WHERE id = ? LIMIT 1');
        $stmt->execute([$lopHocPhanId]);
        $value = $stmt->fetchColumn();
        return $value === false ? null : trim((string)$value);
    }
}

if (!function_exists('ckc_require_lhp_mutable')) {
    function ckc_require_lhp_mutable(PDO $conn, int $lopHocPhanId): void
    {
        if ($lopHocPhanId <= 0) {
            ckc_guard_respond('Không xác định được lớp học phần.', 400);
        }

        $status = ckc_lhp_status($conn, $lopHocPhanId);
        if ($status === null) {
            ckc_guard_respond('Lớp học phần không tồn tại.', 404);
        }

        if ($status !== 'dang_mo') {
            ckc_guard_respond('Lớp học phần đã được lưu. Bạn chỉ có thể xem nội dung.');
        }
    }
}

if (!function_exists('ckc_lhp_id_from_query')) {
    function ckc_lhp_id_from_query(PDO $conn, string $sql, int $id): int
    {
        if ($id <= 0) return 0;
        $stmt = $conn->prepare($sql);
        $stmt->execute([$id]);
        return (int)($stmt->fetchColumn() ?: 0);
    }
}

if (!function_exists('ckc_lhp_id_from_bai_tap')) {
    function ckc_lhp_id_from_bai_tap(PDO $conn, int $id): int
    {
        return ckc_lhp_id_from_query($conn, 'SELECT lop_hoc_phan_id FROM bai_tap WHERE id = ? LIMIT 1', $id);
    }
}

if (!function_exists('ckc_lhp_id_from_quiz')) {
    function ckc_lhp_id_from_quiz(PDO $conn, int $id): int
    {
        return ckc_lhp_id_from_query($conn, 'SELECT lop_hoc_phan_id FROM bai_kiem_tra WHERE id = ? LIMIT 1', $id);
    }
}

if (!function_exists('ckc_lhp_id_from_thong_bao')) {
    function ckc_lhp_id_from_thong_bao(PDO $conn, int $id): int
    {
        return ckc_lhp_id_from_query($conn, 'SELECT lop_hoc_phan_id FROM thong_bao WHERE id = ? LIMIT 1', $id);
    }
}

if (!function_exists('ckc_lhp_id_from_tai_lieu')) {
    function ckc_lhp_id_from_tai_lieu(PDO $conn, int $id): int
    {
        return ckc_lhp_id_from_query($conn, 'SELECT lop_hoc_phan_id FROM tai_lieu WHERE id = ? LIMIT 1', $id);
    }
}

if (!function_exists('ckc_lhp_id_from_chu_de')) {
    function ckc_lhp_id_from_chu_de(PDO $conn, int $id): int
    {
        return ckc_lhp_id_from_query($conn, 'SELECT lop_hoc_phan_id FROM chu_de WHERE id = ? LIMIT 1', $id);
    }
}


if (!function_exists('ckc_lhp_id_from_bai_viet')) {
    function ckc_lhp_id_from_bai_viet(PDO $conn, int $id): int
    {
        return ckc_lhp_id_from_query($conn, 'SELECT lop_hoc_phan_id FROM bai_viet WHERE id = ? LIMIT 1', $id);
    }
}

if (!function_exists('ckc_lhp_id_from_binh_luan')) {
    function ckc_lhp_id_from_binh_luan(PDO $conn, int $id): int
    {
        return ckc_lhp_id_from_query(
            $conn,
            'SELECT COALESCE(bl.lop_hoc_phan_id, bv.lop_hoc_phan_id) FROM binh_luan bl LEFT JOIN bai_viet bv ON bv.id = bl.bai_viet_id WHERE bl.id = ? LIMIT 1',
            $id
        );
    }
}

if (!function_exists('ckc_lhp_id_from_bai_nop')) {
    function ckc_lhp_id_from_bai_nop(PDO $conn, int $id): int
    {
        return ckc_lhp_id_from_query(
            $conn,
            'SELECT bt.lop_hoc_phan_id FROM bai_nop bn JOIN bai_tap bt ON bt.id = bn.bai_tap_id WHERE bn.id = ? LIMIT 1',
            $id
        );
    }
}

if (!function_exists('ckc_lhp_id_from_ket_qua_quiz')) {
    function ckc_lhp_id_from_ket_qua_quiz(PDO $conn, int $id): int
    {
        return ckc_lhp_id_from_query(
            $conn,
            'SELECT bkt.lop_hoc_phan_id FROM ket_qua_kiem_tra kq JOIN bai_kiem_tra bkt ON bkt.id = kq.bai_kiem_tra_id WHERE kq.id = ? LIMIT 1',
            $id
        );
    }
}
