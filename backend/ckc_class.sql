-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1:3306
-- Thời gian đã tạo: Th7 07, 2026 lúc 03:59 PM
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
-- Cơ sở dữ liệu: `ckc_class`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bai_lam_quiz`
--

CREATE TABLE `bai_lam_quiz` (
  `id` int(11) NOT NULL,
  `bai_tap_id` int(11) NOT NULL,
  `sinh_vien_id` int(11) NOT NULL,
  `thoi_gian_bat_dau` datetime DEFAULT current_timestamp(),
  `thoi_gian_nop` datetime DEFAULT NULL,
  `tong_cau` int(11) DEFAULT 0,
  `so_cau_dung` int(11) DEFAULT 0,
  `diem` float DEFAULT NULL,
  `trang_thai` enum('dang_lam','da_nop','qua_han') DEFAULT 'dang_lam',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `bai_lam_quiz`
--

INSERT INTO `bai_lam_quiz` (`id`, `bai_tap_id`, `sinh_vien_id`, `thoi_gian_bat_dau`, `thoi_gian_nop`, `tong_cau`, `so_cau_dung`, `diem`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 7, 9, '2026-06-24 16:01:04', '2026-06-25 10:03:03', 2, 1, 1, 'qua_han', '2026-06-24 16:01:04', '2026-06-25 10:03:03'),
(2, 9, 1, '2026-06-25 23:58:24', '2026-06-25 23:58:33', 2, 2, 2, 'da_nop', '2026-06-25 23:58:24', '2026-06-25 23:58:33'),
(3, 10, 1, '2026-06-26 14:07:27', '2026-06-26 14:07:35', 2, 0, 0, 'da_nop', '2026-06-26 14:07:27', '2026-06-26 14:07:35');

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
  `trang_thai` enum('da_nop','nop_muon','da_cham') DEFAULT 'da_nop',
  `ngay_cham` datetime DEFAULT NULL,
  `giang_vien_cham_id` int(11) DEFAULT NULL,
  `ngay_nop` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `bai_nop`
--

INSERT INTO `bai_nop` (`id`, `bai_tap_id`, `sinh_vien_id`, `duong_dan_file`, `diem`, `nhan_xet`, `trang_thai`, `ngay_cham`, `giang_vien_cham_id`, `ngay_nop`, `ngay_cap_nhat`) VALUES
(1, 1, 1, 'uploads/bai1_sv1.zip', 8.5, 'Lam tot', 'da_cham', '2026-04-22 10:23:53', 1, '2026-04-22 03:23:53', '2026-05-30 16:01:13'),
(2, 1, 2, 'uploads/bai1_sv2.zip', 7, 'Can cai tien', 'da_cham', '2026-04-22 10:23:53', 1, '2026-04-22 03:23:53', '2026-05-30 16:01:13'),
(3, 2, 3, 'uploads/sql_sv3.sql', 9, 'Tot', 'da_cham', '2026-04-22 10:23:53', 1, '2026-04-22 03:23:53', '2026-05-30 16:01:13');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bai_tap`
--

