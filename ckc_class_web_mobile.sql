-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1:3306
-- Thời gian đã tạo: Th7 12, 2026 lúc 08:42 AM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `ckc_class_web_mobile`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bai_kiem_tra`
--

CREATE TABLE `bai_kiem_tra` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tieu_de` varchar(255) NOT NULL,
  `mo_ta` text DEFAULT NULL,
  `lop_hoc_phan_id` int(11) NOT NULL,
  `nguoi_tao_id` bigint(20) UNSIGNED NOT NULL,
  `thoi_gian_bat_dau` datetime DEFAULT NULL,
  `thoi_gian_ket_thuc` datetime DEFAULT NULL,
  `thoi_gian_lam_bai` smallint(5) UNSIGNED NOT NULL DEFAULT 60,
  `diem_toi_da` decimal(5,1) NOT NULL DEFAULT 10.0,
  `diem_dat` decimal(5,1) NOT NULL DEFAULT 5.0,
  `so_lan_thi_toi_da` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `hinh_thuc` enum('trac_nghiem','tu_luan','hon_hop') NOT NULL DEFAULT 'trac_nghiem',
  `xao_tron_cau_hoi` tinyint(1) NOT NULL DEFAULT 1,
  `xao_tron_dap_an` tinyint(1) NOT NULL DEFAULT 1,
  `hien_dap_an_sau_nop` tinyint(1) NOT NULL DEFAULT 0,
  `trang_thai` enum('nhap','hien_thi','an') NOT NULL DEFAULT 'nhap',
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `bai_kiem_tra`
--

INSERT INTO `bai_kiem_tra` (`id`, `tieu_de`, `mo_ta`, `lop_hoc_phan_id`, `nguoi_tao_id`, `thoi_gian_bat_dau`, `thoi_gian_ket_thuc`, `thoi_gian_lam_bai`, `diem_toi_da`, `diem_dat`, `so_lan_thi_toi_da`, `hinh_thuc`, `xao_tron_cau_hoi`, `xao_tron_dap_an`, `hien_dap_an_sau_nop`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'Test', 'Làm nhanh trongg 15p', 1, 2, NULL, NULL, 15, 2.0, 1.0, 1, 'trac_nghiem', 1, 1, 1, 'hien_thi', '2026-07-10 04:14:01', '2026-07-10 04:14:01'),
(6, 'kt15p', 'kiem tra 15p', 5, 10, NULL, NULL, 15, 10.0, 5.0, 1, 'trac_nghiem', 1, 1, 1, 'hien_thi', '2026-06-24 01:52:19', '2026-07-08 14:44:59'),
(7, '30p', 'kiem tra 30p', 4, 10, NULL, '2026-06-25 23:59:00', 30, 10.0, 5.0, 1, 'trac_nghiem', 1, 1, 1, 'hien_thi', '2026-06-24 02:00:43', '2026-07-08 14:44:59'),
(9, 'Lam KT 15p', 'Lam le', 1, 2, NULL, '2026-07-02 23:59:00', 15, 10.0, 5.0, 1, 'trac_nghiem', 0, 0, 1, 'hien_thi', '2026-06-25 09:57:40', '2026-07-08 14:44:59'),
(10, 'Tesst', 'Huongdan', 1, 2, NULL, '2026-07-04 23:59:00', 15, 10.0, 5.0, 1, 'trac_nghiem', 0, 0, 1, 'hien_thi', '2026-06-26 00:07:00', '2026-07-08 14:44:59'),
(11, 'Quizz Test', NULL, 9, 2, NULL, NULL, 15, 10.0, 5.0, 1, 'hon_hop', 0, 0, 1, 'hien_thi', '2026-07-10 06:46:58', '2026-07-10 06:46:58'),
(12, 'Quizz Test', 'Test baif lamf', 1, 2, NULL, NULL, 15, 10.0, 5.0, 1, 'hon_hop', 1, 0, 1, 'hien_thi', '2026-07-10 06:48:39', '2026-07-10 06:48:39'),
(13, 'qư', 'w', 1, 2, NULL, NULL, 15, 1.0, 0.5, 1, 'trac_nghiem', 0, 0, 1, 'hien_thi', '2026-07-10 07:50:57', '2026-07-10 07:50:57');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bai_nop`
--

CREATE TABLE `bai_nop` (
  `id` int(11) NOT NULL,
  `bai_tap_id` int(11) DEFAULT NULL,
  `sinh_vien_id` int(11) DEFAULT NULL,
  `duong_dan_file` text DEFAULT NULL,
  `diem` float DEFAULT NULL,
  `nhan_xet` text DEFAULT NULL,
  `trang_thai` enum('da_nop','nop_muon','da_cham','da_tra') DEFAULT 'da_nop',
  `ngay_cham` datetime DEFAULT NULL,
  `giang_vien_cham_id` int(11) DEFAULT NULL,
  `ngay_nop` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `bai_nop`
--

INSERT INTO `bai_nop` (`id`, `bai_tap_id`, `sinh_vien_id`, `duong_dan_file`, `diem`, `nhan_xet`, `trang_thai`, `ngay_cham`, `giang_vien_cham_id`, `ngay_nop`, `ngay_cap_nhat`) VALUES
(1, 1, 1, 'https://res.cloudinary.com/dnbmqrb2z/raw/upload/v1783595438/submissions/wqqcg1zjtw8j8sampekf.xlsx', 8.5, 'Lam tot', 'nop_muon', '2026-04-22 10:23:53', 1, '2026-04-21 20:23:53', '2026-07-09 18:10:34'),
(2, 1, 2, 'uploads/bai1_sv2.zip', 7, 'Can cai tien', 'da_cham', '2026-04-22 10:23:53', 1, '2026-04-21 20:23:53', '2026-05-30 16:01:13'),
(3, 2, 3, 'uploads/sql_sv3.sql', 9, 'Tot', 'da_cham', '2026-04-22 10:23:53', 1, '2026-04-21 20:23:53', '2026-05-30 16:01:13');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bai_nop_file`
--

