-- MySQL dump 10.13  Distrib 8.4.3, for Win64 (x86_64)
--
-- Host: localhost    Database: db_magang
-- ------------------------------------------------------
-- Server version	8.4.3

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `bimbingan`
--

DROP TABLE IF EXISTS `bimbingan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bimbingan` (
  `id_bimbingan` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_pendaftaran` bigint unsigned NOT NULL,
  `nidn` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_bimbingan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bimbingan`
--

LOCK TABLES `bimbingan` WRITE;
/*!40000 ALTER TABLE `bimbingan` DISABLE KEYS */;
/*!40000 ALTER TABLE `bimbingan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dosen`
--

DROP TABLE IF EXISTS `dosen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dosen` (
  `nidn` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_user` bigint unsigned NOT NULL,
  `nama` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`nidn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dosen`
--

LOCK TABLES `dosen` WRITE;
/*!40000 ALTER TABLE `dosen` DISABLE KEYS */;
/*!40000 ALTER TABLE `dosen` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` smallint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logbook`
--

DROP TABLE IF EXISTS `logbook`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logbook` (
  `id_logbook` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_pendaftaran` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `minggu_ke` int NOT NULL,
  `tanggal` date NOT NULL,
  `deskripsi_kegiatan` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status_validasi` enum('pending','disetujui','revisi') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `feedback_dosen` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_logbook`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logbook`
--

LOCK TABLES `logbook` WRITE;
/*!40000 ALTER TABLE `logbook` DISABLE KEYS */;
INSERT INTO `logbook` VALUES (1,'1',1,'2026-08-12','Melakukan perancangan arsitektur IoT dan memesan sensor suhu.','disetujui','Perencanaan yang bagus. Lanjutkan.',NULL,NULL),(2,'1',2,'2026-08-11','Instalasi mikrokontroler dan pengujian pengiriman data.','pending',NULL,NULL,NULL);
/*!40000 ALTER TABLE `logbook` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lowongan`
--

DROP TABLE IF EXISTS `lowongan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lowongan` (
  `id_lowongan` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_mitra` bigint unsigned NOT NULL,
  `judul_posisi` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `deskripsi` text COLLATE utf8mb4_unicode_ci,
  `persyaratan` text COLLATE utf8mb4_unicode_ci,
  `kategori` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lokasi` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipe_kerja` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipe_kontrak` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `benefit` text COLLATE utf8mb4_unicode_ci,
  `kuota` int NOT NULL,
  `batas_waktu` date NOT NULL,
  `status_approval` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_lowongan`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lowongan`
--

LOCK TABLES `lowongan` WRITE;
/*!40000 ALTER TABLE `lowongan` DISABLE KEYS */;
INSERT INTO `lowongan` VALUES (1,2,'Backend Developer','Membangun arsitektur backend untuk manajemen turnamen divisi esports komunitas RRQ.','1. Mahasiswa Informatika konsentrasi Programming\n2. Memahami Laravel atau Node.js','Programming','Remote',NULL,NULL,'Sertifikat\nMentoring\nUang Saku',3,'2026-08-04','disetujui',NULL,NULL),(2,2,'IoT Engineer Smart Greenhouse','Merancang sistem automasi smart greenhouse berbasis sensor industri.','1. Paham mikrokontroler\n2. Mengerti jaringan sensor','Networking','Sleman, DIY',NULL,NULL,'Akses alat industri\nKonversi SKS PPK Ormawa',4,'2026-08-19','disetujui',NULL,'2026-07-05 20:03:59');
/*!40000 ALTER TABLE `lowongan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lowongans`
--

DROP TABLE IF EXISTS `lowongans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lowongans` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `company_category` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `position` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `requirements` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `quota` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lowongans`
--

LOCK TABLES `lowongans` WRITE;
/*!40000 ALTER TABLE `lowongans` DISABLE KEYS */;
/*!40000 ALTER TABLE `lowongans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mahasiswa`
--

DROP TABLE IF EXISTS `mahasiswa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mahasiswa` (
  `id_mahasiswa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_user` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nama` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `jurusan` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_mahasiswa`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mahasiswa`
--

LOCK TABLES `mahasiswa` WRITE;
/*!40000 ALTER TABLE `mahasiswa` DISABLE KEYS */;
INSERT INTO `mahasiswa` VALUES ('22.11.1234','1','Asrul Gamink','Informatika\r\nSistem Informasi\r\nIlmu Komunikasi',NULL,NULL);
/*!40000 ALTER TABLE `mahasiswa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_06_08_080014_create_mahasiswa_table',1),(5,'2026_06_08_080027_create_dosen_table',1),(6,'2026_06_08_080033_create_mitra_table',1),(7,'2026_06_08_080043_create_lowongan_table',1),(8,'2026_06_08_081122_create_personal_access_tokens_table',1),(9,'2026_06_21_070841_create_lowongans_table',1),(10,'2026_06_26_054353_create_pendaftarans_table',1),(11,'2026_06_26_054405_create_logbooks_table',1),(12,'2026_06_29_071252_add_role_to_users_table',1),(13,'2026_07_02_190053_create_bimbingan_table',1),(14,'2026_07_04_071005_add_portofolio_to_pendaftarans_table',1),(15,'2026_07_04_152023_add_deskripsi_ke_tabel_lowongan',1),(16,'2026_07_04_152535_update_kolom_lowongan_table',1),(17,'2026_07_04_153616_add_laporan_akhir_to_pendaftaran_table',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mitra`
--

DROP TABLE IF EXISTS `mitra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mitra` (
  `id_mitra` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_user` bigint unsigned NOT NULL,
  `nama_perusahaan` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_mitra`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mitra`
--

LOCK TABLES `mitra` WRITE;
/*!40000 ALTER TABLE `mitra` DISABLE KEYS */;
/*!40000 ALTER TABLE `mitra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pendaftaran`
--

DROP TABLE IF EXISTS `pendaftaran`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pendaftaran` (
  `id_pendaftaran` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_mahasiswa` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_lowongan` bigint unsigned NOT NULL,
  `berkas_cv` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `portofolio` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `motivasi` text COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','diterima','ditolak','selesai') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `laporan_akhir` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_pendaftaran`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pendaftaran`
--

LOCK TABLES `pendaftaran` WRITE;
/*!40000 ALTER TABLE `pendaftaran` DISABLE KEYS */;
INSERT INTO `pendaftaran` VALUES (1,'22.11.1234',2,'berkas_cv_bintang.pdf',NULL,'Saya sangat tertarik dengan IoT dan Smart Farming untuk pertanian.','diterima',NULL,NULL,NULL),(2,'22.11.1234',2,'berkas_cv/65yruMmLWlRIuPwsJ2Tl6l3oiUUv0I3be6wHL5ed.pdf',NULL,'saya mau buat gundam','pending',NULL,'2026-07-05 20:03:59','2026-07-05 20:03:59');
/*!40000 ALTER TABLE `pendaftaran` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',1,'auth_token','bfbb9731e795bdab78d874ab6cc146f2693f00deea90861d5266afc9591f0696','[\"*\"]',NULL,NULL,'2026-07-05 10:03:40','2026-07-05 10:03:40'),(2,'App\\Models\\User',2,'auth_token','ad464782bf4cecb37b2498c432061aad38797b1f77579d519121a2314952dcb1','[\"*\"]','2026-07-05 10:05:14',NULL,'2026-07-05 10:04:49','2026-07-05 10:05:14'),(3,'App\\Models\\User',3,'auth_token','f3159b4e6bf8e833ec61afb7eab598dafb6e2385144115d5c75a388f6101c4ef','[\"*\"]',NULL,NULL,'2026-07-05 10:05:28','2026-07-05 10:05:28'),(4,'App\\Models\\User',4,'auth_token','f1952d0ffbc8970386b85ed896daf8020a108982371362eb10c90f1ad386b7a0','[\"*\"]',NULL,NULL,'2026-07-05 10:08:17','2026-07-05 10:08:17'),(5,'App\\Models\\User',1,'auth_token','b0290554949bd7d76a2d946616c28909f3178fa1bad7a77747a217fb174fbbd8','[\"*\"]',NULL,NULL,'2026-07-05 13:55:10','2026-07-05 13:55:10'),(6,'App\\Models\\User',3,'auth_token','09d3770bcff9488186f7ca8189231a3755efaa349023e074890adefbbb218867','[\"*\"]',NULL,NULL,'2026-07-05 13:56:11','2026-07-05 13:56:11'),(7,'App\\Models\\User',1,'auth_token','a7b6456700c0e9fe998b5c2f1f8a37a5c31fac244a2163623273ef27d4cf30f2','[\"*\"]',NULL,NULL,'2026-07-05 18:58:29','2026-07-05 18:58:29'),(8,'App\\Models\\User',1,'auth_token','5bd3c59fd4b61fbdef6dec9161e11dff4c64b07128d4a07b01d81eb0110a262c','[\"*\"]',NULL,NULL,'2026-07-05 19:23:24','2026-07-05 19:23:24'),(9,'App\\Models\\User',1,'auth_token','f452256f232deba69e610ca89c01f11693d7f747554068ae19b0d6111722cee5','[\"*\"]',NULL,NULL,'2026-07-05 19:32:11','2026-07-05 19:32:11'),(10,'App\\Models\\User',1,'auth_token','f5f7fa5091b8e68106fdeaa75fa99d7506e0a5e657e90a4cfcf0459e29d6771a','[\"*\"]','2026-07-05 20:00:53',NULL,'2026-07-05 19:37:39','2026-07-05 20:00:53'),(11,'App\\Models\\User',1,'auth_token','8d193e6ddad21d6e3436b4b5d8d487edb2044a208209984558db0c43fb61772c','[\"*\"]','2026-07-05 20:03:58',NULL,'2026-07-05 20:03:13','2026-07-05 20:03:58'),(12,'App\\Models\\User',2,'auth_token','9b7dae09d8de345a7471f8ea703c5f5a349fc228cfd540e9fae92f25894c700d','[\"*\"]',NULL,NULL,'2026-07-05 20:05:33','2026-07-05 20:05:33'),(13,'App\\Models\\User',2,'auth_token','425d69835e36cacbe82fdd0b93b87158466a4b55842e0914d0d3c88c0c8ac85a','[\"*\"]',NULL,NULL,'2026-07-05 20:06:08','2026-07-05 20:06:08'),(14,'App\\Models\\User',2,'auth_token','cfc4a85d0fb2be68a7e5a5f9c3ad0b59dad61fd7dc281d8be2802d8c5486bc01','[\"*\"]',NULL,NULL,'2026-07-05 20:25:26','2026-07-05 20:25:26'),(15,'App\\Models\\User',3,'auth_token','e2c869eb14aeaeaeed9ac16f22f85b8451390700bec209c06570c7692705ab7b','[\"*\"]',NULL,NULL,'2026-07-05 20:37:38','2026-07-05 20:37:38'),(16,'App\\Models\\User',3,'auth_token','4fafa7c105a317402f6149a86199c3e96591a067f60c6021762193e793785c8b','[\"*\"]','2026-07-05 21:05:25',NULL,'2026-07-05 20:57:48','2026-07-05 21:05:25'),(17,'App\\Models\\User',3,'auth_token','999093fa7b12c55b7651e9f08b77a6840f8dad339cbc2f2ffcf67dd6ca942a59','[\"*\"]','2026-07-05 21:06:54',NULL,'2026-07-05 21:05:47','2026-07-05 21:06:54'),(18,'App\\Models\\User',4,'auth_token','8a7c79f8746d80af70c44e5efad8bfb987637a05683a1701cce8a4f97ec44b84','[\"*\"]','2026-07-05 21:12:53',NULL,'2026-07-05 21:12:34','2026-07-05 21:12:53');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_or_nim` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `semester` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'mahasiswa',
  `konsentrasi` enum('multimedia','jaringan','pemrograman') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_or_nim_unique` (`email_or_nim`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Asrul Gamink','22.11.1234','$2y$12$eM0OgZmlXYNDdc0Z5ZDi6O9.3nORDLrz.UgZotIq3E/q.QrbGO48W',NULL,NULL,'mahasiswa',NULL,NULL,NULL,NULL),(2,'RRQ','mitra.RRQ','$2y$12$XBq.jHzOLXnA.uC3tMTLiuTGTgySmofSD87tnn5zkJd83q8x07zci',NULL,NULL,'mitra',NULL,NULL,NULL,NULL),(3,'Dr. Rina Saraswati, M.Kom.','dosen123','$2y$12$8pA9CII3fgR2d9ADDsJi7uRqa.7ZhgOtPGEjkikTK270tw9FOKUDO',NULL,NULL,'dosen',NULL,NULL,NULL,NULL),(4,'Admin Amikom','admin','$2y$12$BUDVCTAkp1JAcKYK.yNyAOnPAvL0J/t1WeDOq1ysNxRFzzoEejcYW',NULL,NULL,'admin',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-06 11:18:32