CREATE TABLE `bai_tap` (
  `id` int(11) NOT NULL,
  `tieu_de` varchar(255) DEFAULT NULL,
  `mo_ta` text DEFAULT NULL,
  `loai_bai_tap` enum('nop_file','quiz') DEFAULT 'nop_file',
  `duong_dan_file` text DEFAULT NULL,
  `han_nop` datetime DEFAULT NULL,
  `thoi_gian_gui` datetime DEFAULT NULL,
  `thoi_gian_lam` int(11) DEFAULT NULL,
  `cho_xem_dap_an` tinyint(1) DEFAULT 0,
  `dao_cau_hoi` tinyint(1) DEFAULT 0,
  `dao_dap_an` tinyint(1) DEFAULT 0,
  `lop_hoc_phan_id` int(11) DEFAULT NULL,
  `chu_de_id` int(11) DEFAULT NULL,
  `nguoi_tao_id` int(11) DEFAULT NULL,
  `trang_thai` enum('dang_mo','da_dong','an') DEFAULT 'dang_mo',
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `bai_tap`
--

INSERT INTO `bai_tap` (`id`, `tieu_de`, `mo_ta`, `loai_bai_tap`, `duong_dan_file`, `han_nop`, `thoi_gian_gui`, `thoi_gian_lam`, `cho_xem_dap_an`, `dao_cau_hoi`, `dao_dap_an`, `lop_hoc_phan_id`, `chu_de_id`, `nguoi_tao_id`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'Bai tap Flutter 1', 'Xay dung UI login', 'nop_file', NULL, '2026-05-01 23:59:59', NULL, NULL, 0, 0, 0, 1, NULL, 2, 'dang_mo', '2026-04-22 03:23:53', '2026-05-30 15:49:13'),
(2, 'Bai tap SQL', 'Tao database', 'nop_file', NULL, '2026-05-02 23:59:59', NULL, NULL, 0, 0, 0, 2, NULL, 2, 'dang_mo', '2026-04-22 03:23:53', '2026-05-30 15:49:13'),
(3, 'bai tap 1', 'bai tap so 1', 'nop_file', 'baitap1.pdf', '2026-06-16 15:14:00', NULL, NULL, 0, 0, 0, 1, NULL, 2, 'dang_mo', '2026-06-09 08:14:57', '2026-06-09 15:14:57'),
(4, 'bai tap 2', 'bai tap so 2', 'nop_file', 'baitap2.pdf', NULL, NULL, NULL, 0, 0, 0, 1, NULL, 2, 'dang_mo', '2026-06-09 08:28:13', '2026-06-09 15:28:13'),
(5, 'dfgh', 'dfg', 'nop_file', 'sdfg.pdf', NULL, NULL, NULL, 0, 0, 0, 2, NULL, 2, 'dang_mo', '2026-06-13 11:50:11', '2026-06-13 18:50:11'),
(6, 'kt15p', 'kiem tra 15p', 'quiz', NULL, NULL, NULL, 15, 1, 1, 1, 5, NULL, 10, 'dang_mo', '2026-06-24 08:52:19', '2026-06-24 15:52:19'),
(7, '30p', 'kiem tra 30p', 'quiz', NULL, '2026-06-25 23:59:00', NULL, 30, 1, 1, 1, 4, NULL, 10, 'dang_mo', '2026-06-24 09:00:43', '2026-06-24 16:00:43'),
(8, 'thuc hanh', 'Bai thuc hanh 1', 'nop_file', 'bai thuc hanh 1.pdf', '2026-07-01 22:07:00', NULL, NULL, 0, 0, 0, 4, NULL, 10, 'dang_mo', '2026-06-25 15:07:16', '2026-06-25 22:07:16'),
(9, 'Lam KT 15p', 'Lam le', 'quiz', NULL, '2026-07-02 23:59:00', NULL, 15, 1, 0, 0, 1, NULL, 2, 'dang_mo', '2026-06-25 16:57:40', '2026-06-25 23:57:40'),
(10, 'Tesst', 'Huongdan', 'quiz', NULL, '2026-07-04 23:59:00', NULL, 15, 1, 0, 0, 1, NULL, 2, 'dang_mo', '2026-06-26 07:07:00', '2026-06-26 14:07:00'),
(11, 'kkk', 'Lmaf bai đi', 'nop_file', NULL, NULL, NULL, NULL, 0, 0, 0, 9, 13, 2, 'dang_mo', '2026-07-05 12:33:08', '2026-07-05 19:33:08');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bai_viet`
--

CREATE TABLE `bai_viet` (
  `id` int(11) NOT NULL,
  `tieu_de` varchar(255) DEFAULT NULL,
  `noi_dung` text DEFAULT NULL,
  `lop_hoc_phan_id` int(11) NOT NULL,
  `chu_de_id` int(11) DEFAULT NULL,
  `nguoi_tao_id` int(11) NOT NULL,
  `loai_bai_viet` enum('bai_viet','thong_bao','tai_lieu','bai_tap') DEFAULT 'bai_viet',
  `trang_thai` enum('hien_thi','an') DEFAULT 'hien_thi',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
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
  `trang_thai` enum('hien_thi','an') DEFAULT 'hien_thi',
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `binh_luan`
--

INSERT INTO `binh_luan` (`id`, `noi_dung`, `nguoi_dung_id`, `lop_hoc_phan_id`, `bai_viet_id`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'Thay oi em khong hieu bai nay', 4, 1, NULL, 'hien_thi', '2026-04-22 03:23:53', '2026-05-30 15:54:09'),
(2, 'Ban xem lai video buoi 1', 2, 1, NULL, 'hien_thi', '2026-04-22 03:23:53', '2026-05-30 15:54:09'),
(3, 'Deadline la khi nao vay?', 5, 2, NULL, 'hien_thi', '2026-04-22 03:23:53', '2026-05-30 15:54:09'),
(4, 'Da', 4, 2, NULL, 'hien_thi', '2026-06-13 06:12:24', '2026-06-13 13:12:24'),
(5, 'da', 4, 2, NULL, 'hien_thi', '2026-07-05 18:03:54', '2026-07-06 01:03:54');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bo_mon`
--

CREATE TABLE `bo_mon` (
  `id` int(11) NOT NULL,
  `ma_bo_mon` varchar(20) NOT NULL,
  `ten_bo_mon` varchar(150) NOT NULL,
  `khoa_id` int(11) NOT NULL,
  `trang_thai` enum('dang_hoat_dong','ngung_hoat_dong') DEFAULT 'dang_hoat_dong',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `bo_mon`
--

INSERT INTO `bo_mon` (`id`, `ma_bo_mon`, `ten_bo_mon`, `khoa_id`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'BM_LT', 'Bo mon Lap trinh', 1, 'dang_hoat_dong', '2026-05-13 12:30:54', '2026-05-13 12:30:54'),
(2, 'BM_CSDL', 'Bo mon Co so du lieu', 1, 'dang_hoat_dong', '2026-05-13 12:30:54', '2026-05-13 12:30:54'),
(3, 'BM_MKT', 'Bo mon Marketing', 2, 'dang_hoat_dong', '2026-05-13 12:30:54', '2026-05-13 12:30:54');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cau_hoi_quiz`
--

CREATE TABLE `cau_hoi_quiz` (
  `id` int(11) NOT NULL,
  `bai_tap_id` int(11) NOT NULL,
  `noi_dung` text NOT NULL,
  `loai_cau_hoi` enum('mot_dap_an','nhieu_dap_an','dung_sai') DEFAULT 'mot_dap_an',
  `diem` float DEFAULT 1,
  `thu_tu` int(11) DEFAULT 0,
  `trang_thai` enum('hien_thi','an') DEFAULT 'hien_thi',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `cau_hoi_quiz`
--

INSERT INTO `cau_hoi_quiz` (`id`, `bai_tap_id`, `noi_dung`, `loai_cau_hoi`, `diem`, `thu_tu`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 6, '1', 'mot_dap_an', 1, 1, 'hien_thi', '2026-06-24 15:52:19', '2026-06-24 15:52:19'),
(2, 6, '2', 'mot_dap_an', 1, 2, 'hien_thi', '2026-06-24 15:52:19', '2026-06-24 15:52:19'),
(3, 7, '1', 'mot_dap_an', 1, 1, 'hien_thi', '2026-06-24 16:00:43', '2026-06-24 16:00:43'),
(4, 7, '2', 'mot_dap_an', 1, 2, 'hien_thi', '2026-06-24 16:00:43', '2026-06-24 16:00:43'),
(5, 9, '1+1=', 'mot_dap_an', 1, 1, 'hien_thi', '2026-06-25 23:57:40', '2026-06-25 23:57:40'),
(6, 9, '2+2', 'mot_dap_an', 1, 2, 'hien_thi', '2026-06-25 23:57:40', '2026-06-25 23:57:40'),
(7, 10, '1+1 =', 'mot_dap_an', 1, 1, 'hien_thi', '2026-06-26 14:07:00', '2026-06-26 14:07:00'),
(8, 10, '2 244', 'mot_dap_an', 1, 2, 'hien_thi', '2026-06-26 14:07:00', '2026-06-26 14:07:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chi_tiet_bai_lam_quiz`
--

CREATE TABLE `chi_tiet_bai_lam_quiz` (
  `id` int(11) NOT NULL,
  `bai_lam_quiz_id` int(11) NOT NULL,
  `cau_hoi_id` int(11) NOT NULL,
  `dap_an_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `chi_tiet_bai_lam_quiz`
--

INSERT INTO `chi_tiet_bai_lam_quiz` (`id`, `bai_lam_quiz_id`, `cau_hoi_id`, `dap_an_id`) VALUES
(1, 1, 3, 7),
(2, 1, 4, 11),
(3, 2, 5, 14),
(4, 2, 6, 16),
(5, 3, 7, 19),
(6, 3, 8, 20);

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
-- Cấu trúc bảng cho bảng `dap_an_quiz`
--

CREATE TABLE `dap_an_quiz` (
  `id` int(11) NOT NULL,
  `cau_hoi_id` int(11) NOT NULL,
  `noi_dung` text NOT NULL,
  `la_dap_an_dung` tinyint(1) DEFAULT 0,
  `thu_tu` int(11) DEFAULT 0,
  `trang_thai` enum('hien_thi','an') DEFAULT 'hien_thi',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `dap_an_quiz`
--

INSERT INTO `dap_an_quiz` (`id`, `cau_hoi_id`, `noi_dung`, `la_dap_an_dung`, `thu_tu`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 1, 'a', 1, 1, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(2, 1, 'b', 0, 2, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(3, 1, 'c', 0, 3, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(4, 2, 'a', 1, 1, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(5, 2, 'b', 0, 2, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(6, 2, 'c', 0, 3, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(7, 3, 'a', 1, 1, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(8, 3, 'b', 0, 2, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(9, 3, 'c', 0, 3, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(10, 4, 'a', 1, 1, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(11, 4, 'b', 0, 2, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(12, 4, 'c', 0, 3, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(13, 5, '1', 0, 1, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(14, 5, '2', 1, 2, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(15, 5, '3', 0, 3, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(16, 6, '4', 1, 1, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(17, 6, '5', 0, 2, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(18, 7, '1', 1, 1, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(19, 7, '2', 0, 2, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(20, 8, 'ff', 0, 1, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23'),
(21, 8, '33', 1, 2, 'hien_thi', '2026-07-03 00:44:23', '2026-07-03 00:44:23');

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
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `giang_vien`
--

INSERT INTO `giang_vien` (`id`, `nguoi_dung_id`, `ma_giang_vien`, `ngay_sinh`, `gioi_tinh`, `so_dien_thoai`, `cccd`, `dia_chi`, `bo_mon_id`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 2, 'GV001', NULL, NULL, NULL, NULL, NULL, 1, 'dang_day', '2026-05-13 15:14:09', '2026-05-13 15:14:09'),
(2, 3, 'GV002', NULL, NULL, NULL, NULL, NULL, 3, 'dang_day', '2026-05-13 15:14:09', '2026-05-13 15:14:09'),
(3, 10, '007', NULL, NULL, NULL, NULL, NULL, 2, 'dang_day', '2026-06-13 22:54:45', '2026-06-13 22:54:45');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `khoa`
--

CREATE TABLE `khoa` (
  `id` int(11) NOT NULL,
  `ma_khoa` varchar(20) NOT NULL,
  `ten_khoa` varchar(100) DEFAULT NULL,
  `trang_thai` enum('dang_hoat_dong','ngung_hoat_dong') DEFAULT 'dang_hoat_dong',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `khoa`
--

INSERT INTO `khoa` (`id`, `ma_khoa`, `ten_khoa`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'CNTT', 'Cong nghe thong tin', 'dang_hoat_dong', '2026-05-13 11:15:14', '2026-05-13 11:15:45'),
(2, 'QTKD', 'Quan tri kinh doanh', 'dang_hoat_dong', '2026-05-13 11:15:14', '2026-05-15 09:47:30');

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
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `lop`
--

INSERT INTO `lop` (`id`, `ma_lop`, `ten_lop`, `khoa_id`, `khoa_hoc`, `nam_nhap_hoc`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'CDTH24A', 'CĐ TH 24A', 1, '2024-2027', 2024, 'dang_hoc', '2026-05-13 12:52:06', '2026-06-27 13:58:44'),
(2, 'CDTH24B', 'CĐ TH 24B', 1, '2024-2027', 2024, 'dang_hoc', '2026-05-13 12:52:06', '2026-06-27 13:58:44'),
(3, 'CDQTKD24A', 'CĐ QTKD 24A', 2, '2024-2027', 2024, 'dang_hoc', '2026-05-13 12:52:06', '2026-06-27 13:58:44'),
(4, 'CDTEST', 'TESTLop', 2, '2020-2023', NULL, 'dang_hoc', '2026-06-27 14:12:46', '2026-06-27 14:12:46');

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
  `hoc_ky` enum('HK1','HK2','HK3','HK4','HK5','HK6') DEFAULT 'HK1',
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
(1, 'LHP1', 'Flutter K1', 1, 1, 'HK1', NULL, NULL, NULL, 'dang_mo', '2026-04-22 03:23:53', '2026-05-30 15:34:08'),
(2, 'LHP2', 'CSDL K1', 2, 1, 'HK1', NULL, NULL, NULL, 'dang_mo', '2026-04-22 03:23:53', '2026-05-30 15:34:08'),
(3, 'LHP3', 'Marketing K1', 3, 2, 'HK1', NULL, NULL, NULL, 'dang_mo', '2026-04-22 03:23:53', '2026-05-30 15:34:08'),
(4, 'API1', 'LOP API', 1, 3, 'HK1', '2026-2027', '2026-2029', 50, 'dang_mo', '2026-06-14 16:59:42', '2026-06-26 14:13:25'),
(5, 'MODEL1', 'LOP MODEL 1', 1, 2, 'HK1', '2026-2027', '2026-2029', 50, 'dang_mo', '2026-06-14 17:20:46', '2026-06-26 14:32:40'),
(6, 'CĐ TH 24B - Lap trinh Flutter', 'CĐ TH 24B - Lap trinh Flutter', 1, 1, 'HK1', '2024-2025', '2024-2027', 40, 'dang_mo', '2026-06-28 07:39:57', '2026-06-28 14:39:57'),
(7, 'CĐ TH 24A - Nhập môn lập trình', 'CĐ TH 24A - Nhập môn lập trình', 4, 3, 'HK1', '2024-2025', '2024-2027', 40, 'dang_mo', '2026-06-28 07:42:21', '2026-06-28 14:42:21'),
(8, 'HKP Học kỳ 3 2027-2028', 'HKP Học kỳ 3 2027-2028', 4, 3, 'HK3', '2027-2028', '2026-2029', 40, 'dang_mo', '2026-07-01 07:29:41', '2026-07-01 14:29:41'),
(9, 'CDTH26A - Lập trình Flutter - HK1 - 2026-2029', 'CDTH26A - Lập trình Flutter - HK1 - 2026-2029', 4, 1, 'HK1', '2026-2027', '2026-2029', 50, 'dang_mo', '2026-07-02 08:23:15', '2026-07-02 15:23:15');

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
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `mon_hoc`
--

INSERT INTO `mon_hoc` (`id`, `ma_mon`, `ten_mon`, `tin_chi`, `khoa_id`, `bo_mon_id`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'FLUTTER01', 'Lap trinh Flutter', 3, 1, 1, 'dang_mo', '2026-05-13 13:02:15', '2026-05-13 13:02:45'),
(2, 'CSDL01', 'Co so du lieu', 3, 1, 2, 'dang_mo', '2026-05-13 13:02:15', '2026-05-13 13:02:46'),
(3, 'MKT01', 'Marketing can ban', 3, 2, 3, 'dang_mo', '2026-05-13 13:02:15', '2026-05-13 13:02:46'),
(4, 'KKK', 'Nhập môn lập trình', 3, 1, 1, 'dang_mo', '2026-06-28 14:41:54', '2026-06-28 14:41:54'),
(5, 'LAP TRINH C', 'C++', 3, 1, 2, 'dang_mo', '2026-07-02 02:09:20', '2026-07-02 02:09:20');

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
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `nguoi_dung`
--

INSERT INTO `nguoi_dung` (`id`, `ho_ten`, `email`, `mat_khau`, `vai_tro_id`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'Admin He Thong', 'admin@gmail.com', '123456', 1, 'dang_hoat_dong', '2026-04-22 03:23:53', '2026-05-30 15:34:58'),
(2, 'Nguyen Van A', 'gv1@gmail.com', '123456', 2, 'dang_hoat_dong', '2026-04-22 03:23:53', '2026-05-30 15:34:58'),
(3, 'Tran Thi B', 'gv2@gmail.com', '123456', 2, 'dang_hoat_dong', '2026-04-22 03:23:53', '2026-05-30 15:34:58'),
(4, 'Le Van C', 'sv1@gmail.com', '123456', 3, 'dang_hoat_dong', '2026-04-22 03:23:53', '2026-05-30 15:34:58'),
(5, 'Pham Thi D', 'sv2@gmail.com', '123456', 3, 'dang_hoat_dong', '2026-04-22 03:23:53', '2026-05-30 15:34:58'),
(6, 'Hoang Van E', 'sv3@gmail.com', '123456', 3, 'dang_hoat_dong', '2026-04-22 03:23:53', '2026-05-30 15:34:58'),
(7, 'Vo Minh Tuan 123', 'tuan@gmail.com', '123456', 3, 'dang_hoat_dong', '2026-06-07 14:15:44', '2026-06-15 14:21:15'),
(8, 'Le Van Duoc', 'duoc@gmail.com', '123456', 3, 'dang_hoat_dong', '2026-06-13 14:44:14', '2026-06-13 21:44:14'),
(9, 'test1', 'test1@gmail.com', '123456', 3, 'dang_hoat_dong', '2026-06-13 15:43:01', '2026-06-13 22:43:01'),
(10, 'GV Oood', 'aq1@gmail.com', '123456', 2, 'dang_hoat_dong', '2026-06-13 15:54:45', '2026-06-15 14:22:12'),
(11, 'Trần Trọng Nhân', 'nhant4404@gmail.com', '123456', 3, 'dang_hoat_dong', '2026-07-02 18:29:44', '2026-07-03 01:29:44');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nhap_excel_dong`
--

CREATE TABLE `nhap_excel_dong` (
  `id` int(11) NOT NULL,
  `dot_nhap_id` int(11) NOT NULL,
  `so_dong` int(11) NOT NULL,
  `du_lieu_json` longtext DEFAULT NULL,
  `trang_thai` enum('hop_le','canh_bao','loi') DEFAULT 'hop_le',
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
  `tong_dong` int(11) DEFAULT 0,
  `so_hop_le` int(11) DEFAULT 0,
  `so_loi` int(11) DEFAULT 0,
  `so_canh_bao` int(11) DEFAULT 0,
  `trang_thai` enum('cho_xac_nhan','da_nhap','that_bai','da_huy') DEFAULT 'cho_xac_nhan',
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
  `ngay_cap_nhat` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `sinh_vien`
--

INSERT INTO `sinh_vien` (`id`, `nguoi_dung_id`, `ma_sinh_vien`, `ngay_sinh`, `gioi_tinh`, `so_dien_thoai`, `cccd`, `dia_chi`, `lop_id`, `khoa_id`, `khoa_hoc`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 4, 'SV001', NULL, NULL, NULL, NULL, NULL, 1, 1, '2024-2027', 'dang_hoc', '2026-05-13 14:52:48', '2026-06-27 13:58:44'),
(2, 5, 'SV002', NULL, NULL, NULL, NULL, NULL, 1, 1, '2024-2027', 'dang_hoc', '2026-05-13 14:52:48', '2026-06-27 13:58:44'),
(3, 6, 'SV003', NULL, NULL, NULL, NULL, NULL, 2, 1, '2024-2027', 'dang_hoc', '2026-05-13 14:52:48', '2026-06-27 13:58:44'),
(8, 9, '011', NULL, NULL, NULL, NULL, NULL, 1, 1, '2024-2027', 'dang_hoc', '2026-06-13 22:43:01', '2026-06-27 13:58:44'),
(9, 7, 'SV007', NULL, NULL, NULL, NULL, NULL, 1, 1, '2024-2027', 'dang_hoc', '2026-06-15 00:35:52', '2026-06-27 13:58:44'),
(11, 8, 'SV008', NULL, NULL, NULL, NULL, NULL, 1, 1, '2024-2027', 'dang_hoc', '2026-06-15 00:36:40', '2026-06-27 13:58:44'),
(12, 11, 'SV0021', '2004-10-21', 'nam', '969427271', '7920000000', 'Cuchi', 4, 2, '2020-2023', 'dang_hoc', '2026-07-03 01:29:44', '2026-07-03 01:29:44');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `sinh_vien_lop_hoc_phan`
--

CREATE TABLE `sinh_vien_lop_hoc_phan` (
  `id` int(11) NOT NULL,
  `sinh_vien_id` int(11) DEFAULT NULL,
  `lop_hoc_phan_id` int(11) DEFAULT NULL,
  `trang_thai` enum('dang_hoc','da_huy','hoan_thanh') DEFAULT 'dang_hoc',
  `ngay_dang_ky` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `sinh_vien_lop_hoc_phan`
--

INSERT INTO `sinh_vien_lop_hoc_phan` (`id`, `sinh_vien_id`, `lop_hoc_phan_id`, `trang_thai`, `ngay_dang_ky`) VALUES
(1, 1, 1, 'dang_hoc', '2026-04-22 03:23:53'),
(2, 2, 1, 'dang_hoc', '2026-04-22 03:23:53'),
(3, 3, 2, 'dang_hoc', '2026-04-22 03:23:53'),
(4, 1, 2, 'dang_hoc', '2026-04-22 03:23:53'),
(5, 2, 3, 'dang_hoc', '2026-04-22 03:23:53'),
(6, 8, 4, 'dang_hoc', '2026-06-14 17:37:26'),
(8, 9, 4, 'dang_hoc', '2026-06-14 17:59:23'),
(9, 11, 5, 'dang_hoc', '2026-06-14 18:10:05'),
(10, 11, 4, 'dang_hoc', '2026-06-14 18:20:24'),
(11, 8, 5, 'dang_hoc', '2026-06-14 18:28:59'),
(12, 3, 6, 'dang_hoc', '2026-06-28 07:39:57'),
(13, 1, 7, 'dang_hoc', '2026-06-28 07:42:21'),
(14, 2, 7, 'dang_hoc', '2026-06-28 07:42:21'),
(15, 8, 7, 'dang_hoc', '2026-06-28 07:42:21'),
(16, 9, 7, 'dang_hoc', '2026-06-28 07:42:21'),
(17, 11, 7, 'dang_hoc', '2026-06-28 07:42:21');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tai_lieu`
--

CREATE TABLE `tai_lieu` (
  `id` int(11) NOT NULL,
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

INSERT INTO `tai_lieu` (`id`, `tieu_de`, `mo_ta`, `duong_dan_file`, `lop_hoc_phan_id`, `nguoi_tao_id`, `trang_thai`, `ngay_tao`, `ngay_cap_nhat`) VALUES
(1, 'Tai lieu Flutter PDF', NULL, 'uploads/flutter.pdf', 1, 2, 'hien_thi', '2026-04-22 03:23:53', '2026-05-30 15:51:22'),
(2, 'Slide MySQL', NULL, 'uploads/mysql.ppt', 2, 2, 'hien_thi', '2026-04-22 03:23:53', '2026-07-07 02:54:42'),
(3, 'Tai lieu Marketing', NULL, 'uploads/marketing.pdf', 3, 3, 'hien_thi', '2026-04-22 03:23:53', '2026-05-30 15:51:22'),
(5, 'gbvcx', 'sdfg', 'sdfg.pdf', 2, 2, 'hien_thi', '2026-06-13 11:49:55', '2026-07-07 02:54:10');

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
(1, 'Thong bao 1', 'Nop bai truoc han', NULL, 1, 2, 'hien_thi', '2026-04-22 03:23:53', '2026-05-30 15:51:58'),
(2, 'Thong bao 2', 'Kiem tra giua ky', NULL, 2, 2, 'hien_thi', '2026-04-22 03:23:53', '2026-05-30 15:51:58'),
(3, 'Thong bao 3', 'Nghi hoc tuan nay', NULL, 3, 3, 'hien_thi', '2026-04-22 03:23:53', '2026-05-30 15:51:58'),
(4, 'aaaaa', 'aaaaaaaaa', NULL, 1, 2, 'hien_thi', '2026-06-13 11:12:06', '2026-06-13 18:12:06'),
(6, 'ccccccc', 'cccccccccccc', NULL, 2, 2, 'hien_thi', '2026-06-13 11:43:05', '2026-06-13 18:43:05');

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
-- Chỉ mục cho bảng `bai_lam_quiz`
--
ALTER TABLE `bai_lam_quiz`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_bai_lam_quiz_sv_bai_tap` (`bai_tap_id`,`sinh_vien_id`),
  ADD KEY `idx_bai_lam_quiz_sinh_vien` (`sinh_vien_id`);

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
-- Chỉ mục cho bảng `bai_tap`
--
ALTER TABLE `bai_tap`
  ADD PRIMARY KEY (`id`),
  ADD KEY `lop_hoc_phan_id` (`lop_hoc_phan_id`),
  ADD KEY `fk_bai_tap_nguoi_tao` (`nguoi_tao_id`),
  ADD KEY `idx_bai_tap_chu_de` (`chu_de_id`),
  ADD KEY `idx_bai_tap_gui` (`lop_hoc_phan_id`,`trang_thai`,`thoi_gian_gui`);

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
  ADD KEY `fk_binh_luan_bai_viet` (`bai_viet_id`);

--
-- Chỉ mục cho bảng `bo_mon`
--
ALTER TABLE `bo_mon`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ma_bo_mon` (`ma_bo_mon`),
  ADD KEY `fk_bo_mon_khoa` (`khoa_id`);

--
-- Chỉ mục cho bảng `cau_hoi_quiz`
--
ALTER TABLE `cau_hoi_quiz`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cau_hoi_quiz_bai_tap` (`bai_tap_id`);

--
-- Chỉ mục cho bảng `chi_tiet_bai_lam_quiz`
--
ALTER TABLE `chi_tiet_bai_lam_quiz`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_ct_blq_unique_answer` (`bai_lam_quiz_id`,`cau_hoi_id`,`dap_an_id`),
  ADD KEY `idx_ct_blq_bai_lam` (`bai_lam_quiz_id`),
  ADD KEY `idx_ct_blq_cau_hoi` (`cau_hoi_id`),
  ADD KEY `idx_ct_blq_dap_an` (`dap_an_id`);

--
-- Chỉ mục cho bảng `chu_de`
--
ALTER TABLE `chu_de`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_chu_de_lop_ten` (`lop_hoc_phan_id`,`ten_chu_de`),
  ADD KEY `idx_chu_de_lop_hoc_phan` (`lop_hoc_phan_id`);

--
-- Chỉ mục cho bảng `dap_an_quiz`
--
ALTER TABLE `dap_an_quiz`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_dap_an_quiz_cau_hoi` (`cau_hoi_id`);

--
-- Chỉ mục cho bảng `giang_vien`
--
ALTER TABLE `giang_vien`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nguoi_dung_id` (`nguoi_dung_id`),
  ADD UNIQUE KEY `ma_giang_vien` (`ma_giang_vien`),
  ADD KEY `fk_giang_vien_bo_mon` (`bo_mon_id`);

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
-- Chỉ mục cho bảng `quen_mat_khau`
--
ALTER TABLE `quen_mat_khau`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_quen_mat_khau_nguoi_dung` (`nguoi_dung_id`);

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
  ADD UNIQUE KEY `uq_svlhp_sinh_vien_lop_hoc_phan` (`sinh_vien_id`,`lop_hoc_phan_id`),
  ADD KEY `lop_hoc_phan_id` (`lop_hoc_phan_id`);

--
-- Chỉ mục cho bảng `tai_lieu`
--
ALTER TABLE `tai_lieu`
  ADD PRIMARY KEY (`id`),
  ADD KEY `lop_hoc_phan_id` (`lop_hoc_phan_id`),
  ADD KEY `nguoi_tao_id` (`nguoi_tao_id`);

--
-- Chỉ mục cho bảng `tep_tin`
--
ALTER TABLE `tep_tin`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tep_tin_nguoi_tao` (`nguoi_tao_id`);

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
  ADD KEY `fk_thong_bao_nguoi_tao` (`nguoi_tao_id`),
  ADD KEY `idx_thong_bao_gui` (`lop_hoc_phan_id`,`trang_thai`,`thoi_gian_gui`);

--
-- Chỉ mục cho bảng `vai_tro`
--
ALTER TABLE `vai_tro`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `bai_lam_quiz`
--
ALTER TABLE `bai_lam_quiz`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `bai_nop`
--
ALTER TABLE `bai_nop`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `bai_tap`
--
ALTER TABLE `bai_tap`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `bai_viet`
--
ALTER TABLE `bai_viet`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `binh_luan`
--
ALTER TABLE `binh_luan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `bo_mon`
--
ALTER TABLE `bo_mon`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `cau_hoi_quiz`
--
ALTER TABLE `cau_hoi_quiz`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `chi_tiet_bai_lam_quiz`
--
ALTER TABLE `chi_tiet_bai_lam_quiz`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `chu_de`
--
ALTER TABLE `chu_de`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT cho bảng `dap_an_quiz`
--
ALTER TABLE `dap_an_quiz`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT cho bảng `giang_vien`
--
ALTER TABLE `giang_vien`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `khoa`
--
ALTER TABLE `khoa`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT cho bảng `nhap_excel_dot`
--
ALTER TABLE `nhap_excel_dot`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT cho bảng `tai_lieu`
--
ALTER TABLE `tai_lieu`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `tep_tin`
--
ALTER TABLE `tep_tin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

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
-- AUTO_INCREMENT cho bảng `vai_tro`
--
ALTER TABLE `vai_tro`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `bai_lam_quiz`
--
ALTER TABLE `bai_lam_quiz`
  ADD CONSTRAINT `fk_bai_lam_quiz_bai_tap` FOREIGN KEY (`bai_tap_id`) REFERENCES `bai_tap` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_bai_lam_quiz_sinh_vien` FOREIGN KEY (`sinh_vien_id`) REFERENCES `sinh_vien` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `bai_nop`
--
ALTER TABLE `bai_nop`
  ADD CONSTRAINT `bai_nop_ibfk_1` FOREIGN KEY (`bai_tap_id`) REFERENCES `bai_tap` (`id`),
  ADD CONSTRAINT `fk_bai_nop_giang_vien_cham` FOREIGN KEY (`giang_vien_cham_id`) REFERENCES `giang_vien` (`id`),
  ADD CONSTRAINT `fk_bai_nop_sinh_vien` FOREIGN KEY (`sinh_vien_id`) REFERENCES `sinh_vien` (`id`);

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
  ADD CONSTRAINT `binh_luan_ibfk_1` FOREIGN KEY (`nguoi_dung_id`) REFERENCES `nguoi_dung` (`id`),
  ADD CONSTRAINT `binh_luan_ibfk_2` FOREIGN KEY (`lop_hoc_phan_id`) REFERENCES `lop_hoc_phan` (`id`),
  ADD CONSTRAINT `fk_binh_luan_bai_viet` FOREIGN KEY (`bai_viet_id`) REFERENCES `bai_viet` (`id`);

--
-- Các ràng buộc cho bảng `bo_mon`
--
ALTER TABLE `bo_mon`
  ADD CONSTRAINT `fk_bo_mon_khoa` FOREIGN KEY (`khoa_id`) REFERENCES `khoa` (`id`);

--
-- Các ràng buộc cho bảng `cau_hoi_quiz`
--
ALTER TABLE `cau_hoi_quiz`
  ADD CONSTRAINT `fk_cau_hoi_quiz_bai_tap` FOREIGN KEY (`bai_tap_id`) REFERENCES `bai_tap` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `chi_tiet_bai_lam_quiz`
--
ALTER TABLE `chi_tiet_bai_lam_quiz`
  ADD CONSTRAINT `fk_ct_blq_bai_lam` FOREIGN KEY (`bai_lam_quiz_id`) REFERENCES `bai_lam_quiz` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ct_blq_cau_hoi` FOREIGN KEY (`cau_hoi_id`) REFERENCES `cau_hoi_quiz` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ct_blq_dap_an` FOREIGN KEY (`dap_an_id`) REFERENCES `dap_an_quiz` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `chu_de`
--
ALTER TABLE `chu_de`
  ADD CONSTRAINT `fk_chu_de_lop_hoc_phan` FOREIGN KEY (`lop_hoc_phan_id`) REFERENCES `lop_hoc_phan` (`id`);

--
-- Các ràng buộc cho bảng `dap_an_quiz`
--
ALTER TABLE `dap_an_quiz`
  ADD CONSTRAINT `fk_dap_an_quiz_cau_hoi` FOREIGN KEY (`cau_hoi_id`) REFERENCES `cau_hoi_quiz` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `giang_vien`
--
ALTER TABLE `giang_vien`
  ADD CONSTRAINT `fk_giang_vien_bo_mon` FOREIGN KEY (`bo_mon_id`) REFERENCES `bo_mon` (`id`),
  ADD CONSTRAINT `fk_giang_vien_nguoi_dung` FOREIGN KEY (`nguoi_dung_id`) REFERENCES `nguoi_dung` (`id`);

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
  ADD CONSTRAINT `fk_svlhp_lop_hoc_phan` FOREIGN KEY (`lop_hoc_phan_id`) REFERENCES `lop_hoc_phan` (`id`),
  ADD CONSTRAINT `fk_svlhp_sinh_vien` FOREIGN KEY (`sinh_vien_id`) REFERENCES `sinh_vien` (`id`);

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