CREATE TABLE `bai_nop_file` (
  `id` int(11) NOT NULL,
  `bai_nop_id` int(11) NOT NULL,
  `ten_file_goc` varchar(255) DEFAULT NULL,
  `duong_dan_file` text NOT NULL,
  `loai_file` varchar(50) DEFAULT NULL,
  `kich_thuoc` bigint(20) NOT NULL DEFAULT 0,
  `ngay_tao` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `bai_nop_file`
--

INSERT INTO `bai_nop_file` (`id`, `bai_nop_id`, `ten_file_goc`, `duong_dan_file`, `loai_file`, `kich_thuoc`, `ngay_tao`) VALUES
(2, 2, 'bai1_sv2.zip', 'uploads/bai1_sv2.zip', 'zip', 0, '2026-04-22 10:23:53'),
(3, 3, 'sql_sv3.sql', 'uploads/sql_sv3.sql', 'sql', 0, '2026-04-22 10:23:53'),
(4, 1, 'sinh_vien_20260703_154449.xlsx', 'https://res.cloudinary.com/dnbmqrb2z/raw/upload/v1783595438/submissions/wqqcg1zjtw8j8sampekf.xlsx', 'xlsx', 4503, '2026-07-09 18:10:34');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bai_tap`
--

CREATE TABLE `bai_tap` (
  `id` int(11) NOT NULL,
  `tieu_de` varchar(255) DEFAULT NULL,
  `noi_dung` text DEFAULT NULL,
  `huong_dan` text DEFAULT NULL,
  `mo_ta` text DEFAULT NULL,
  `loai_bai_tap` enum('nop_file','quiz') NOT NULL DEFAULT 'nop_file',
  `duong_dan_file` text DEFAULT NULL,
  `yeu_cau_nop_file` tinyint(1) NOT NULL DEFAULT 1,
  `dinh_dang_file_cho_phep` varchar(255) DEFAULT NULL,
  `so_file_toi_da` int(11) NOT NULL DEFAULT 1,
  `dung_luong_toi_da_mb` int(11) NOT NULL DEFAULT 25,
  `cho_phep_nop_lai` tinyint(1) NOT NULL DEFAULT 1,
  `cho_phep_nop_muon` tinyint(1) NOT NULL DEFAULT 1,
  `file_url` text DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `han_nop` datetime DEFAULT NULL,
  `thoi_gian_gui` datetime DEFAULT NULL,
  `thoi_gian_lam` int(11) DEFAULT NULL,
  `cho_xem_dap_an` tinyint(1) NOT NULL DEFAULT 0,
  `dao_cau_hoi` tinyint(1) NOT NULL DEFAULT 0,
  `dao_dap_an` tinyint(1) NOT NULL DEFAULT 0,
  `cho_phep_nop_tre` tinyint(1) NOT NULL DEFAULT 0,
  `tyle_phat_tre` int(11) NOT NULL DEFAULT 10,
  `lop_hoc_phan_id` int(11) DEFAULT NULL,
  `chu_de_id` int(11) DEFAULT NULL,
  `nguoi_tao_id` int(11) DEFAULT NULL,
  `diem_toi_da` decimal(5,2) NOT NULL DEFAULT 10.00,
  `trang_thai` enum('hien_thi','dang_mo','da_dong','an') NOT NULL DEFAULT 'hien_thi',
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `bai_tap`
--

INSERT INTO `bai_tap` (`id`, `tieu_de`, `noi_dung`, `huong_dan`, `mo_ta`, `loai_bai_tap`, `duong_dan_file`, `yeu_cau_nop_file`, `dinh_dang_file_cho_phep`, `so_file_toi_da`, `dung_luong_toi_da_mb`, `cho_phep_nop_lai`, `cho_phep_nop_muon`, `file_url`, `file_name`, `han_nop`, `thoi_gian_gui`, `thoi_gian_lam`, `cho_xem_dap_an`, `dao_cau_hoi`, `dao_dap_an`, `cho_phep_nop_tre`, `tyle_phat_tre`, `lop_hoc_phan_id`, `chu_de_id`, `nguoi_tao_id`, `diem_toi_da`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'Bai tap Flutter 1', 'Xay dung UI login', 'Xay dung UI login', 'Xay dung UI login', 'nop_file', NULL, 1, NULL, 1, 25, 1, 1, NULL, NULL, '2026-05-01 23:59:59', NULL, NULL, 0, 0, 0, 1, 10, 1, NULL, 2, 10.00, 'dang_mo', '2026-04-21 20:23:53', '2026-07-08 21:44:59'),
(2, 'Bai tap SQL', 'Tao database', 'Tao database', 'Tao database', 'nop_file', NULL, 1, NULL, 1, 25, 1, 1, NULL, NULL, '2026-05-02 23:59:59', NULL, NULL, 0, 0, 0, 1, 10, 2, NULL, 2, 10.00, 'dang_mo', '2026-04-21 20:23:53', '2026-07-08 21:44:59'),
(3, 'bai tap 1', 'bai tap so 1', 'bai tap so 1', 'bai tap so 1', 'nop_file', 'baitap1.pdf', 1, NULL, 1, 25, 1, 1, 'baitap1.pdf', 'baitap1.pdf', '2026-06-16 15:14:00', NULL, NULL, 0, 0, 0, 1, 10, 1, NULL, 2, 10.00, 'dang_mo', '2026-06-09 01:14:57', '2026-07-08 21:44:59'),
(4, 'bai tap 2', 'bai tap so 2', 'bai tap so 2', 'bai tap so 2', 'nop_file', 'baitap2.pdf', 1, NULL, 1, 25, 1, 1, 'baitap2.pdf', 'baitap2.pdf', NULL, NULL, NULL, 0, 0, 0, 1, 10, 1, NULL, 2, 10.00, 'dang_mo', '2026-06-09 01:28:13', '2026-07-08 21:44:59'),
(5, 'dfgh', 'dfg', 'dfg', 'dfg', 'nop_file', 'sdfg.pdf', 1, NULL, 1, 25, 1, 1, 'sdfg.pdf', 'sdfg.pdf', NULL, NULL, NULL, 0, 0, 0, 1, 10, 2, NULL, 2, 10.00, 'dang_mo', '2026-06-13 04:50:11', '2026-07-08 21:44:59'),
(6, 'kt15p', 'kiem tra 15p', 'kiem tra 15p', 'kiem tra 15p', 'quiz', NULL, 1, NULL, 1, 25, 1, 1, NULL, NULL, NULL, NULL, 15, 1, 1, 1, 1, 10, 5, NULL, 10, 10.00, 'an', '2026-06-24 01:52:19', '2026-07-10 13:52:53'),
(7, '30p', 'kiem tra 30p', 'kiem tra 30p', 'kiem tra 30p', 'quiz', NULL, 1, NULL, 1, 25, 1, 1, NULL, NULL, '2026-06-25 23:59:00', NULL, 30, 1, 1, 1, 1, 10, 4, NULL, 10, 10.00, 'an', '2026-06-24 02:00:43', '2026-07-10 13:52:53'),
(8, 'thuc hanh', 'Bai thuc hanh 1', 'Bai thuc hanh 1', 'Bai thuc hanh 1', 'nop_file', 'bai thuc hanh 1.pdf', 1, NULL, 1, 25, 1, 1, 'bai thuc hanh 1.pdf', 'bai thuc hanh 1.pdf', '2026-07-01 22:07:00', NULL, NULL, 0, 0, 0, 1, 10, 4, NULL, 10, 10.00, 'dang_mo', '2026-06-25 08:07:16', '2026-07-08 21:44:59'),
(9, 'Lam KT 15p', 'Lam le', 'Lam le', 'Lam le', 'quiz', NULL, 1, NULL, 1, 25, 1, 1, NULL, NULL, '2026-07-02 23:59:00', NULL, 15, 1, 0, 0, 1, 10, 1, NULL, 2, 10.00, 'an', '2026-06-25 09:57:40', '2026-07-10 13:52:53'),
(10, 'Tesst', 'Huongdan', 'Huongdan', 'Huongdan', 'quiz', NULL, 1, NULL, 1, 25, 1, 1, NULL, NULL, '2026-07-04 23:59:00', NULL, 15, 1, 0, 0, 1, 10, 1, NULL, 2, 10.00, 'an', '2026-06-26 00:07:00', '2026-07-10 13:52:53'),
(11, 'kkk', 'Lmaf bai đi', 'Lmaf bai đi', 'Lmaf bai đi', 'nop_file', NULL, 1, NULL, 1, 25, 1, 1, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 1, 10, 9, 13, 2, 10.00, 'dang_mo', '2026-07-05 05:33:08', '2026-07-08 21:44:59'),
(12, 'nn', NULL, NULL, NULL, 'nop_file', 'https://res.cloudinary.com/dnbmqrb2z/raw/upload/v1783595286/assignments/w8dfzfflsezsedqcuxg5.xlsx', 1, NULL, 1, 25, 1, 1, 'https://res.cloudinary.com/dnbmqrb2z/raw/upload/v1783595286/assignments/w8dfzfflsezsedqcuxg5.xlsx', 'w8dfzfflsezsedqcuxg5.xlsx', NULL, NULL, NULL, 0, 0, 0, 1, 10, 9, 13, 2, 10.00, 'dang_mo', '2026-07-09 10:25:15', '2026-07-09 18:08:02'),
(13, 'kkkk', NULL, NULL, NULL, 'nop_file', 'https://res.cloudinary.com/dnbmqrb2z/raw/upload/v1783595180/assignments/dngb34nkpakab9cfqm1r.xlsx', 1, NULL, 1, 25, 1, 1, 'https://res.cloudinary.com/dnbmqrb2z/raw/upload/v1783595180/assignments/dngb34nkpakab9cfqm1r.xlsx', 'dngb34nkpakab9cfqm1r.xlsx', NULL, NULL, NULL, 0, 0, 0, 1, 10, 9, NULL, 2, 10.00, 'dang_mo', '2026-07-09 11:06:17', '2026-07-09 18:06:17');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bai_viet`
--

CREATE TABLE `bai_viet` (
  `id` int(11) NOT NULL,
  `tieu_de` varchar(255) DEFAULT NULL,
  `noi_dung` text DEFAULT NULL,
  `hinh_anh` varchar(255) DEFAULT NULL,
  `external_url` text DEFAULT NULL,
  `lop_hoc_phan_id` int(11) NOT NULL,
  `chu_de_id` int(11) DEFAULT NULL,
  `bai_tap_id` int(10) UNSIGNED DEFAULT NULL,
  `nguoi_tao_id` int(11) NOT NULL,
  `loai_bai_viet` enum('bai_viet','thong_bao','tai_lieu','bai_tap') DEFAULT 'bai_viet',
  `loai_tai_nguyen` enum('document','video','link','image','other') DEFAULT 'document',
  `trang_thai` enum('hien_thi','an') DEFAULT 'hien_thi',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `diem_toi_da` decimal(5,1) NOT NULL DEFAULT 10.0,
  `han_nop` datetime DEFAULT NULL,
  `cho_phep_nop_tre` tinyint(1) NOT NULL DEFAULT 0,
  `tyle_phat_tre` int(11) NOT NULL DEFAULT 10,
  `luot_xem` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `binh_luan`
--

CREATE TABLE `binh_luan` (
  `id` int(11) NOT NULL,
  `noi_dung` text DEFAULT NULL,
  `nguoi_dung_id` int(11) DEFAULT NULL,
  `lop_hoc_phan_id` int(11) DEFAULT NULL,
  `bai_viet_id` int(11) DEFAULT NULL,
  `binh_luan_cha_id` int(11) DEFAULT NULL,
  `trang_thai` enum('hien_thi','an') DEFAULT 'hien_thi',
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `binh_luan`
--

INSERT INTO `binh_luan` (`id`, `noi_dung`, `nguoi_dung_id`, `lop_hoc_phan_id`, `bai_viet_id`, `binh_luan_cha_id`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'Thay oi em khong hieu bai nay', 4, 1, NULL, NULL, 'hien_thi', '2026-04-21 20:23:53', '2026-05-30 15:54:09'),
(2, 'Ban xem lai video buoi 1', 2, 1, NULL, NULL, 'hien_thi', '2026-04-21 20:23:53', '2026-05-30 15:54:09'),
(3, 'Deadline la khi nao vay?', 5, 2, NULL, NULL, 'hien_thi', '2026-04-21 20:23:53', '2026-05-30 15:54:09'),
(4, 'Da', 4, 2, NULL, NULL, 'hien_thi', '2026-06-12 23:12:24', '2026-06-13 13:12:24'),
(5, 'da', 4, 2, NULL, NULL, 'hien_thi', '2026-07-05 11:03:54', '2026-07-06 01:03:54'),
(6, 'kkk', 4, 7, NULL, NULL, 'hien_thi', '2026-07-09 14:19:45', '2026-07-09 21:19:45'),
(7, '33', 4, 1, NULL, NULL, 'hien_thi', '2026-07-09 14:26:37', '2026-07-09 21:26:37');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bo_mon`
--

CREATE TABLE `bo_mon` (
  `id` int(11) NOT NULL,
  `ma_bo_mon` varchar(20) NOT NULL,
  `ten_bo_mon` varchar(150) NOT NULL,
  `khoa_id` int(11) NOT NULL,
  `trang_thai` enum('dang_hoat_dong','ngung_hoat_dong','cho_phe_duyet') DEFAULT 'dang_hoat_dong',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `truong_bo_mon` varchar(100) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `bo_mon`
--

INSERT INTO `bo_mon` (`id`, `ma_bo_mon`, `ten_bo_mon`, `khoa_id`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`, `truong_bo_mon`, `deleted_at`) VALUES
(1, 'BM_LT', 'Bo mon Lap trinh', 1, 'dang_hoat_dong', '2026-05-13 12:30:54', '2026-05-13 12:30:54', NULL, NULL),
(2, 'BM_CSDL', 'Bo mon Co so du lieu', 1, 'dang_hoat_dong', '2026-05-13 12:30:54', '2026-05-13 12:30:54', NULL, NULL),
(3, 'BM_MKT', 'Bo mon Marketing', 2, 'dang_hoat_dong', '2026-05-13 12:30:54', '2026-05-13 12:30:54', NULL, NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cau_hoi`
--

CREATE TABLE `cau_hoi` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `bai_kiem_tra_id` bigint(20) UNSIGNED NOT NULL,
  `loai` enum('single_choice','multiple_choice','true_false','essay') NOT NULL,
  `noi_dung` text NOT NULL,
  `diem` decimal(5,1) NOT NULL DEFAULT 1.0,
  `giai_thich` text DEFAULT NULL,
  `thu_tu` int(11) NOT NULL DEFAULT 0,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `cau_hoi`
--

INSERT INTO `cau_hoi` (`id`, `bai_kiem_tra_id`, `loai`, `noi_dung`, `diem`, `giai_thich`, `thu_tu`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 1, 'single_choice', 'test', 1.0, NULL, 1, '2026-07-10 04:14:01', '2026-07-10 04:14:01'),
(2, 1, 'single_choice', 'bb', 1.0, NULL, 2, '2026-07-10 04:14:01', '2026-07-10 04:14:01'),
(3, 7, 'single_choice', '1', 1.0, NULL, 1, '2026-06-24 09:00:43', '2026-06-24 09:00:43'),
(4, 7, 'single_choice', '2', 1.0, NULL, 2, '2026-06-24 09:00:43', '2026-06-24 09:00:43'),
(5, 9, 'single_choice', '1+1=', 1.0, NULL, 1, '2026-06-25 16:57:40', '2026-06-25 16:57:40'),
(6, 9, 'single_choice', '2+2', 1.0, NULL, 2, '2026-06-25 16:57:40', '2026-06-25 16:57:40'),
(7, 10, 'single_choice', '1+1 =', 1.0, NULL, 1, '2026-06-26 07:07:00', '2026-06-26 07:07:00'),
(8, 10, 'single_choice', '2 244', 1.0, NULL, 2, '2026-06-26 07:07:00', '2026-06-26 07:07:00'),
(9, 11, 'single_choice', '2 + 2 =', 5.0, NULL, 1, '2026-07-10 06:46:58', '2026-07-10 06:46:58'),
(10, 11, 'essay', '1+1 =', 5.0, NULL, 2, '2026-07-10 06:46:58', '2026-07-10 06:46:58'),
(11, 12, 'single_choice', '1 + 1', 5.0, NULL, 1, '2026-07-10 06:48:39', '2026-07-10 06:48:39'),
(12, 12, 'essay', 'Trả lời gì cx có điểm', 5.0, NULL, 2, '2026-07-10 06:48:39', '2026-07-10 06:48:39'),
(13, 13, 'single_choice', 'cc', 1.0, NULL, 1, '2026-07-10 07:50:57', '2026-07-10 07:50:57');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chi_tiet_ket_qua`
--

CREATE TABLE `chi_tiet_ket_qua` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `ket_qua_kiem_tra_id` bigint(20) UNSIGNED NOT NULL,
  `cau_hoi_id` bigint(20) UNSIGNED NOT NULL,
  `dap_an_id` bigint(20) UNSIGNED DEFAULT NULL,
  `dap_an_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`dap_an_ids`)),
  `dap_an_tu_luan` text DEFAULT NULL,
  `diem_dat` double NOT NULL DEFAULT 0,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `chi_tiet_ket_qua`
--

INSERT INTO `chi_tiet_ket_qua` (`id`, `ket_qua_kiem_tra_id`, `cau_hoi_id`, `dap_an_id`, `dap_an_ids`, `dap_an_tu_luan`, `diem_dat`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 1, 1, 1, NULL, NULL, 1, '2026-07-10 04:15:35', '2026-07-10 04:15:35'),
(2, 1, 2, 4, NULL, NULL, 0, '2026-07-10 04:15:35', '2026-07-10 04:15:35'),
(3, 2, 5, 14, NULL, NULL, 1, '2026-07-10 05:47:31', '2026-07-10 05:47:31'),
(4, 2, 6, 16, NULL, NULL, 1, '2026-07-10 05:47:31', '2026-07-10 05:47:31'),
(5, 3, 7, 19, NULL, NULL, 0, '2026-07-10 05:47:31', '2026-07-10 05:47:31'),
(6, 3, 8, 20, NULL, NULL, 0, '2026-07-10 05:47:31', '2026-07-10 05:47:31'),
(7, 4, 11, 25, NULL, NULL, 0, '2026-07-10 06:49:39', '2026-07-10 06:49:39'),
(8, 4, 12, NULL, NULL, 'Ba + 2 = 5', 5, '2026-07-10 06:49:39', '2026-07-10 06:50:25'),
(9, 5, 13, 27, NULL, NULL, 0, '2026-07-10 08:06:12', '2026-07-10 08:06:12');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chu_de`
--

CREATE TABLE `chu_de` (
  `id` int(11) NOT NULL,
  `ten_chu_de` varchar(255) NOT NULL,
  `lop_hoc_phan_id` int(11) NOT NULL,
  `thu_tu` int(11) DEFAULT 0,
  `trang_thai` enum('dang_mo','da_dong') DEFAULT 'dang_mo',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `chu_de`
--

INSERT INTO `chu_de` (`id`, `ten_chu_de`, `lop_hoc_phan_id`, `thu_tu`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'Thông báo', 1, 1, 'dang_mo', '2026-05-30 15:52:14', '2026-05-30 15:52:14'),
(2, 'Thông báo', 2, 1, 'dang_mo', '2026-05-30 15:52:14', '2026-05-30 15:52:14'),
(3, 'Thông báo', 3, 1, 'dang_mo', '2026-05-30 15:52:14', '2026-05-30 15:52:14'),
(4, 'Tài liệu', 1, 2, 'dang_mo', '2026-05-30 15:53:16', '2026-05-30 15:53:16'),
(5, 'Tài liệu', 2, 2, 'dang_mo', '2026-05-30 15:53:16', '2026-05-30 15:53:16'),
(6, 'Tài liệu', 3, 2, 'dang_mo', '2026-05-30 15:53:16', '2026-05-30 15:53:16'),
(7, 'Bài tập', 1, 3, 'dang_mo', '2026-05-30 15:53:23', '2026-05-30 15:53:23'),
(8, 'Bài tập', 2, 3, 'dang_mo', '2026-05-30 15:53:23', '2026-05-30 15:53:23'),
(9, 'Bài tập', 3, 3, 'dang_mo', '2026-05-30 15:53:23', '2026-05-30 15:53:23'),
(10, 'Thảo luận', 1, 4, 'dang_mo', '2026-05-30 15:53:29', '2026-05-30 15:53:29'),
(11, 'Thảo luận', 2, 4, 'dang_mo', '2026-05-30 15:53:29', '2026-05-30 15:53:29'),
(12, 'Thảo luận', 3, 4, 'dang_mo', '2026-05-30 15:53:29', '2026-05-30 15:53:29'),
(13, 'HOT', 9, 1, 'dang_mo', '2026-07-05 19:32:40', '2026-07-05 19:32:40');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `dap_an`
--

CREATE TABLE `dap_an` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `cau_hoi_id` bigint(20) UNSIGNED NOT NULL,
  `noi_dung` text NOT NULL,
  `la_dap_an_dung` tinyint(1) NOT NULL DEFAULT 0,
  `thu_tu` int(11) NOT NULL DEFAULT 0,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `dap_an`
--

INSERT INTO `dap_an` (`id`, `cau_hoi_id`, `noi_dung`, `la_dap_an_dung`, `thu_tu`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 1, 'test', 1, 1, '2026-07-10 04:14:01', '2026-07-10 04:14:01'),
(2, 1, 'b', 0, 2, '2026-07-10 04:14:01', '2026-07-10 04:14:01'),
(3, 2, 'bb4', 1, 1, '2026-07-10 04:14:01', '2026-07-10 04:14:01'),
(4, 2, 'bb', 0, 2, '2026-07-10 04:14:01', '2026-07-10 04:14:01'),
(5, 2, 'b', 0, 2, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(6, 2, 'c', 0, 3, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(7, 3, 'a', 1, 1, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(8, 3, 'b', 0, 2, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(9, 3, 'c', 0, 3, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(10, 4, 'a', 1, 1, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(11, 4, 'b', 0, 2, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(12, 4, 'c', 0, 3, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(13, 5, '1', 0, 1, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(14, 5, '2', 1, 2, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(15, 5, '3', 0, 3, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(16, 6, '4', 1, 1, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(17, 6, '5', 0, 2, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(18, 7, '1', 1, 1, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(19, 7, '2', 0, 2, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(20, 8, 'ff', 0, 1, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(21, 8, '33', 1, 2, '2026-07-02 17:44:23', '2026-07-02 17:44:23'),
(22, 9, '2', 0, 1, '2026-07-10 06:46:58', '2026-07-10 06:46:58'),
(23, 9, '4', 1, 2, '2026-07-10 06:46:58', '2026-07-10 06:46:58'),
(24, 11, '3', 1, 1, '2026-07-10 06:48:39', '2026-07-10 06:48:39'),
(25, 11, '2', 0, 2, '2026-07-10 06:48:39', '2026-07-10 06:48:39'),
(26, 13, 'c', 1, 1, '2026-07-10 07:50:57', '2026-07-10 07:50:57'),
(27, 13, 'c', 0, 2, '2026-07-10 07:50:57', '2026-07-10 07:50:57');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` varchar(255) NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `giang_vien`
--

CREATE TABLE `giang_vien` (
  `id` int(11) NOT NULL,
  `nguoi_dung_id` int(11) NOT NULL,
  `ma_giang_vien` varchar(20) NOT NULL,
  `ngay_sinh` date DEFAULT NULL,
  `gioi_tinh` enum('nam','nu','khac') DEFAULT NULL,
  `so_dien_thoai` varchar(20) DEFAULT NULL,
  `cccd` varchar(20) DEFAULT NULL,
  `dia_chi` text DEFAULT NULL,
  `bo_mon_id` int(11) DEFAULT NULL,
  `trang_thai` enum('dang_day','ngung_day') DEFAULT 'dang_day',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `giang_vien`
--

INSERT INTO `giang_vien` (`id`, `nguoi_dung_id`, `ma_giang_vien`, `ngay_sinh`, `gioi_tinh`, `so_dien_thoai`, `cccd`, `dia_chi`, `bo_mon_id`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`, `deleted_at`) VALUES
(1, 2, 'GV001', NULL, NULL, NULL, NULL, NULL, 1, 'dang_day', '2026-05-13 15:14:09', '2026-05-13 15:14:09', NULL),
(2, 3, 'GV002', NULL, NULL, NULL, NULL, NULL, 3, 'dang_day', '2026-05-13 15:14:09', '2026-05-13 15:14:09', NULL),
(3, 10, '007', NULL, NULL, NULL, NULL, NULL, 2, 'dang_day', '2026-06-13 22:54:45', '2026-06-13 22:54:45', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` smallint(5) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `ket_qua_kiem_tra`
--

CREATE TABLE `ket_qua_kiem_tra` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `sinh_vien_id` int(11) NOT NULL,
  `bai_kiem_tra_id` bigint(20) UNSIGNED NOT NULL,
  `thoi_gian_bat_dau` timestamp NULL DEFAULT NULL,
  `thoi_gian_nop_bai` timestamp NULL DEFAULT NULL,
  `diem_trac_nghiem` double NOT NULL DEFAULT 0,
  `diem_tu_luan` double NOT NULL DEFAULT 0,
  `tong_diem` double NOT NULL DEFAULT 0,
  `trang_thai` enum('dang_lam','da_nop','da_cham') NOT NULL DEFAULT 'dang_lam',
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `ket_qua_kiem_tra`
--

INSERT INTO `ket_qua_kiem_tra` (`id`, `sinh_vien_id`, `bai_kiem_tra_id`, `thoi_gian_bat_dau`, `thoi_gian_nop_bai`, `diem_trac_nghiem`, `diem_tu_luan`, `tong_diem`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 1, 1, '2026-07-10 04:15:27', '2026-07-10 04:15:35', 1, 0, 1, 'da_cham', '2026-07-10 04:15:27', '2026-07-10 04:15:35'),
(2, 1, 9, '2026-06-25 16:58:24', '2026-06-25 16:58:33', 2, 0, 2, 'da_cham', '2026-06-25 16:58:24', '2026-06-25 16:58:33'),
(3, 1, 10, '2026-06-26 07:07:27', '2026-06-26 07:07:35', 0, 0, 0, 'da_cham', '2026-06-26 07:07:27', '2026-06-26 07:07:35'),
(4, 1, 12, '2026-07-10 06:49:24', '2026-07-10 06:49:39', 0, 5, 5, 'da_cham', '2026-07-10 06:49:24', '2026-07-10 06:50:25'),
(5, 1, 13, '2026-07-10 08:06:08', '2026-07-10 08:06:12', 0, 0, 0, 'da_cham', '2026-07-10 08:06:08', '2026-07-10 08:06:12');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `khoa`
--

CREATE TABLE `khoa` (
  `id` int(11) NOT NULL,
  `ma_khoa` varchar(20) NOT NULL,
  `ten_khoa` varchar(100) DEFAULT NULL,
  `trang_thai` enum('dang_hoat_dong','ngung_hoat_dong','cho_phe_duyet') DEFAULT 'dang_hoat_dong',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `truong_khoa` varchar(100) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `khoa`
--

INSERT INTO `khoa` (`id`, `ma_khoa`, `ten_khoa`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`, `truong_khoa`, `deleted_at`) VALUES
(1, 'CNTT', 'Cong nghe thong tin', 'dang_hoat_dong', '2026-05-13 11:15:14', '2026-05-13 11:15:45', NULL, NULL),
(2, 'QTKD', 'Quan tri kinh doanh', 'dang_hoat_dong', '2026-05-13 11:15:14', '2026-05-15 09:47:30', NULL, NULL),
(3, 'TEST', 'TEst', 'dang_hoat_dong', '2026-07-08 21:45:43', '2026-07-08 21:45:43', NULL, NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `lop`
--

CREATE TABLE `lop` (
  `id` int(11) NOT NULL,
  `ma_lop` varchar(20) NOT NULL,
  `ten_lop` varchar(100) NOT NULL,
  `khoa_id` int(11) NOT NULL,
  `khoa_hoc` varchar(9) DEFAULT NULL,
  `nam_nhap_hoc` int(11) DEFAULT NULL,
  `trang_thai` enum('dang_hoc','da_tot_nghiep','tam_khoa') DEFAULT 'dang_hoc',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `lop`
--

INSERT INTO `lop` (`id`, `ma_lop`, `ten_lop`, `khoa_id`, `khoa_hoc`, `nam_nhap_hoc`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`, `deleted_at`) VALUES
(1, 'CDTH24A', 'CĐ TH 24A', 1, '2024-2027', 2024, 'dang_hoc', '2026-05-13 12:52:06', '2026-06-27 13:58:44', NULL),
(2, 'CDTH24B', 'CĐ TH 24B', 1, '2024-2027', 2024, 'dang_hoc', '2026-05-13 12:52:06', '2026-06-27 13:58:44', NULL),
(3, 'CDQTKD24A', 'CĐ QTKD 24A', 2, '2024-2027', 2024, 'dang_hoc', '2026-05-13 12:52:06', '2026-06-27 13:58:44', NULL),
(4, 'CDTEST', 'TESTLop', 2, '2020-2023', NULL, 'dang_hoc', '2026-06-27 14:12:46', '2026-06-27 14:12:46', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `lop_hoc_phan`
--

CREATE TABLE `lop_hoc_phan` (
  `id` int(11) NOT NULL,
  `ma_lop_hoc_phan` varchar(150) NOT NULL,
  `ten_lop` varchar(150) DEFAULT NULL,
  `mon_hoc_id` int(11) DEFAULT NULL,
  `giang_vien_id` int(11) DEFAULT NULL,
  `hoc_ky` enum('HK1','HK2','HK3','HK4','HK5','HK6') NOT NULL DEFAULT 'HK1',
  `nam_hoc` varchar(20) DEFAULT NULL,
  `khoa_hoc` varchar(9) DEFAULT NULL,
  `si_so_toi_da` int(11) DEFAULT NULL,
  `trang_thai` enum('dang_mo','da_khoa','da_ket_thuc') DEFAULT 'dang_mo',
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `lop_hoc_phan`
--

INSERT INTO `lop_hoc_phan` (`id`, `ma_lop_hoc_phan`, `ten_lop`, `mon_hoc_id`, `giang_vien_id`, `hoc_ky`, `nam_hoc`, `khoa_hoc`, `si_so_toi_da`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'LHP1', 'Flutter K1', 1, 1, 'HK1', NULL, NULL, NULL, 'dang_mo', '2026-04-21 20:23:53', '2026-05-30 15:34:08'),
(2, 'LHP2', 'CSDL K1', 2, 1, 'HK1', NULL, NULL, NULL, 'dang_mo', '2026-04-21 20:23:53', '2026-05-30 15:34:08'),
(3, 'LHP3', 'Marketing K1', 3, 2, 'HK1', NULL, NULL, NULL, 'dang_mo', '2026-04-21 20:23:53', '2026-05-30 15:34:08'),
(4, 'API1', 'LOP API', 1, 3, 'HK1', '2026-2027', '2026-2029', 50, 'dang_mo', '2026-06-14 09:59:42', '2026-06-26 14:13:25'),
(5, 'MODEL1', 'LOP MODEL 1', 1, 2, 'HK1', '2026-2027', '2026-2029', 50, 'dang_mo', '2026-06-14 10:20:46', '2026-06-26 14:32:40'),
(6, 'CĐ TH 24B - Lap trinh Flutter', 'CĐ TH 24B - Lap trinh Flutter', 1, 1, 'HK1', '2024-2025', '2024-2027', 40, 'dang_mo', '2026-06-28 00:39:57', '2026-06-28 14:39:57'),
(7, 'CĐ TH 24A - Nhập môn lập trình', 'CĐ TH 24A - Nhập môn lập trình', 4, 3, 'HK1', '2024-2025', '2024-2027', 40, 'dang_mo', '2026-06-28 00:42:21', '2026-06-28 14:42:21'),
(8, 'HKP Học kỳ 3 2027-2028', 'HKP Học kỳ 3 2027-2028', 4, 3, 'HK3', '2027-2028', '2026-2029', 40, 'dang_mo', '2026-07-01 00:29:41', '2026-07-01 14:29:41'),
(9, 'CDTH26A - Lập trình Flutter - HK1 - 2026-2029', 'CDTH26A - Lập trình Flutter - HK1 - 2026-2029', 4, 1, 'HK1', '2026-2027', '2026-2029', 50, 'dang_mo', '2026-07-02 01:23:15', '2026-07-02 15:23:15');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `mon_hoc`
--

CREATE TABLE `mon_hoc` (
  `id` int(11) NOT NULL,
  `ma_mon` varchar(20) NOT NULL,
  `ten_mon` varchar(100) DEFAULT NULL,
  `tin_chi` tinyint(3) UNSIGNED DEFAULT 3,
  `khoa_id` int(11) DEFAULT NULL,
  `bo_mon_id` int(11) DEFAULT NULL,
  `trang_thai` enum('dang_mo','ngung_su_dung') DEFAULT 'dang_mo',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `mon_hoc`
--

INSERT INTO `mon_hoc` (`id`, `ma_mon`, `ten_mon`, `tin_chi`, `khoa_id`, `bo_mon_id`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`, `deleted_at`) VALUES
(1, 'FLUTTER01', 'Lap trinh Flutter', 3, 1, 1, 'dang_mo', '2026-05-13 13:02:15', '2026-05-13 13:02:45', NULL),
(2, 'CSDL01', 'Co so du lieu', 3, 1, 2, 'dang_mo', '2026-05-13 13:02:15', '2026-05-13 13:02:46', NULL),
(3, 'MKT01', 'Marketing can ban', 3, 2, 3, 'dang_mo', '2026-05-13 13:02:15', '2026-05-13 13:02:46', NULL),
(4, 'KKK', 'Nhập môn lập trình', 3, 1, 1, 'dang_mo', '2026-06-28 14:41:54', '2026-06-28 14:41:54', NULL),
(5, 'LAP TRINH C', 'C++', 3, 1, 2, 'dang_mo', '2026-07-02 02:09:20', '2026-07-02 02:09:20', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nguoi_dung`
--

CREATE TABLE `nguoi_dung` (
  `id` int(11) NOT NULL,
  `ho_ten` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `mat_khau` varchar(255) DEFAULT NULL,
  `vai_tro_id` int(11) DEFAULT NULL,
  `trang_thai` enum('dang_hoat_dong','bi_khoa') DEFAULT 'dang_hoat_dong',
  `avatar` varchar(255) DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `nguoi_dung`
--

INSERT INTO `nguoi_dung` (`id`, `ho_ten`, `email`, `mat_khau`, `vai_tro_id`, `trang_thai`, `avatar`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'Admin He Thong', 'admin@gmail.com', '123456', 1, 'dang_hoat_dong', NULL, '2026-04-21 20:23:53', '2026-05-30 15:34:58'),
(2, 'Nguyen Van A', 'gv1@gmail.com', '123456', 2, 'dang_hoat_dong', NULL, '2026-04-21 20:23:53', '2026-05-30 15:34:58'),
(3, 'Tran Thi B', 'gv2@gmail.com', '123456', 2, 'dang_hoat_dong', NULL, '2026-04-21 20:23:53', '2026-05-30 15:34:58'),
(4, 'Le Van C', 'sv1@gmail.com', '1234567', 3, 'dang_hoat_dong', NULL, '2026-04-21 20:23:53', '2026-07-10 14:28:40'),
(5, 'Pham Thi D', 'sv2@gmail.com', '123456', 3, 'dang_hoat_dong', NULL, '2026-04-21 20:23:53', '2026-05-30 15:34:58'),
(6, 'Hoang Van E', 'sv3@gmail.com', '123456', 3, 'dang_hoat_dong', NULL, '2026-04-21 20:23:53', '2026-05-30 15:34:58'),
(7, 'Vo Minh Tuan 123', 'tuan@gmail.com', '123456', 3, 'dang_hoat_dong', NULL, '2026-06-07 07:15:44', '2026-06-15 14:21:15'),
(8, 'Le Van Duoc', 'duoc@gmail.com', '123456', 3, 'dang_hoat_dong', NULL, '2026-06-13 07:44:14', '2026-06-13 21:44:14'),
(9, 'test1', 'test1@gmail.com', '123456', 3, 'dang_hoat_dong', NULL, '2026-06-13 08:43:01', '2026-06-13 22:43:01'),
(10, 'GV Oood', 'aq1@gmail.com', '123456', 2, 'dang_hoat_dong', NULL, '2026-06-13 08:54:45', '2026-06-15 14:22:12'),
(11, 'Trần Trọng Nhân', 'nhant4404@gmail.com', '123456', 3, 'dang_hoat_dong', NULL, '2026-07-02 11:29:44', '2026-07-03 01:29:44');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nhap_excel_dong`
--

CREATE TABLE `nhap_excel_dong` (
  `id` int(11) NOT NULL,
  `dot_nhap_id` int(11) NOT NULL,
  `so_dong` int(11) NOT NULL,
  `du_lieu_json` longtext DEFAULT NULL,
  `trang_thai` enum('hop_le','canh_bao','loi') NOT NULL DEFAULT 'hop_le',
  `hanh_dong` varchar(50) DEFAULT 'them_moi',
  `thong_bao` text DEFAULT NULL,
  `ngay_tao` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `nhap_excel_dong`
--

INSERT INTO `nhap_excel_dong` (`id`, `dot_nhap_id`, `so_dong`, `du_lieu_json`, `trang_thai`, `hanh_dong`, `thong_bao`, `ngay_tao`) VALUES
(3, 3, 4, '{\"ma_mon\":\"LAP TRINH C\",\"ten_mon\":\"C++\",\"tin_chi\":3,\"ma_khoa\":\"CNTT\",\"ma_bo_mon\":\"BM_CSDL\",\"trang_thai\":\"dang_mo\",\"khoa_id\":1,\"bo_mon_id\":2}', 'hop_le', 'them_moi', '', '2026-07-02 02:09:10'),
(8, 8, 4, '{\"ma_lop_hoc_phan\":\"CDTH26A - Lập trình Flutter - HK1 - 2026-2029\",\"ten_lop\":\"CDTH26A - Lập trình Flutter - HK1 - 2026-2029\",\"ma_mon\":\"KKK\",\"ma_giang_vien\":\"GV001\",\"khoa_hoc\":\"2026-2029\",\"hoc_ky\":\"HK1\",\"si_so_toi_da\":50,\"trang_thai\":\"dang_mo\",\"mon_hoc_id\":4,\"giang_vien_id\":1,\"nam_hoc\":\"2026-2027\"}', 'hop_le', 'them_moi', '', '2026-07-02 15:23:09'),
(16, 16, 4, '{\"ma_sinh_vien\":\"SV0021\",\"ho_ten\":\"Trần Trọng Nhân\",\"email\":\"nhant4404@gmail.com\",\"mat_khau\":\"123456\",\"ma_lop\":\"CDTEST\",\"ma_khoa\":\"QTKD\",\"ngay_sinh\":\"2004-10-21\",\"gioi_tinh\":\"nam\",\"so_dien_thoai\":\"969427271\",\"cccd\":\"7920000000\",\"dia_chi\":\"Cuchi\",\"trang_thai_sinh_vien\":\"dang_hoc\",\"trang_thai_tai_khoan\":\"dang_hoat_dong\",\"lop_id\":4,\"khoa_id\":2,\"khoa_hoc\":\"2020-2023\"}', 'hop_le', 'them_moi', '', '2026-07-03 01:29:35');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nhap_excel_dot`
--

CREATE TABLE `nhap_excel_dot` (
  `id` int(11) NOT NULL,
  `loai_nhap` varchar(50) NOT NULL,
  `ten_file` varchar(255) DEFAULT NULL,
  `nguoi_nhap_id` int(11) DEFAULT NULL,
  `tong_dong` int(11) NOT NULL DEFAULT 0,
  `so_hop_le` int(11) NOT NULL DEFAULT 0,
  `so_loi` int(11) NOT NULL DEFAULT 0,
  `so_canh_bao` int(11) NOT NULL DEFAULT 0,
  `trang_thai` enum('cho_xac_nhan','da_nhap','that_bai','da_huy') NOT NULL DEFAULT 'cho_xac_nhan',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `nhap_excel_dot`
--

INSERT INTO `nhap_excel_dot` (`id`, `loai_nhap`, `ten_file`, `nguoi_nhap_id`, `tong_dong`, `so_hop_le`, `so_loi`, `so_canh_bao`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(3, 'mon_hoc', 'mau_nhap_mon_hoc.xlsx', 1, 1, 1, 0, 0, 'da_nhap', '2026-07-02 02:09:10', '2026-07-02 02:09:20'),
(8, 'lop_hoc_phan', 'mau_nhap_lop_hoc_phan.xlsx', 1, 1, 1, 0, 0, 'da_nhap', '2026-07-02 15:23:09', '2026-07-02 15:23:15'),
(16, 'sinh_vien', 'mau_nhap_sinh_vien.xlsx', 1, 1, 1, 0, 0, 'da_nhap', '2026-07-03 01:29:35', '2026-07-03 01:29:44');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `quen_mat_khau`
--

CREATE TABLE `quen_mat_khau` (
  `id` int(11) NOT NULL,
  `nguoi_dung_id` int(11) NOT NULL,
  `ma_xac_nhan` varchar(10) NOT NULL,
  `het_han_luc` datetime DEFAULT NULL,
  `da_su_dung` tinyint(1) DEFAULT 0,
  `ngay_tao` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `sinh_vien`
--

CREATE TABLE `sinh_vien` (
  `id` int(11) NOT NULL,
  `nguoi_dung_id` int(11) NOT NULL,
  `ma_sinh_vien` varchar(20) NOT NULL,
  `ngay_sinh` date DEFAULT NULL,
  `gioi_tinh` enum('nam','nu','khac') DEFAULT NULL,
  `so_dien_thoai` varchar(20) DEFAULT NULL,
  `cccd` varchar(20) DEFAULT NULL,
  `dia_chi` text DEFAULT NULL,
  `lop_id` int(11) NOT NULL,
  `khoa_id` int(11) NOT NULL,
  `khoa_hoc` varchar(9) DEFAULT NULL,
  `trang_thai` enum('dang_hoc','tam_nghi','da_tot_nghiep') DEFAULT 'dang_hoc',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `sinh_vien`
--

INSERT INTO `sinh_vien` (`id`, `nguoi_dung_id`, `ma_sinh_vien`, `ngay_sinh`, `gioi_tinh`, `so_dien_thoai`, `cccd`, `dia_chi`, `lop_id`, `khoa_id`, `khoa_hoc`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`, `deleted_at`) VALUES
(1, 4, 'SV001', NULL, NULL, '0969427271', '079299999224', 'kkkk', 1, 1, '2024-2027', 'dang_hoc', '2026-05-13 14:52:48', '2026-07-09 22:40:47', NULL),
(2, 5, 'SV002', NULL, NULL, NULL, NULL, NULL, 1, 1, '2024-2027', 'dang_hoc', '2026-05-13 14:52:48', '2026-06-27 13:58:44', NULL),
(3, 6, 'SV003', NULL, NULL, NULL, NULL, NULL, 2, 1, '2024-2027', 'dang_hoc', '2026-05-13 14:52:48', '2026-06-27 13:58:44', NULL),
(8, 9, '011', NULL, NULL, NULL, NULL, NULL, 1, 1, '2024-2027', 'dang_hoc', '2026-06-13 22:43:01', '2026-06-27 13:58:44', NULL),
(9, 7, 'SV007', NULL, NULL, NULL, NULL, NULL, 1, 1, '2024-2027', 'dang_hoc', '2026-06-15 00:35:52', '2026-06-27 13:58:44', NULL),
(11, 8, 'SV008', NULL, NULL, NULL, NULL, NULL, 1, 1, '2024-2027', 'dang_hoc', '2026-06-15 00:36:40', '2026-06-27 13:58:44', NULL),
(12, 11, 'SV0021', '2004-10-21', 'nam', '969427271', '7920000000', 'Cuchi', 4, 2, '2020-2023', 'dang_hoc', '2026-07-03 01:29:44', '2026-07-03 01:29:44', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `sinh_vien_lop_hoc_phan`
--

CREATE TABLE `sinh_vien_lop_hoc_phan` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `sinh_vien_id` int(11) NOT NULL,
  `lop_hoc_phan_id` int(11) NOT NULL,
  `trang_thai` enum('dang_hoc','da_huy','hoan_thanh') NOT NULL DEFAULT 'dang_hoc',
  `ngay_dang_ky` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_tao` timestamp NULL DEFAULT NULL,
  `ngay_cap_nhat` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `sinh_vien_lop_hoc_phan`
--

INSERT INTO `sinh_vien_lop_hoc_phan` (`id`, `sinh_vien_id`, `lop_hoc_phan_id`, `trang_thai`, `ngay_dang_ky`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 1, 1, 'dang_hoc', '2026-04-21 20:23:53', '2026-04-21 20:23:53', '2026-04-21 20:23:53'),
(2, 2, 1, 'dang_hoc', '2026-04-21 20:23:53', '2026-04-21 20:23:53', '2026-04-21 20:23:53'),
(3, 3, 2, 'dang_hoc', '2026-04-21 20:23:53', '2026-04-21 20:23:53', '2026-04-21 20:23:53'),
(4, 1, 2, 'dang_hoc', '2026-04-21 20:23:53', '2026-04-21 20:23:53', '2026-04-21 20:23:53'),
(5, 2, 3, 'dang_hoc', '2026-04-21 20:23:53', '2026-04-21 20:23:53', '2026-04-21 20:23:53'),
(6, 8, 4, 'dang_hoc', '2026-06-14 10:37:26', '2026-06-14 10:37:26', '2026-06-14 10:37:26'),
(8, 9, 4, 'dang_hoc', '2026-06-14 10:59:23', '2026-06-14 10:59:23', '2026-06-14 10:59:23'),
(9, 11, 5, 'dang_hoc', '2026-06-14 11:10:05', '2026-06-14 11:10:05', '2026-06-14 11:10:05'),
(10, 11, 4, 'dang_hoc', '2026-06-14 11:20:24', '2026-06-14 11:20:24', '2026-06-14 11:20:24'),
(11, 8, 5, 'dang_hoc', '2026-06-14 11:28:59', '2026-06-14 11:28:59', '2026-06-14 11:28:59'),
(12, 3, 6, 'dang_hoc', '2026-06-28 00:39:57', '2026-06-28 00:39:57', '2026-06-28 00:39:57'),
(13, 1, 7, 'dang_hoc', '2026-06-28 00:42:21', '2026-06-28 00:42:21', '2026-06-28 00:42:21'),
(14, 2, 7, 'dang_hoc', '2026-06-28 00:42:21', '2026-06-28 00:42:21', '2026-06-28 00:42:21'),
(15, 8, 7, 'dang_hoc', '2026-06-28 00:42:21', '2026-06-28 00:42:21', '2026-06-28 00:42:21'),
(16, 9, 7, 'dang_hoc', '2026-06-28 00:42:21', '2026-06-28 00:42:21', '2026-06-28 00:42:21'),
(17, 11, 7, 'dang_hoc', '2026-06-28 00:42:21', '2026-06-28 00:42:21', '2026-06-28 00:42:21');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tai_lieu`
--

CREATE TABLE `tai_lieu` (
  `id` int(11) NOT NULL,
  `bai_viet_id` int(11) DEFAULT NULL,
  `tieu_de` varchar(255) DEFAULT NULL,
  `mo_ta` text DEFAULT NULL,
  `duong_dan_file` text DEFAULT NULL,
  `lop_hoc_phan_id` int(11) DEFAULT NULL,
  `nguoi_tao_id` int(11) DEFAULT NULL,
  `trang_thai` enum('hien_thi','an') DEFAULT 'hien_thi',
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tai_lieu`
--

INSERT INTO `tai_lieu` (`id`, `bai_viet_id`, `tieu_de`, `mo_ta`, `duong_dan_file`, `lop_hoc_phan_id`, `nguoi_tao_id`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, NULL, 'Tai lieu Flutter PDF', NULL, 'uploads/flutter.pdf', 1, 2, 'hien_thi', '2026-04-21 20:23:53', '2026-05-30 15:51:22'),
(2, NULL, 'Slide MySQL', NULL, 'uploads/mysql.ppt', 2, 2, 'hien_thi', '2026-04-21 20:23:53', '2026-07-07 02:54:42'),
(3, NULL, 'Tai lieu Marketing', NULL, 'uploads/marketing.pdf', 3, 3, 'hien_thi', '2026-04-21 20:23:53', '2026-05-30 15:51:22'),
(5, NULL, 'gbvcx', 'sdfg', 'sdfg.pdf', 2, 2, 'hien_thi', '2026-06-13 04:49:55', '2026-07-07 02:54:10');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tep_tin`
--

CREATE TABLE `tep_tin` (
  `id` int(11) NOT NULL,
  `ten_file` varchar(255) NOT NULL,
  `ten_file_luu` varchar(255) DEFAULT NULL,
  `duong_dan` varchar(255) NOT NULL,
  `loai_file` varchar(100) DEFAULT NULL,
  `kich_thuoc` float DEFAULT NULL,
  `nguoi_tao_id` int(11) DEFAULT NULL,
  `trang_thai` enum('dang_su_dung','da_xoa') DEFAULT 'dang_su_dung',
  `ngay_tao` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tep_tin`
--

INSERT INTO `tep_tin` (`id`, `ten_file`, `ten_file_luu`, `duong_dan`, `loai_file`, `kich_thuoc`, `nguoi_tao_id`, `trang_thai`, `ngay_tao`) VALUES
(1, 'dngb34nkpakab9cfqm1r.xlsx', 'dngb34nkpakab9cfqm1r.xlsx', 'https://res.cloudinary.com/dnbmqrb2z/raw/upload/v1783595180/assignments/dngb34nkpakab9cfqm1r.xlsx', 'xlsx', 0, 2, 'dang_su_dung', '2026-07-09 18:06:17'),
(2, 'w8dfzfflsezsedqcuxg5.xlsx', 'w8dfzfflsezsedqcuxg5.xlsx', 'https://res.cloudinary.com/dnbmqrb2z/raw/upload/v1783595286/assignments/w8dfzfflsezsedqcuxg5.xlsx', 'xlsx', 0, NULL, 'dang_su_dung', '2026-07-09 18:08:02');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tep_tin_bai_tap`
--

CREATE TABLE `tep_tin_bai_tap` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `bai_tap_id` int(11) NOT NULL,
  `tep_tin_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tep_tin_bai_tap`
--

INSERT INTO `tep_tin_bai_tap` (`id`, `bai_tap_id`, `tep_tin_id`, `created_at`, `updated_at`) VALUES
(1, 13, 1, '2026-07-09 11:06:17', '2026-07-09 11:06:17'),
(2, 12, 2, '2026-07-09 11:08:02', '2026-07-09 11:08:02');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tep_tin_bai_viet`
--

CREATE TABLE `tep_tin_bai_viet` (
  `id` int(11) NOT NULL,
  `tep_tin_id` int(11) NOT NULL,
  `bai_viet_id` int(11) NOT NULL,
  `ngay_tao` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `thong_bao`
--

CREATE TABLE `thong_bao` (
  `id` int(11) NOT NULL,
  `tieu_de` varchar(255) DEFAULT NULL,
  `noi_dung` text DEFAULT NULL,
  `thoi_gian_gui` datetime DEFAULT NULL,
  `lop_hoc_phan_id` int(11) DEFAULT NULL,
  `nguoi_tao_id` int(11) DEFAULT NULL,
  `trang_thai` enum('hien_thi','an') DEFAULT 'hien_thi',
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `thong_bao`
--

INSERT INTO `thong_bao` (`id`, `tieu_de`, `noi_dung`, `thoi_gian_gui`, `lop_hoc_phan_id`, `nguoi_tao_id`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'Thong bao 1', 'Nop bai truoc han', NULL, 1, 2, 'hien_thi', '2026-04-21 20:23:53', '2026-05-30 15:51:58'),
(2, 'Thong bao 2', 'Kiem tra giua ky', NULL, 2, 2, 'hien_thi', '2026-04-21 20:23:53', '2026-05-30 15:51:58'),
(3, 'Thong bao 3', 'Nghi hoc tuan nay', NULL, 3, 3, 'hien_thi', '2026-04-21 20:23:53', '2026-05-30 15:51:58'),
(4, 'aaaaa', 'aaaaaaaaa', NULL, 1, 2, 'hien_thi', '2026-06-13 04:12:06', '2026-06-13 18:12:06'),
(6, 'ccccccc', 'cccccccccccc', NULL, 2, 2, 'hien_thi', '2026-06-13 04:43:05', '2026-06-13 18:43:05');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `vai_tro`
--

CREATE TABLE `vai_tro` (
  `id` int(11) NOT NULL,
  `ten_vai_tro` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `vai_tro`
--

INSERT INTO `vai_tro` (`id`, `ten_vai_tro`) VALUES
(1, 'admin'),
(2, 'giang_vien'),
(3, 'sinh_vien');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `bai_kiem_tra`
--
ALTER TABLE `bai_kiem_tra`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `bai_nop`
--
ALTER TABLE `bai_nop`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_bai_nop_bai_tap_sinh_vien` (`bai_tap_id`,`sinh_vien_id`),
  ADD KEY `bai_tap_id` (`bai_tap_id`),
  ADD KEY `sinh_vien_id` (`sinh_vien_id`),
  ADD KEY `fk_bai_nop_giang_vien_cham` (`giang_vien_cham_id`);

--
-- Chỉ mục cho bảng `bai_nop_file`
--
ALTER TABLE `bai_nop_file`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_bai_nop_file_bai_nop` (`bai_nop_id`);

--
-- Chỉ mục cho bảng `bai_tap`
--
ALTER TABLE `bai_tap`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bai_tap_chu_de` (`chu_de_id`),
  ADD KEY `idx_bai_tap_gui` (`lop_hoc_phan_id`,`trang_thai`,`thoi_gian_gui`),
  ADD KEY `lop_hoc_phan_id` (`lop_hoc_phan_id`),
  ADD KEY `fk_bai_tap_nguoi_tao` (`nguoi_tao_id`);

--
-- Chỉ mục cho bảng `bai_viet`
--
ALTER TABLE `bai_viet`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bai_viet_lop_hoc_phan` (`lop_hoc_phan_id`),
  ADD KEY `idx_bai_viet_chu_de` (`chu_de_id`),
  ADD KEY `idx_bai_viet_nguoi_tao` (`nguoi_tao_id`);

--
-- Chỉ mục cho bảng `binh_luan`
--
ALTER TABLE `binh_luan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nguoi_dung_id` (`nguoi_dung_id`),
  ADD KEY `lop_hoc_phan_id` (`lop_hoc_phan_id`),
  ADD KEY `fk_binh_luan_bai_viet` (`bai_viet_id`),
  ADD KEY `binh_luan_binh_luan_cha_id_foreign` (`binh_luan_cha_id`);

--
-- Chỉ mục cho bảng `bo_mon`
--
ALTER TABLE `bo_mon`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ma_bo_mon` (`ma_bo_mon`),
  ADD KEY `fk_bo_mon_khoa` (`khoa_id`);

--
-- Chỉ mục cho bảng `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Chỉ mục cho bảng `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Chỉ mục cho bảng `cau_hoi`
--
ALTER TABLE `cau_hoi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cau_hoi_bai_kiem_tra_id_foreign` (`bai_kiem_tra_id`);

--
-- Chỉ mục cho bảng `chi_tiet_ket_qua`
--
ALTER TABLE `chi_tiet_ket_qua`
  ADD PRIMARY KEY (`id`),
  ADD KEY `chi_tiet_ket_qua_ket_qua_kiem_tra_id_foreign` (`ket_qua_kiem_tra_id`),
  ADD KEY `chi_tiet_ket_qua_cau_hoi_id_foreign` (`cau_hoi_id`),
  ADD KEY `chi_tiet_ket_qua_dap_an_id_foreign` (`dap_an_id`);

--
-- Chỉ mục cho bảng `chu_de`
--
ALTER TABLE `chu_de`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_chu_de_lop_ten` (`lop_hoc_phan_id`,`ten_chu_de`),
  ADD KEY `idx_chu_de_lop_hoc_phan` (`lop_hoc_phan_id`);

--
-- Chỉ mục cho bảng `dap_an`
--
ALTER TABLE `dap_an`
  ADD PRIMARY KEY (`id`),
  ADD KEY `dap_an_cau_hoi_id_foreign` (`cau_hoi_id`);

--
-- Chỉ mục cho bảng `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  ADD KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`);

--
-- Chỉ mục cho bảng `giang_vien`
--
ALTER TABLE `giang_vien`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nguoi_dung_id` (`nguoi_dung_id`),
  ADD UNIQUE KEY `ma_giang_vien` (`ma_giang_vien`),
  ADD KEY `fk_giang_vien_bo_mon` (`bo_mon_id`);

--
-- Chỉ mục cho bảng `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Chỉ mục cho bảng `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `ket_qua_kiem_tra`
--
ALTER TABLE `ket_qua_kiem_tra`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ket_qua_kiem_tra_sinh_vien_id_foreign` (`sinh_vien_id`),
  ADD KEY `ket_qua_kiem_tra_bai_kiem_tra_id_foreign` (`bai_kiem_tra_id`);

--
-- Chỉ mục cho bảng `khoa`
--
ALTER TABLE `khoa`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_khoa_ma_khoa` (`ma_khoa`);

--
-- Chỉ mục cho bảng `lop`
--
ALTER TABLE `lop`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ma_lop` (`ma_lop`),
  ADD KEY `fk_lop_khoa` (`khoa_id`);

--
-- Chỉ mục cho bảng `lop_hoc_phan`
--
ALTER TABLE `lop_hoc_phan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_lop_hoc_phan_ma` (`ma_lop_hoc_phan`),
  ADD KEY `mon_hoc_id` (`mon_hoc_id`),
  ADD KEY `giang_vien_id` (`giang_vien_id`);

--
-- Chỉ mục cho bảng `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `mon_hoc`
--
ALTER TABLE `mon_hoc`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_mon_hoc_ma_mon` (`ma_mon`),
  ADD KEY `khoa_id` (`khoa_id`),
  ADD KEY `idx_mon_hoc_bo_mon` (`bo_mon_id`);

--
-- Chỉ mục cho bảng `nguoi_dung`
--
ALTER TABLE `nguoi_dung`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `vai_tro_id` (`vai_tro_id`);

--
-- Chỉ mục cho bảng `nhap_excel_dong`
--
ALTER TABLE `nhap_excel_dong`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_nhap_excel_dong_dot` (`dot_nhap_id`);

--
-- Chỉ mục cho bảng `nhap_excel_dot`
--
ALTER TABLE `nhap_excel_dot`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_nhap_excel_dot_loai_ngay` (`loai_nhap`,`ngay_tao`),
  ADD KEY `idx_nhap_excel_dot_ten_file` (`ten_file`),
  ADD KEY `idx_nhap_excel_dot_ngay_tao` (`ngay_tao`);

--
-- Chỉ mục cho bảng `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Chỉ mục cho bảng `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Chỉ mục cho bảng `quen_mat_khau`
--
ALTER TABLE `quen_mat_khau`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_quen_mat_khau_nguoi_dung` (`nguoi_dung_id`);

--
-- Chỉ mục cho bảng `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Chỉ mục cho bảng `sinh_vien`
--
ALTER TABLE `sinh_vien`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nguoi_dung_id` (`nguoi_dung_id`),
  ADD UNIQUE KEY `ma_sinh_vien` (`ma_sinh_vien`),
  ADD KEY `fk_sinh_vien_lop` (`lop_id`),
  ADD KEY `fk_sinh_vien_khoa` (`khoa_id`);

--
-- Chỉ mục cho bảng `sinh_vien_lop_hoc_phan`
--
ALTER TABLE `sinh_vien_lop_hoc_phan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sinh_vien_lop_hoc_phan_sinh_vien_id_lop_hoc_phan_id_unique` (`sinh_vien_id`,`lop_hoc_phan_id`),
  ADD KEY `sinh_vien_lop_hoc_phan_lop_hoc_phan_id_foreign` (`lop_hoc_phan_id`);

--
-- Chỉ mục cho bảng `tai_lieu`
--
ALTER TABLE `tai_lieu`
  ADD PRIMARY KEY (`id`),
  ADD KEY `lop_hoc_phan_id` (`lop_hoc_phan_id`),
  ADD KEY `nguoi_tao_id` (`nguoi_tao_id`),
  ADD KEY `idx_tai_lieu_bai_viet_id` (`bai_viet_id`);

--
-- Chỉ mục cho bảng `tep_tin`
--
ALTER TABLE `tep_tin`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tep_tin_nguoi_tao` (`nguoi_tao_id`);

--
-- Chỉ mục cho bảng `tep_tin_bai_tap`
--
ALTER TABLE `tep_tin_bai_tap`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tep_tin_bai_tap_bai_tap_id_foreign` (`bai_tap_id`),
  ADD KEY `tep_tin_bai_tap_tep_tin_id_foreign` (`tep_tin_id`);

--
-- Chỉ mục cho bảng `tep_tin_bai_viet`
--
ALTER TABLE `tep_tin_bai_viet`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tep_tin_bai_viet` (`tep_tin_id`,`bai_viet_id`),
  ADD KEY `idx_ttbv_bai_viet` (`bai_viet_id`);

--
-- Chỉ mục cho bảng `thong_bao`
--
ALTER TABLE `thong_bao`
  ADD PRIMARY KEY (`id`),
  ADD KEY `lop_hoc_phan_id` (`lop_hoc_phan_id`),
  ADD KEY `fk_thong_bao_nguoi_tao` (`nguoi_tao_id`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Chỉ mục cho bảng `vai_tro`
--
ALTER TABLE `vai_tro`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `bai_kiem_tra`
--
ALTER TABLE `bai_kiem_tra`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT cho bảng `bai_nop`
--
ALTER TABLE `bai_nop`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `bai_nop_file`
--
ALTER TABLE `bai_nop_file`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `bai_tap`
--
ALTER TABLE `bai_tap`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT cho bảng `bai_viet`
--
ALTER TABLE `bai_viet`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `binh_luan`
--
ALTER TABLE `binh_luan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `bo_mon`
--
ALTER TABLE `bo_mon`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `cau_hoi`
--
ALTER TABLE `cau_hoi`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT cho bảng `chi_tiet_ket_qua`
--
ALTER TABLE `chi_tiet_ket_qua`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `chu_de`
--
ALTER TABLE `chu_de`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT cho bảng `dap_an`
--
ALTER TABLE `dap_an`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT cho bảng `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `giang_vien`
--
ALTER TABLE `giang_vien`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `ket_qua_kiem_tra`
--
ALTER TABLE `ket_qua_kiem_tra`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `khoa`
--
ALTER TABLE `khoa`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `lop`
--
ALTER TABLE `lop`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `lop_hoc_phan`
--
ALTER TABLE `lop_hoc_phan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `mon_hoc`
--
ALTER TABLE `mon_hoc`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `nguoi_dung`
--
ALTER TABLE `nguoi_dung`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `nhap_excel_dong`
--
ALTER TABLE `nhap_excel_dong`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT cho bảng `nhap_excel_dot`
--
ALTER TABLE `nhap_excel_dot`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT cho bảng `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `quen_mat_khau`
--
ALTER TABLE `quen_mat_khau`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `sinh_vien`
--
ALTER TABLE `sinh_vien`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT cho bảng `sinh_vien_lop_hoc_phan`
--
ALTER TABLE `sinh_vien_lop_hoc_phan`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT cho bảng `tai_lieu`
--
ALTER TABLE `tai_lieu`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `tep_tin`
--
ALTER TABLE `tep_tin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `tep_tin_bai_tap`
--
ALTER TABLE `tep_tin_bai_tap`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `tep_tin_bai_viet`
--
ALTER TABLE `tep_tin_bai_viet`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `thong_bao`
--
ALTER TABLE `thong_bao`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `vai_tro`
--
ALTER TABLE `vai_tro`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `bai_nop`
--
ALTER TABLE `bai_nop`
  ADD CONSTRAINT `bai_nop_ibfk_1` FOREIGN KEY (`bai_tap_id`) REFERENCES `bai_tap` (`id`),
  ADD CONSTRAINT `fk_bai_nop_giang_vien_cham` FOREIGN KEY (`giang_vien_cham_id`) REFERENCES `giang_vien` (`id`),
  ADD CONSTRAINT `fk_bai_nop_sinh_vien` FOREIGN KEY (`sinh_vien_id`) REFERENCES `sinh_vien` (`id`);

--
-- Các ràng buộc cho bảng `bai_nop_file`
--
ALTER TABLE `bai_nop_file`
  ADD CONSTRAINT `fk_bai_nop_file_bai_nop` FOREIGN KEY (`bai_nop_id`) REFERENCES `bai_nop` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `bai_tap`
--
ALTER TABLE `bai_tap`
  ADD CONSTRAINT `bai_tap_ibfk_1` FOREIGN KEY (`lop_hoc_phan_id`) REFERENCES `lop_hoc_phan` (`id`),
  ADD CONSTRAINT `fk_bai_tap_chu_de` FOREIGN KEY (`chu_de_id`) REFERENCES `chu_de` (`id`),
  ADD CONSTRAINT `fk_bai_tap_nguoi_tao` FOREIGN KEY (`nguoi_tao_id`) REFERENCES `nguoi_dung` (`id`);

--
-- Các ràng buộc cho bảng `bai_viet`
--
ALTER TABLE `bai_viet`
  ADD CONSTRAINT `fk_bai_viet_chu_de` FOREIGN KEY (`chu_de_id`) REFERENCES `chu_de` (`id`),
  ADD CONSTRAINT `fk_bai_viet_lop_hoc_phan` FOREIGN KEY (`lop_hoc_phan_id`) REFERENCES `lop_hoc_phan` (`id`),
  ADD CONSTRAINT `fk_bai_viet_nguoi_tao` FOREIGN KEY (`nguoi_tao_id`) REFERENCES `nguoi_dung` (`id`);

--
-- Các ràng buộc cho bảng `binh_luan`
--
ALTER TABLE `binh_luan`
  ADD CONSTRAINT `binh_luan_binh_luan_cha_id_foreign` FOREIGN KEY (`binh_luan_cha_id`) REFERENCES `binh_luan` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `binh_luan_ibfk_1` FOREIGN KEY (`nguoi_dung_id`) REFERENCES `nguoi_dung` (`id`),
  ADD CONSTRAINT `binh_luan_ibfk_2` FOREIGN KEY (`lop_hoc_phan_id`) REFERENCES `lop_hoc_phan` (`id`),
  ADD CONSTRAINT `fk_binh_luan_bai_viet` FOREIGN KEY (`bai_viet_id`) REFERENCES `bai_viet` (`id`);

--
-- Các ràng buộc cho bảng `bo_mon`
--
ALTER TABLE `bo_mon`
  ADD CONSTRAINT `fk_bo_mon_khoa` FOREIGN KEY (`khoa_id`) REFERENCES `khoa` (`id`);

--
-- Các ràng buộc cho bảng `cau_hoi`
--
ALTER TABLE `cau_hoi`
  ADD CONSTRAINT `cau_hoi_bai_kiem_tra_id_foreign` FOREIGN KEY (`bai_kiem_tra_id`) REFERENCES `bai_kiem_tra` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `chi_tiet_ket_qua`
--
ALTER TABLE `chi_tiet_ket_qua`
  ADD CONSTRAINT `chi_tiet_ket_qua_cau_hoi_id_foreign` FOREIGN KEY (`cau_hoi_id`) REFERENCES `cau_hoi` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chi_tiet_ket_qua_dap_an_id_foreign` FOREIGN KEY (`dap_an_id`) REFERENCES `dap_an` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `chi_tiet_ket_qua_ket_qua_kiem_tra_id_foreign` FOREIGN KEY (`ket_qua_kiem_tra_id`) REFERENCES `ket_qua_kiem_tra` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `chu_de`
--
ALTER TABLE `chu_de`
  ADD CONSTRAINT `fk_chu_de_lop_hoc_phan` FOREIGN KEY (`lop_hoc_phan_id`) REFERENCES `lop_hoc_phan` (`id`);

--
-- Các ràng buộc cho bảng `dap_an`
--
ALTER TABLE `dap_an`
  ADD CONSTRAINT `dap_an_cau_hoi_id_foreign` FOREIGN KEY (`cau_hoi_id`) REFERENCES `cau_hoi` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `giang_vien`
--
ALTER TABLE `giang_vien`
  ADD CONSTRAINT `fk_giang_vien_bo_mon` FOREIGN KEY (`bo_mon_id`) REFERENCES `bo_mon` (`id`),
  ADD CONSTRAINT `fk_giang_vien_nguoi_dung` FOREIGN KEY (`nguoi_dung_id`) REFERENCES `nguoi_dung` (`id`);

--
-- Các ràng buộc cho bảng `ket_qua_kiem_tra`
--
ALTER TABLE `ket_qua_kiem_tra`
  ADD CONSTRAINT `ket_qua_kiem_tra_bai_kiem_tra_id_foreign` FOREIGN KEY (`bai_kiem_tra_id`) REFERENCES `bai_kiem_tra` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ket_qua_kiem_tra_sinh_vien_id_foreign` FOREIGN KEY (`sinh_vien_id`) REFERENCES `sinh_vien` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `lop`
--
ALTER TABLE `lop`
  ADD CONSTRAINT `fk_lop_khoa` FOREIGN KEY (`khoa_id`) REFERENCES `khoa` (`id`);

--
-- Các ràng buộc cho bảng `lop_hoc_phan`
--
ALTER TABLE `lop_hoc_phan`
  ADD CONSTRAINT `fk_lop_hoc_phan_giang_vien` FOREIGN KEY (`giang_vien_id`) REFERENCES `giang_vien` (`id`),
  ADD CONSTRAINT `lop_hoc_phan_ibfk_1` FOREIGN KEY (`mon_hoc_id`) REFERENCES `mon_hoc` (`id`);

--
-- Các ràng buộc cho bảng `mon_hoc`
--
ALTER TABLE `mon_hoc`
  ADD CONSTRAINT `fk_mon_hoc_bo_mon` FOREIGN KEY (`bo_mon_id`) REFERENCES `bo_mon` (`id`),
  ADD CONSTRAINT `mon_hoc_ibfk_1` FOREIGN KEY (`khoa_id`) REFERENCES `khoa` (`id`);

--
-- Các ràng buộc cho bảng `nguoi_dung`
--
ALTER TABLE `nguoi_dung`
  ADD CONSTRAINT `nguoi_dung_ibfk_1` FOREIGN KEY (`vai_tro_id`) REFERENCES `vai_tro` (`id`);

--
-- Các ràng buộc cho bảng `nhap_excel_dong`
--
ALTER TABLE `nhap_excel_dong`
  ADD CONSTRAINT `fk_nhap_excel_dong_dot` FOREIGN KEY (`dot_nhap_id`) REFERENCES `nhap_excel_dot` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `quen_mat_khau`
--
ALTER TABLE `quen_mat_khau`
  ADD CONSTRAINT `fk_quen_mat_khau_nguoi_dung` FOREIGN KEY (`nguoi_dung_id`) REFERENCES `nguoi_dung` (`id`);

--
-- Các ràng buộc cho bảng `sinh_vien`
--
ALTER TABLE `sinh_vien`
  ADD CONSTRAINT `fk_sinh_vien_khoa` FOREIGN KEY (`khoa_id`) REFERENCES `khoa` (`id`),
  ADD CONSTRAINT `fk_sinh_vien_lop` FOREIGN KEY (`lop_id`) REFERENCES `lop` (`id`),
  ADD CONSTRAINT `fk_sinh_vien_nguoi_dung` FOREIGN KEY (`nguoi_dung_id`) REFERENCES `nguoi_dung` (`id`);

--
-- Các ràng buộc cho bảng `sinh_vien_lop_hoc_phan`
--
ALTER TABLE `sinh_vien_lop_hoc_phan`
  ADD CONSTRAINT `sinh_vien_lop_hoc_phan_lop_hoc_phan_id_foreign` FOREIGN KEY (`lop_hoc_phan_id`) REFERENCES `lop_hoc_phan` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `sinh_vien_lop_hoc_phan_sinh_vien_id_foreign` FOREIGN KEY (`sinh_vien_id`) REFERENCES `sinh_vien` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `tai_lieu`
--
ALTER TABLE `tai_lieu`
  ADD CONSTRAINT `tai_lieu_ibfk_1` FOREIGN KEY (`lop_hoc_phan_id`) REFERENCES `lop_hoc_phan` (`id`),
  ADD CONSTRAINT `tai_lieu_ibfk_2` FOREIGN KEY (`nguoi_tao_id`) REFERENCES `nguoi_dung` (`id`);

--
-- Các ràng buộc cho bảng `tep_tin`
--
ALTER TABLE `tep_tin`
  ADD CONSTRAINT `fk_tep_tin_nguoi_tao` FOREIGN KEY (`nguoi_tao_id`) REFERENCES `nguoi_dung` (`id`);

--
-- Các ràng buộc cho bảng `tep_tin_bai_tap`
--
ALTER TABLE `tep_tin_bai_tap`
  ADD CONSTRAINT `tep_tin_bai_tap_bai_tap_id_foreign` FOREIGN KEY (`bai_tap_id`) REFERENCES `bai_tap` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tep_tin_bai_tap_tep_tin_id_foreign` FOREIGN KEY (`tep_tin_id`) REFERENCES `tep_tin` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `tep_tin_bai_viet`
--
ALTER TABLE `tep_tin_bai_viet`
  ADD CONSTRAINT `fk_ttbv_bai_viet` FOREIGN KEY (`bai_viet_id`) REFERENCES `bai_viet` (`id`),
  ADD CONSTRAINT `fk_ttbv_tep_tin` FOREIGN KEY (`tep_tin_id`) REFERENCES `tep_tin` (`id`);

--
-- Các ràng buộc cho bảng `thong_bao`
--
ALTER TABLE `thong_bao`
  ADD CONSTRAINT `fk_thong_bao_nguoi_tao` FOREIGN KEY (`nguoi_tao_id`) REFERENCES `nguoi_dung` (`id`),
  ADD CONSTRAINT `thong_bao_ibfk_1` FOREIGN KEY (`lop_hoc_phan_id`) REFERENCES `lop_hoc_phan` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
