-- MySQL dump 10.13  Distrib 5.1.57, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: hibernate
-- ------------------------------------------------------
-- Server version	5.1.57-3-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `AUTHORITIES`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `AUTHORITIES` (
  `AUTHORITY` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `DESCRIPTION` varchar(100) COLLATE latin1_general_ci DEFAULT NULL,
  PRIMARY KEY (`AUTHORITY`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `BDPARAMS`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `BDPARAMS` (
  `ITEMID` varchar(100) NOT NULL,
  `PARAMVALUE` varchar(50) DEFAULT NULL,
  `PARAMKEY` varchar(50) NOT NULL,
  PRIMARY KEY (`ITEMID`,`PARAMKEY`),
  KEY `FK61733C48FA34BFDC` (`ITEMID`),
  CONSTRAINT `FK61733C48FA34BFDC` FOREIGN KEY (`ITEMID`) REFERENCES `RTELEMENT` (`INSTANCEID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `BGCONTENTID`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `BGCONTENTID` (
  `BGCONTID` varchar(100) NOT NULL,
  `REVISION` int(11) NOT NULL,
  `BGUSER` varchar(100) NOT NULL,
  PRIMARY KEY (`BGCONTID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CONTENTITEM`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `CONTENTITEM` (
  `CONTITEMID` varchar(100) NOT NULL,
  `REVISION` int(11) NOT NULL,
  `NAME` varchar(200) NOT NULL,
  `parent_id` varchar(100) DEFAULT NULL,
  `PATH` varchar(767) NOT NULL,
  `TITLE` varchar(200) NOT NULL,
  `MIMETYPE` varchar(100) DEFAULT NULL,
  `URL` varchar(254) DEFAULT NULL,
  `LATESTVERNUM` int(11) DEFAULT NULL,
  `EXTENSION` varchar(10) NOT NULL,
  `WRITEMODE` int(11) NOT NULL,
  PRIMARY KEY (`CONTITEMID`),
  UNIQUE KEY `PATH` (`PATH`),
  KEY `FK692B5EEC44F32395` (`parent_id`),
  CONSTRAINT `FK692B5EEC44F32395` FOREIGN KEY (`parent_id`) REFERENCES `CONTENTLOCATION` (`CONTENTID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CONTENTLOCATION`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `CONTENTLOCATION` (
  `CONTENTID` varchar(100) NOT NULL,
  `REVISION` int(11) NOT NULL,
  `NAME` varchar(200) NOT NULL,
  `SOLNID` varchar(100) NOT NULL,
  `DESCRIPTION` varchar(200) NOT NULL,
  `DIRPATH` varchar(767) NOT NULL,
  PRIMARY KEY (`CONTENTID`),
  UNIQUE KEY `DIRPATH` (`DIRPATH`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CONTITEMFILE`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `CONTITEMFILE` (
  `CONTIFILEID` varchar(100) NOT NULL,
  `REVISION` int(11) NOT NULL,
  `OSFILENAME` varchar(200) NOT NULL,
  `OSPATH` varchar(1024) NOT NULL,
  `ACTNAME` varchar(100) NOT NULL,
  `parent_id` varchar(100) DEFAULT NULL,
  `FILESIZE` bigint(20) DEFAULT NULL,
  `FILEDATETIME` datetime NOT NULL,
  `ISINITIALIZED` int(11) DEFAULT NULL,
  PRIMARY KEY (`CONTIFILEID`),
  KEY `FK7FC3F44164D906F3` (`parent_id`),
  CONSTRAINT `FK7FC3F44164D906F3` FOREIGN KEY (`parent_id`) REFERENCES `CONTENTITEM` (`CONTITEMID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CPLXPARAMS`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `CPLXPARAMS` (
  `ITEMID` varchar(100) NOT NULL,
  `PARAMVALUE` blob,
  `PARAMKEY` varchar(50) NOT NULL,
  PRIMARY KEY (`ITEMID`,`PARAMKEY`),
  KEY `FKD6D6E97FFA34BFDC` (`ITEMID`),
  CONSTRAINT `FKD6D6E97FFA34BFDC` FOREIGN KEY (`ITEMID`) REFERENCES `RTELEMENT` (`INSTANCEID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `DATASOURCE`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `DATASOURCE` (
  `NAME` varchar(50) NOT NULL,
  `MAXACTCONN` int(11) NOT NULL,
  `DRIVERCLASS` varchar(50) NOT NULL,
  `IDLECONN` int(11) NOT NULL,
  `USERNAME` varchar(50) DEFAULT NULL,
  `PASSWORD` varchar(150) DEFAULT NULL,
  `URL` varchar(512) NOT NULL,
  `QUERY` varchar(100) DEFAULT NULL,
  `WAIT` int(11) NOT NULL,
  PRIMARY KEY (`NAME`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `DTPARAMS`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `DTPARAMS` (
  `ITEMID` varchar(100) NOT NULL,
  `PARAMVALUE` datetime DEFAULT NULL,
  `PARAMKEY` varchar(50) NOT NULL,
  PRIMARY KEY (`ITEMID`,`PARAMKEY`),
  KEY `FK7F994A16FA34BFDC` (`ITEMID`),
  CONSTRAINT `FK7F994A16FA34BFDC` FOREIGN KEY (`ITEMID`) REFERENCES `RTELEMENT` (`INSTANCEID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GRANTED_AUTHORITIES`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `GRANTED_AUTHORITIES` (
  `USERNAME` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `AUTHORITY` varchar(50) COLLATE latin1_general_ci NOT NULL,
  KEY `FK_GRANTED_AUTHORITIES_USERS` (`USERNAME`),
  KEY `FK_GRANTED_AUTHORITIES_AUTHORITIES` (`AUTHORITY`),
  KEY `FK7471775DD9EDC77F` (`USERNAME`),
  KEY `FK7471775D41B6DA97` (`AUTHORITY`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `LNGPARAMS`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `LNGPARAMS` (
  `ITEMID` varchar(100) NOT NULL,
  `PARAMVALUE` bigint(20) DEFAULT NULL,
  `PARAMKEY` varchar(50) NOT NULL,
  PRIMARY KEY (`ITEMID`,`PARAMKEY`),
  KEY `FKE304FCCBFA34BFDC` (`ITEMID`),
  CONSTRAINT `FKE304FCCBFA34BFDC` FOREIGN KEY (`ITEMID`) REFERENCES `RTELEMENT` (`INSTANCEID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `LSPARAMS`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `LSPARAMS` (
  `ITEMID` varchar(100) NOT NULL,
  `PARAMVALUE` text,
  `PARAMKEY` varchar(50) NOT NULL,
  PRIMARY KEY (`ITEMID`,`PARAMKEY`),
  KEY `FK89BC75CDFA34BFDC` (`ITEMID`),
  CONSTRAINT `FK89BC75CDFA34BFDC` FOREIGN KEY (`ITEMID`) REFERENCES `RTELEMENT` (`INSTANCEID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PARAMTYPESMAP`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `PARAMTYPESMAP` (
  `ITEMID` varchar(100) NOT NULL,
  `PARAMVALUE` varchar(25) DEFAULT NULL,
  `PARAMKEY` varchar(50) NOT NULL,
  PRIMARY KEY (`ITEMID`,`PARAMKEY`),
  KEY `FKD3EDA1B0FA34BFDC` (`ITEMID`),
  CONSTRAINT `FKD3EDA1B0FA34BFDC` FOREIGN KEY (`ITEMID`) REFERENCES `RTELEMENT` (`INSTANCEID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PRO_ACLS_LIST`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `PRO_ACLS_LIST` (
  `ACL_ID` varchar(100) NOT NULL,
  `ACL_MASK` int(11) NOT NULL,
  `RECIP_TYPE` int(11) NOT NULL,
  `RECIPIENT` varchar(255) NOT NULL,
  `ACL_POSITION` int(11) NOT NULL,
  PRIMARY KEY (`ACL_ID`,`ACL_POSITION`),
  KEY `FKB65646C2B23C5D30` (`ACL_ID`),
  CONSTRAINT `FKB65646C2B23C5D30` FOREIGN KEY (`ACL_ID`) REFERENCES `PRO_FILES` (`FILE_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PRO_FILES`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `PRO_FILES` (
  `FILE_ID` varchar(100) NOT NULL,
  `revision` int(11) NOT NULL,
  `parent` varchar(100) DEFAULT NULL,
  `fileName` varchar(255) NOT NULL,
  `fullPath` varchar(767) NOT NULL,
  `data` longblob,
  `directory` bit(1) NOT NULL,
  `lastModified` bigint(20) NOT NULL,
  `CHILD_ID` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`FILE_ID`),
  UNIQUE KEY `fullPath` (`fullPath`),
  KEY `FK94A87E2569FABF5E` (`CHILD_ID`),
  KEY `FK94A87E25CBBBB0EA` (`parent`),
  CONSTRAINT `FK94A87E2569FABF5E` FOREIGN KEY (`CHILD_ID`) REFERENCES `PRO_FILES` (`FILE_ID`),
  CONSTRAINT `FK94A87E25CBBBB0EA` FOREIGN KEY (`parent`) REFERENCES `PRO_FILES` (`FILE_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PRO_SCHEDULE`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `PRO_SCHEDULE` (
  `SCHEDULEID` varchar(100) NOT NULL,
  `REVISION` int(11) NOT NULL,
  `SCHEDTITLE` varchar(200) NOT NULL,
  `SCHEDREF` varchar(1024) NOT NULL,
  `SCHEDDESC` varchar(50) NOT NULL,
  `CRONSTRING` varchar(256) DEFAULT NULL,
  `REPEATCOUNT` int(11) DEFAULT NULL,
  `REPEATINTERVAL` int(11) DEFAULT NULL,
  `STARTDATE` datetime DEFAULT NULL,
  `ENDDATE` datetime DEFAULT NULL,
  `GROUPNAME` varchar(50) DEFAULT NULL,
  `LAST_TRIGGER` datetime DEFAULT NULL,
  PRIMARY KEY (`SCHEDULEID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PRO_SUBCONTENT`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `PRO_SUBCONTENT` (
  `SUBCONTID` varchar(100) NOT NULL,
  `REVISION` int(11) NOT NULL,
  `SUBCONTTYPE` varchar(255) NOT NULL,
  `SUBCONTACTREF` varchar(767) NOT NULL,
  PRIMARY KEY (`SUBCONTID`),
  UNIQUE KEY `SUBCONTACTREF` (`SUBCONTACTREF`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PRO_SUBCONTPARMS`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `PRO_SUBCONTPARMS` (
  `ITEMID` varchar(100) NOT NULL,
  `PARAMVALUE` blob,
  `PARAMKEY` varchar(100) NOT NULL,
  PRIMARY KEY (`ITEMID`,`PARAMKEY`),
  KEY `FKF3CE4C47846761A` (`ITEMID`),
  CONSTRAINT `FKF3CE4C47846761A` FOREIGN KEY (`ITEMID`) REFERENCES `PRO_SUBCONTENT` (`SUBCONTID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PRO_SUBCONT_SCHEDLIST`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `PRO_SUBCONT_SCHEDLIST` (
  `SCHEDULEID` varchar(100) NOT NULL,
  `elt` varchar(100) NOT NULL,
  `SCHEDID` int(11) NOT NULL,
  PRIMARY KEY (`SCHEDULEID`,`SCHEDID`),
  KEY `FKF0D3FBD69E226721` (`elt`),
  KEY `FKF0D3FBD62593BC9E` (`SCHEDULEID`),
  CONSTRAINT `FKF0D3FBD62593BC9E` FOREIGN KEY (`SCHEDULEID`) REFERENCES `PRO_SUBCONTENT` (`SUBCONTID`),
  CONSTRAINT `FKF0D3FBD69E226721` FOREIGN KEY (`elt`) REFERENCES `PRO_SCHEDULE` (`SCHEDULEID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PRO_SUBSCRIBE`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `PRO_SUBSCRIBE` (
  `SUBSCRID` varchar(100) NOT NULL,
  `REVISION` int(11) NOT NULL,
  `SUBSCRTYPE` int(11) NOT NULL,
  `SUBSCRUSER` varchar(100) NOT NULL,
  `SUBSCRTITLE` varchar(200) NOT NULL,
  `SUBSCR_CONTID` varchar(100) DEFAULT NULL,
  `SUBSCRDEST` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`SUBSCRID`),
  KEY `FK5E7511F89D8AC376` (`SUBSCR_CONTID`),
  CONSTRAINT `FK5E7511F89D8AC376` FOREIGN KEY (`SUBSCR_CONTID`) REFERENCES `PRO_SUBCONTENT` (`SUBCONTID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PRO_SUBSCRPARMS`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `PRO_SUBSCRPARMS` (
  `ITEMID` varchar(100) NOT NULL,
  `PARAMVALUE` blob,
  `PARAMKEY` varchar(100) NOT NULL,
  PRIMARY KEY (`ITEMID`,`PARAMKEY`),
  KEY `FK95DADE9355DC7DE8` (`ITEMID`),
  CONSTRAINT `FK95DADE9355DC7DE8` FOREIGN KEY (`ITEMID`) REFERENCES `PRO_SUBSCRIBE` (`SUBSCRID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PRO_SUBS_SCHEDLIST`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `PRO_SUBS_SCHEDLIST` (
  `SCHEDULEID` varchar(100) NOT NULL,
  `elt` varchar(100) NOT NULL,
  `SCHEDID` int(11) NOT NULL,
  PRIMARY KEY (`SCHEDULEID`,`SCHEDID`),
  KEY `FK2A8C749B9E226721` (`elt`),
  KEY `FK2A8C749B7329C46C` (`SCHEDULEID`),
  CONSTRAINT `FK2A8C749B7329C46C` FOREIGN KEY (`SCHEDULEID`) REFERENCES `PRO_SUBSCRIBE` (`SUBSCRID`),
  CONSTRAINT `FK2A8C749B9E226721` FOREIGN KEY (`elt`) REFERENCES `PRO_SCHEDULE` (`SCHEDULEID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RTELEMENT`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `RTELEMENT` (
  `INSTANCEID` varchar(100) NOT NULL,
  `REVISION` int(11) NOT NULL,
  `PARID` varchar(254) DEFAULT NULL,
  `PARTYPE` varchar(50) DEFAULT NULL,
  `SOLNID` varchar(254) DEFAULT NULL,
  `READONLY` bit(1) DEFAULT NULL,
  `CREATED` datetime NOT NULL,
  PRIMARY KEY (`INSTANCEID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SSPARAMS`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `SSPARAMS` (
  `ITEMID` varchar(100) NOT NULL,
  `PARAMVALUE` varchar(254) DEFAULT NULL,
  `PARAMKEY` varchar(50) NOT NULL,
  PRIMARY KEY (`ITEMID`,`PARAMKEY`),
  KEY `FK60E4AFE6FA34BFDC` (`ITEMID`),
  CONSTRAINT `FK60E4AFE6FA34BFDC` FOREIGN KEY (`ITEMID`) REFERENCES `RTELEMENT` (`INSTANCEID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `USERS`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `USERS` (
  `USERNAME` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `PASSWORD` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `ENABLED` tinyint(1) NOT NULL,
  `DESCRIPTION` varchar(100) COLLATE latin1_general_ci DEFAULT NULL,
  PRIMARY KEY (`USERNAME`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `USER_SETTINGS`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `USER_SETTINGS` (
  `USER_SETTINGS_ID` bigint(20) NOT NULL,
  `USERNAME` varchar(50) NOT NULL,
  `SETTING_NAME` varchar(100) NOT NULL,
  `SETTING_VALUE` varchar(2048) NOT NULL,
  PRIMARY KEY (`USER_SETTINGS_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cda_cacheControl`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `cda_cacheControl` (
  `queryId` bigint(20) NOT NULL AUTO_INCREMENT,
  `discriminator` varchar(20) NOT NULL,
  `cdaFile` varchar(254) NOT NULL,
  `dataAccessId` varchar(254) NOT NULL,
  `hitCount` int(11) DEFAULT NULL,
  `missCount` int(11) DEFAULT NULL,
  `timeElapsed` bigint(20) DEFAULT NULL,
  `uname` varchar(255) DEFAULT NULL,
  `lastExecuted` datetime DEFAULT NULL,
  `nextExecution` datetime DEFAULT NULL,
  `cronString` varchar(254) NOT NULL,
  `success` bit(1) DEFAULT NULL,
  PRIMARY KEY (`queryId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cda_cachedParams`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `cda_cachedParams` (
  `id` bigint(20) NOT NULL,
  `paramName` varchar(254) NOT NULL,
  `paramValue` varchar(254) NOT NULL,
  `paramid` bigint(20) DEFAULT NULL,
  `idx` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKB92B6307FB97ED80` (`paramid`),
  CONSTRAINT `FKB92B6307FB97ED80` FOREIGN KEY (`paramid`) REFERENCES `cda_cacheControl` (`queryId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdf_storage`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `cdf_storage` (
  `storageid` int(11) NOT NULL AUTO_INCREMENT,
  `pentahouser` varchar(255) DEFAULT NULL,
  `storagevalue` text,
  `lastupdated` datetime NOT NULL,
  PRIMARY KEY (`storageid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-12-08 18:32:16

