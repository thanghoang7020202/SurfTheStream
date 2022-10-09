-- phpMyAdmin SQL Dump
-- version 5.1.1deb3+bionic1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: When I should have been sleeping. :)
-- Server version: The latest and best.
-- PHP Version: One of the secure ones.

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `SurfTheStream`
--
CREATE DATABASE IF NOT EXISTS `SurfTheStream` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `SurfTheStream`;

-- --------------------------------------------------------

--
-- Table structure for table `Customer`
--

DROP TABLE IF EXISTS `Customer`;
CREATE TABLE `Customer` (
  `id` VARCHAR(100) NOT NULL,
  `name` varchar(255) NOT NULL,
  `dob` date NOT NULL,
  `bestFriend` VARCHAR(100) DEFAULT NULL,
  `subscriptionLevel` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Movie`
--

DROP TABLE IF EXISTS `Movie`;
CREATE TABLE `Movie` (
  `prefix` char(4) NOT NULL,
  `suffix` char(4) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `rating` enum('G','PG','M','MA15+','R18+') NOT NULL,
  `releaseDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Triggers `Movie`
--
DROP TRIGGER IF EXISTS `checkPrefixInsert`;
DELIMITER $$
CREATE TRIGGER `checkPrefixInsert` BEFORE INSERT ON `Movie` FOR EACH ROW BEGIN 
IF (NEW.`prefix` REGEXP '^[a-zA-Z]{4}$' ) = 0 THEN 
  SIGNAL SQLSTATE '12345'
     SET MESSAGE_TEXT = 'Prefix Format Incorrect. (Four alphabet characters.)';
END IF; 
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `checkPrefixUpdate`;
DELIMITER $$
CREATE TRIGGER `checkPrefixUpdate` BEFORE UPDATE ON `Movie` FOR EACH ROW BEGIN 
IF (NEW.`prefix` REGEXP '^[a-zA-Z]{4}$' ) = 0 THEN 
  SIGNAL SQLSTATE '12345'
     SET MESSAGE_TEXT = 'Prefix Format Incorrect. (Four alphabet characters.)';
END IF; 
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `checkSuffixInsert`;
DELIMITER $$
CREATE TRIGGER `checkSuffixInsert` BEFORE INSERT ON `Movie` FOR EACH ROW BEGIN 
IF (NEW.`suffix` REGEXP '^[0-9]{4}$' ) = 0 THEN 
  SIGNAL SQLSTATE '12345'
     SET MESSAGE_TEXT = 'Suffix Format Incorrect. (Four numeric digits with leading zeros.)';
END IF; 
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `checkSuffixUpdate`;
DELIMITER $$
CREATE TRIGGER `checkSuffixUpdate` BEFORE UPDATE ON `Movie` FOR EACH ROW BEGIN 
IF (NEW.`suffix` REGEXP '^[0-9]{4}$' ) = 0 THEN 
  SIGNAL SQLSTATE '12345'
     SET MESSAGE_TEXT = 'Suffix Format Incorrect. (Four numeric digits with leading zeros.)';
END IF; 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Previews`
--

DROP TABLE IF EXISTS `Previews`;
CREATE TABLE `Previews` (
  `customer` varchar(100) NOT NULL,
  `moviePrefix` char(4) NOT NULL,
  `movieSuffix` char(4) NOT NULL,
  `timestamp` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Triggers `Previews`
--
DROP TRIGGER IF EXISTS `checkPreviewInsert`;
DELIMITER $$
CREATE TRIGGER `checkPreviewInsert` BEFORE INSERT ON `Previews` FOR EACH ROW BEGIN 
IF EXISTS (
		SELECT *
    	FROM Streams S
    	WHERE (NEW.`moviePrefix` = S.moviePrefix) AND (NEW.`movieSuffix` = S.movieSuffix) AND (NEW.`customer` = S.customer) AND (NEW.`timestamp` > S.timestamp)
	) THEN 
  SIGNAL SQLSTATE '12345'
     SET MESSAGE_TEXT = 'Semantic Constraint Violation. (Customers cannot preview a movie after they have started to stream it.)';
END IF; 
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `checkPreviewUpdate`;
DELIMITER $$
CREATE TRIGGER `checkPreviewUpdate` BEFORE UPDATE ON `Previews` FOR EACH ROW BEGIN 
IF EXISTS (
		SELECT *
    	FROM Streams S
    	WHERE (NEW.`moviePrefix` = S.moviePrefix) AND (NEW.`movieSuffix` = S.movieSuffix) AND (NEW.`customer` = S.customer) AND (NEW.`timestamp` > S.timestamp)
	) THEN 
  SIGNAL SQLSTATE '12345'
     SET MESSAGE_TEXT = 'Semantic Constraint Violation. (Customers cannot preview a movie after they have started to stream it.)';
END IF; 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Streams`
--

DROP TABLE IF EXISTS `Streams`;
CREATE TABLE `Streams` (
  `customer` varchar(100) NOT NULL,
  `moviePrefix` char(4) NOT NULL,
  `movieSuffix` char(4) NOT NULL,
  `timestamp` timestamp NOT NULL,
  `duration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Triggers `Streams`
--
DROP TRIGGER IF EXISTS `checkDurationInsert`;
DELIMITER $$
CREATE TRIGGER `checkDurationInsert` BEFORE INSERT ON `Streams` FOR EACH ROW BEGIN 
IF NEW.`duration` < 0 THEN 
  SIGNAL SQLSTATE '12345'
     SET MESSAGE_TEXT = 'Invalid Streaming Duration. The streaming duration must not be negative.';
END IF; 
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `checkDurationUpdate`;
DELIMITER $$
CREATE TRIGGER `checkDurationUpdate` BEFORE UPDATE ON `Streams` FOR EACH ROW BEGIN 
IF NEW.`duration` < 0 THEN 
  SIGNAL SQLSTATE '12345'
     SET MESSAGE_TEXT = 'Invalid Streaming Duration. The streaming duration must not be negative.';
END IF; 
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `checkStreamInsert`;
DELIMITER $$
CREATE TRIGGER `checkStreamInsert` BEFORE INSERT ON `Streams` FOR EACH ROW BEGIN 
IF EXISTS (
		SELECT *
    	FROM Previews P
    	WHERE (NEW.`moviePrefix` = P.moviePrefix) AND (NEW.`movieSuffix` = P.movieSuffix) AND (NEW.`customer` = P.customer) AND (P.timestamp > NEW.`timestamp`)
	) THEN 
  SIGNAL SQLSTATE '12345'
     SET MESSAGE_TEXT = 'Semantic Constraint Violation. (Customers cannot preview a movie after they have started to stream it.)';
END IF; 
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `checkStreamUpdate`;
DELIMITER $$
CREATE TRIGGER `checkStreamUpdate` BEFORE UPDATE ON `Streams` FOR EACH ROW BEGIN 
IF EXISTS (
		SELECT *
    	FROM Previews P
    	WHERE (NEW.`moviePrefix` = P.moviePrefix) AND (NEW.`movieSuffix` = P.movieSuffix) AND (NEW.`customer` = P.customer) AND (P.timestamp > NEW.`timestamp`)
	) THEN 
  SIGNAL SQLSTATE '12345'
     SET MESSAGE_TEXT = 'Semantic Constraint Violation. (Customers cannot preview a movie after they have started to stream it.)';
END IF; 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Subscription`
--

DROP TABLE IF EXISTS `Subscription`;
CREATE TABLE `Subscription` (
  `level` varchar(25) NOT NULL,
  `price` double(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- DATA
--

insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('738-vvc-525', 'Maybelle Ghidetti', '1998-12-18', null, 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('134-zqa-081', 'Morris Kunzel', '1947-01-29', '162-hqa-752', 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('162-hqa-752', 'Dorian Ivel', '1978-02-16', null, 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('238-ntw-925', 'Muffin Profit', '2009-10-02', '664-vvt-091', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('159-zhu-507', 'Lory Yardy', '1991-03-12', null, 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('488-xfr-095', 'Gates Braidford', '1997-09-27', '254-qjq-328', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('254-qjq-328', 'Ame Thow', '1952-02-27', null, 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('677-mef-089', 'Joletta Kitley', '1984-08-10', null, 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('664-vvt-091', 'Garrott Wane', '1953-05-13', '253-ojd-858', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('253-ojd-858', 'Morten Kubach', '1974-03-03', '738-vvc-525', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('674-ysu-659', 'Carlo Tompkin', '1995-02-23', null, 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('191-vir-059', 'Hardy Bullerwell', '1949-06-05', null, 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('057-toq-736', 'Hallie Braund', '1979-10-07', '191-vir-059', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('535-xbq-689', 'Walden Riteley', '1966-12-23', '253-ojd-858', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('044-owi-640', 'Carny Burtt', '1964-04-01', '253-ojd-858', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('470-mre-229', 'Dee dee Korbmaker', '1978-02-11', null, 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('541-nlg-797', 'Davin Titmuss', '1967-05-03', null, 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('136-vql-065', 'Robin Ridpath', '1962-04-24', null, 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('756-sth-728', 'Hannis Cliffe', '1960-03-30', '470-mre-229', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('257-dwu-165', 'Rita Nussen', '1952-03-28', '136-vql-065', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('980-sgv-254', 'Britt Braun', '1955-02-01', '136-vql-065', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('022-wuc-936', 'Dasya Hurburt', '2000-05-28', null, 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('397-oui-372', 'Marie-ann Brabin', '1950-12-09', '022-wuc-936', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('188-awq-308', 'Pebrook O''Dempsey', '1946-02-13', null, 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('700-nad', 'Kristofer Rupert', '1992-07-17', '188-awq-308', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('921-rox-723', 'Jenna Shafier', '1976-11-19', '700-nad', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('346-nzk-382', 'Aldridge Wyche', '1950-02-05', null, 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('361-nmp-751', 'Ruthi Blodg', '1971-12-19', '928-kau-489', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('833-gzw-944', 'Colly De Minico', '1955-02-28', '738-vvc-525', 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('741-qyq-244', 'Robinet Giordano', '1990-12-14', '907-anw-514', 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('907-anw-514', 'Kettie Haberfield', '1947-06-18', '392-uhz-406', 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('928-kau-489', 'Claretta Jeandeau', '1973-02-04', '392-uhz-406', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('392-uhz-406', 'Arlan Berzen', '1964-10-18', null, 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('145-kup-479', 'Debbi Embling', '2010-03-06', '833-gzw-944', 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('919-adw-261', 'Clara Gwinnel', '1959-04-09', null, 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('266-nnb-236', 'Dillon Hollington', '2010-09-02', null, 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('461-fib-609', 'Khalil Spieght', '2001-11-18', null, 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('730-ldf-468', 'Emmett McCrow', '1968-08-19', '662-xne-157', 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('593-ymt-349', 'Wanda Shenfisch', '1973-03-02', null, 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('662-xne-157', 'Adorne Velareal', '2011-01-12', null, 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('660-gnc-951', 'Billi Kondrat', '1946-11-27', '833-gzw-944', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('098-vfl-325', 'Loretta Chaffyn', '2001-07-06', null, 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('478-yjr-076', 'Davin Joao', '1958-01-22', null, 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('911-iku-076', 'Paul Stanistrete', '1945-11-20', '736-mtz-051', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('894-hdc-244', 'Norina Chelley', '1969-10-04', '069-eid-493', 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('069-eid-493', 'Frankie Tripony', '2011-09-17', '660-gnc-951', 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('520-onz-868', 'Rahel Toffts', '1955-01-17', '069-eid-493', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('998-zyp-523', 'Nedda Cow', '2003-11-06', '340-igt-367', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('340-igt-367', 'Clovis Vinau', '2010-01-27', null, 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('854-vzb-038', 'Poul Wisdom', '1980-07-09', '894-hdc-244', 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('072-gch-306', 'Cathrin Wawer', '1997-12-03', '529-cih-170', 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('736-mtz-051', 'Corry Lyptrade', '1945-03-14', '340-igt-367', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('951-uxm-072', 'Judy MacKimm', '2002-02-26', null, 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('529-cih-170', 'Lanni Falkingham', '1980-07-12', '149-isy-541', 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('848-niu-003', 'Mignonne Custed', '1995-12-12', '001-kgz-498', 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('001-kgz-498', 'Tedie Potteridge', '1993-01-05', null, 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('664-udc-941', 'Candie Wooller', '2011-06-29', '660-zxd-821', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('149-isy-541', 'Reeva Bosket', '1992-03-12', null, 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('399-psg-942', 'Tyrone Shewen', '2008-02-07', '149-isy-541', 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('660-zxd-821', 'Ashley Squibbes', '2006-08-12', null, 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('142-flp-971', 'Van Jados', '1955-11-08', '792-bfq-394', 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('792-bfq-394', 'Jozef Aitkenhead', '1968-11-15', null, 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('061-meo-439', 'Lexi Dearing', '1961-11-23', '774-ejz-507', 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('837-nlq-314', 'Ganny Fancutt', '2007-02-01', '069-eid-493', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('964-rzz-277', 'Lissy Massenhove', '1959-05-19', null, 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('762-ywh-585', 'Murvyn Hambrick', '1948-02-27', null, 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('774-ejz-507', 'Teddy Dilliway', '1992-10-28', '335-boi-403', 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('379-tqa-901', 'Erda Dunsford', '1953-10-03', null, 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('335-boi-403', 'Cornall Beaument', '1977-11-16', null, 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('310-cqn-446', 'Maximilian Niaves', '1960-06-13', '837-nlq-314', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('751-zla-785', 'Lianne Mattersey', '1962-05-26', '310-cqn-446', 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('585-hyw-659', 'Murray Hatherill', '1958-09-09', '335-boi-403', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('688-pfm-688', 'Douglas Silcox', '2011-07-17', '107-btc-275', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('588-nmx-784', 'Dorita Buzine', '1969-04-10', '107-btc-275', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('689-eac-874', 'Jaymee Ollier', '1968-03-28', null, 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('728-zfa-701', 'Thatch Bridges', '1980-08-19', null, 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('107-btc-275', 'Bessy Noyes', '1949-05-23', null, 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('625-gfd-228', 'Sharlene Ansell', '1973-04-23', null, 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('165-pjg-471', 'Gayler Wycliff', '2012-01-13', '614-cgd-337', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('614-cgd-337', 'Vivien Tapley', '2005-02-18', '984-wwy-346', 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('984-wwy-346', 'Jo-anne Braemer', '1989-05-12', '497-dpm-396', 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('297-dla-907', 'Jourdan Bakes', '1975-02-20', null, 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('106-bjs-091', 'Stevena Cullinan', '1995-12-03', '564-ihr-703', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('538-ncr-647', 'Boonie Kirvell', '1982-07-12', '792-bfq-394', 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('564-ihr-703', 'Patti Bollom', '2003-01-14', '792-bfq-394', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('497-dpm-396', 'Michael Kernoghan', '1962-06-14', null, 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('699-kuh-297', 'Lauree Gilling', '1972-11-23', '648-asc-849', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('485-suw-285', 'Peyton Raubenheimer', '1977-01-20', null, 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('836-ymi-756', 'Tara Gentery', '1991-01-13', '699-kuh-297', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('014-pms-687', 'Fernande Kettlesing', '1999-03-03', '538-ncr-647', 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('648-asc-849', 'Howey Fippe', '2004-06-03', '738-lzs-935', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('067-anp-920', 'Emmey Attride', '1957-04-13', '836-ymi-756', 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('048-tmk-454', 'Teressa Skune', '2003-06-11', '191-gvc-966', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('191-gvc-966', 'Emelyne Harbertson', '1987-01-30', '738-lzs-935', 'basic');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('738-lzs-935', 'Kellyann Ingles', '1996-01-23', '836-ymi-756', 'organisation');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('949-zjg-539', 'Crichton Benjamin', '1969-05-08', null, 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('484-ogz-688', 'Carola Cusworth', '1964-03-06', '936-nbm-141', 'pro');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('936-nbm-141', 'Fairfax Drewitt', '1954-10-10', '753-jlx-238', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('057-zhi-627', 'Blondie Honeywood', '1984-02-18', '984-wwy-346', 'premium');
insert into Customer (id, name, dob, bestFriend, subscriptionLevel) values ('753-jlx-238', 'Mada Alexis', '1945-04-14', null, 'organisation');

INSERT INTO `Subscription` (`level`, `price`) VALUES
('Basic', 199.50),
('Organisation', 2201.00),
('Premium', 405.89),
('Pro', 50.99),
('Tester', 0.00);


INSERT INTO `Movie` (`prefix`, `suffix`, `name`, `description`, `rating`, `releaseDate`) VALUES
('ABJF', '7245', 'Move', 'This movie started Jack Smith.', 'MA15+', '1965-10-13'),
('ACEH', '0941', 'Move 2', 'This movie started Yeseul Jeon.', 'M', '1984-03-29'),
('ADEU', '6883', 'Kicked in the Head', '11-500 - Industrial and Process Equipment', 'MA15+', '1974-07-06'),
('AEHF', '3027', 'Spawn', '4-600 - Corrosion-Resistant Masonry', 'M', '1978-10-04'),
('AFCI', '1624', 'Men Who Stare at Goats, The', '8 - Doors and Windows', 'M', '1954-08-21'),
('AGBL', '3689', 'Blackwoods', '10-150 - Compartments and Cubicles', 'M', '2014-08-08'),
('AHYC', '8059', 'Wendigo', '3-000 - General', 'M', '1948-12-02'),
('AIRK', '5532', 'Idiot Returns, The (Návrat idiota)', '8-200 - Wood and Plastic Doors', 'R18+', '1975-12-05'),
('AJIB', '5561', 'Nutcracker, The', '11-460 - Unit Kitchens', 'PG', '2014-08-22'),
('AJUH', '0291', 'Grand Dukes, The (Les grands ducs)', '1-510 - Temporary Utilities', 'G', '1990-01-22'),
('AKFF', '6623', 'The Sign of Four: Sherlock Holmes\' Greatest Case', '2-820 - Fences and Gates', 'M', '1959-11-15'),
('AKFW', '1016', 'Film ist.', '2-310 - Grading', 'M', '1991-09-06'),
('ALAS', '5790', 'Notebook, The (A nagy füzet)', '2-750 - Concrete Pads and Walks', 'R18+', '1971-08-13'),
('AMJD', '5770', '100 Feet', '2-770 - Curb and Gutters', 'PG', '1999-04-09'),
('AMPO', '8227', 'Floating Clouds  (Ukigumo)', '11-780 - Mortuary Equipment', 'R18+', '2012-05-12'),
('ANFY', '9323', 'Last Polka, The', '10-880 - Scales', 'M', '1982-04-19'),
('APFB', '7635', 'Lineup, The', '2-924 - Sodding', 'M', '1978-06-07'),
('ARIS', '7076', 'Rolling Family (Familia rodante)', '2-312 - Rough Grading', 'R18+', '1945-09-24'),
('ASYE', '2338', 'Boeing, Boeing', '2-317 - Select Borrow', 'MA15+', '1946-02-24'),
('AUDR', '5657', 'Johnny Be Good', '10-700 - Exterior Protection', 'MA15+', '1989-07-02'),
('AUPL', '3736', 'Dog Run', '5-050 - Basic Metal Materials and Methods', 'PG', '1951-01-04'),
('AUZZ', '4505', 'Farewell, Home Sweet Home (Adieu, plancher des vaches!)', '10-500 - Lockers', 'G', '1951-03-24'),
('AVDD', '6490', 'Violets Are Blue...', '4 - Masonry', 'R18+', '2006-03-02'),
('AVOI', '6834', 'Perfect Crime, The (Crimen Ferpecto) (Ferpect Crime)', '1-514 - Temporary Heating, Cooling and Ventilation', 'R18+', '1952-04-01'),
('AVSD', '4423', 'Georgy Girl', '11-600 - Laboratory Equipment', 'M', '2007-10-19'),
('AVVY', '0658', 'Beverly Hillbillies, The', '7-050 - Basic Thermal and Moisture Protection Materials and Methods', 'PG', '2014-05-28'),
('AWCB', '0302', 'Kung Fu Hustle (Gong fu)', '14-600 - Hoists and Cables', 'G', '2003-05-08'),
('AWNI', '7777', 'Man Without a Face, The', '2-500 - Utility Services', 'R18+', '1988-01-28'),
('AXGI', '2905', 'Louise-Michel', '11-650 - Planetarium Equipment', 'G', '1982-04-01'),
('AXUZ', '5250', 'How She Move', '6-100 - Rough Carpentry', 'M', '2008-07-09'),
('AYRS', '6381', 'Russian Dolls (Les poupées russes)', '15-200 - Process Piping', 'G', '1983-01-06'),
('AZFT', '0236', 'Boy A', '4-400 - Stone', 'MA15+', '2019-07-15'),
('BAAA', '7596', 'Little Big Soldier (Da bing xiao jiang)', '10-550 - Postal Specialties', 'MA15+', '1997-02-21'),
('BAXP', '6142', 'Coward, The (Kapurush)', '15-200 - Process Piping', 'M', '1957-11-06'),
('BBBK', '1814', 'Trick', '5 - Metals', 'M', '1959-02-28'),
('BBFE', '6191', 'Highlander: Endgame (Highlander IV)', '1-630 - Product Substitution Procedures', 'MA15+', '1986-05-11'),
('BBXG', '1968', 'Abduction', '7-400 - Roofing and Siding Panels', 'M', '1988-05-14'),
('BCFE', '8180', 'Robinson Crusoe on Mars', '11-280 - Hydraulic Gates and Valves', 'G', '1978-11-21'),
('BCOI', '1663', 'Epic', '9-680 - Carpet', 'R18+', '1961-08-03'),
('BCPD', '2801', 'Dance with Me', '3-230 - Anchor Bolts', 'G', '2005-06-15'),
('BCRU', '8105', 'Suicide Room', '2-935 - Plant Maintenance', 'M', '1985-11-11'),
('BDJX', '4600', 'Night of the Demons', '2-310 - Grading', 'R18+', '1951-11-04'),
('BDKV', '4154', 'Cheaper by the Dozen 2', '2-230 - Site Clearing', 'M', '1992-10-16'),
('BDNA', '7116', 'The Land Before Time IX: Journey to the Big Water', '3-100 - Concrete Reinforcement', 'PG', '1969-03-28'),
('BDOW', '0505', 'Nick Fury: Agent of S.H.I.E.L.D.', '2-900 - Landscaping', 'M', '1968-03-03'),
('BDWP', '8765', 'Spark: A Burning Man Story', '3-230 - Anchor Bolts', 'M', '1963-07-27'),
('BEWF', '7753', 'Hits', '2-310 - Grading', 'G', '1973-11-28'),
('BFGG', '4263', 'Sextette', '5-200 - Metal Joists', 'G', '1998-12-01'),
('BFMA', '9766', 'The Devil and the Holy Water', '2-821 - Chain Link Fences', 'M', '1951-07-04'),
('BGAN', '7893', 'The Circle', '11-450 - Residential Equipment', 'PG', '1980-12-16'),
('BGQK', '3817', 'Usual Suspects, The', '13-100 - Lightning Protection', 'PG', '1977-10-02'),
('BIMW', '4328', 'Cloak & Dagger', '10-290 - Pest Control', 'G', '2015-01-18'),
('BJOW', '9195', 'The Third Reich: The Rise & Fall', '2-784 - Stone Unit Pavers', 'M', '1949-03-02'),
('BJQA', '9391', 'Dukes, The', '7-400 - Roofing and Siding Panels', 'MA15+', '2016-06-22'),
('BKDY', '9224', 'The Woman in Black 2: Angel of Death', '2-312 - Rough Grading', 'M', '1957-08-28'),
('BKPU', '4838', 'Hamlet', '5-600 - Hydraulic Fabrications', 'PG', '1984-02-24'),
('BKRJ', '0565', 'Skyscraper Souls', '10-800 - Toilet, Bath, and Laundry Specialties', 'M', '1977-06-26'),
('BKVQ', '9037', 'Pleasure Garden, The', '5-100 - Structural Metals', 'M', '1949-10-24'),
('BKZF', '3788', 'Glengarry Glen Ross', '13 - Special Construction', 'G', '1964-12-21'),
('BLEJ', '8881', 'Bad Country', '13-185 - Kennels and Animal Shelters', 'MA15+', '2018-04-04'),
('BMBL', '0249', 'Light of Day', '11-020 - Security and Vault Equipment', 'M', '1983-08-19'),
('BMNC', '8737', 'Sleeping Beauty', '7-600 - Flashing and Sheet Metal', 'MA15+', '2020-01-20'),
('BMVD', '2108', 'Baby Doll', '10-400 - Identification Devices', 'R18+', '2019-12-29'),
('BNKZ', '5558', 'Space Pirate Captain Harlock: Arcadia of My Youth (Waga seishun no Arcadia)', '14-100 - Dumbwaiters', 'MA15+', '1999-06-27'),
('BPKX', '0190', 'Hidden Agenda', '8-500 - Windows', 'MA15+', '1980-05-08'),
('BPUU', '6137', 'Last Ferry, The (Ostatni prom)', '11-300 - Fluid Waste Treatment and Disposal Equipment', 'M', '1996-02-04'),
('BPYP', '9976', 'Affluenza', '10-700 - Exterior Protection', 'R18+', '1950-03-13'),
('BQJL', '7201', 'Acacia', '2-813 - Lawn Sprinkling and Irrigation', 'M', '1975-02-07'),
('BQNL', '1481', 'The Trap', '10-700 - Exterior Protection', 'G', '2015-03-25'),
('BRDK', '4122', 'Go for Zucker! (Alles auf Zucker!)', '17 - Markup and Contingency', 'MA15+', '1983-02-11'),
('BRJL', '8225', 'Hud', '8-100 - Doors', 'M', '1996-09-15'),
('BRRB', '2871', 'Sharpe\'s Sword', '7-300 - Shingles, Roof Tiles, and Roof Coverings', 'PG', '1968-11-02'),
('BRSH', '9819', 'Pillow Book, The', '1 - General Requirements', 'G', '1999-01-29'),
('BRTB', '0128', 'The Loyal 47 Ronin', '13-550 - Transportation Control Instrumentation', 'R18+', '1960-10-01'),
('BSHL', '3071', '¡Alambrista! (Illegal, The)', '17-010 - Contingency', 'MA15+', '2005-08-31'),
('BSOQ', '5819', 'Nine Ways to Approach Helsinki (Yhdeksän tapaa lähestyä Helsinkiä)', '2-770 - Curb and Gutters', 'MA15+', '1951-11-09'),
('BSTS', '0116', 'Sällskapsresan II - Snowroller', '2-362 - Termite Control', 'MA15+', '1984-12-05'),
('BSYN', '3235', 'Enter the Dragon', '11-190 - Detention Equipment', 'G', '1980-01-14'),
('BTAX', '5830', '3 dev adam (Three Giant Men) ', '15-800 - Air Distribution', 'G', '1985-05-21'),
('BWAT', '9482', 'Lost Missile, The', '1-013 - Project Coordinator', 'R18+', '1991-08-11'),
('BWKB', '4051', 'Night to Remember, A', '7 - Thermal and Moisture Protection', 'G', '1952-09-21'),
('BWUD', '7649', 'Sleepwalkers', '10-500 - Lockers', 'R18+', '1967-02-22'),
('BWVY', '1263', 'On Earth as It Is in Heaven (Así en el cielo como en la tierra)', '2-813 - Lawn Sprinkling and Irrigation', 'M', '1984-05-09'),
('BXLS', '9539', 'Bubble Boy', '13-020 - Building Modules', 'R18+', '1965-11-02'),
('BXWR', '2853', 'Bait', '8-400 - Entrances and Storefronts', 'MA15+', '2007-03-03'),
('BYLW', '6163', 'Ex Drummer', '10-150 - Compartments and Cubicles', 'MA15+', '1970-06-10'),
('BYMX', '3804', 'Harry Potter and the Philosopher\'s Stone', 'An orphaned boy enrolls in a school of wizardry, where he learns the truth about himself, his family and the terrible evil that haunts the magical world.', 'PG', '2001-11-29'),
('BZKF', '9909', 'Lawman', '11-120 - Vending Equipment', 'R18+', '1961-02-11'),
('BZQX', '6040', 'Mr. Moto\'s Last Warning', '16-050 - Basic Electrical Materials and Methods', 'MA15+', '1958-10-23'),
('ZQDX', '7005', 'Hum Aapke Hain Koun...!', '13-100 - Lightning Protection', 'MA15+', '1966-11-07'),
('ZQJS', '3535', 'Serbian Film, A (Srpski film)', '13-260 - Sludge Conditioning Systems', 'MA15+', '2018-01-08'),
('ZRNE', '2615', 'Deadly Trackers, The', '7-300 - Shingles, Roof Tiles, and Roof Coverings', 'M', '1948-04-12'),
('ZRPQ', '9930', 'Sundays and Cybele (Les dimanches de Ville d\'Avray)', '12-100 - Art', 'M', '1948-08-26'),
('ZSAL', '9891', 'Stone', '1-000 - Purpose', 'R18+', '1971-10-01'),
('ZTUI', '8982', 'D.O.A.', '2-317 - Select Borrow', 'R18+', '1947-04-08'),
('ZUBI', '8560', 'Dangerous Beauty', '4-900 - Masonry Restoration and Cleaning', 'M', '1965-05-11'),
('ZUFR', '0718', 'Vicious Kind, The', '1-580 - Project Identification', 'MA15+', '1982-11-09'),
('ZUGE', '0648', 'Lonely Man, The', '9-800 - Acoustical Treatment', 'R18+', '2009-11-14'),
('ZVFS', '5681', 'Blue Spring (Aoi haru)', '1-903 - Hazardous Materials Abatement', 'G', '1990-09-15'),
('ZWSO', '7667', 'Smitty', '16-800 - Sound and Video', 'G', '2021-01-20'),
('ZXHG', '9777', 'No Nukes', '14-800 - Scaffolding', 'R18+', '1957-06-26'),
('ZXYI', '3953', 'Kommissarie Späck', '3 - Concrete', 'MA15+', '2021-09-07'),
('ZYCE', '3115', 'Kwik Stop', '4-800 - Masonry Assemblies', 'R18+', '2012-08-25'),
('ZYJD', '1482', 'Killjoy', '9-700 - Wall Finishes', 'PG', '2011-02-05'),
('ZZJP', '2491', 'Death Race 3: Inferno', '13-240 - Oxygenation Systems', 'R18+', '1991-05-02'),
('ZZWJ', '4853', 'First Daughter', '8-300 - Specialty Doors', 'MA15+', '1968-03-22'),
('ZZXF', '9411', 'Victory (a.k.a. Escape to Victory)', '7-100 - Damproofing and Waterproofing', 'G', '2014-06-29');


insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('188-awq-308', 'ACEH', '0941', '2019-06-06 17:25:15');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('699-kuh-297', 'BAXP', '6142', '2014-01-17 08:39:28');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('145-kup-479', 'ZXYI', '3953', '2015-04-20 18:38:53');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('485-suw-285', 'ZZXF', '9411', '2009-11-17 09:44:49');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('688-pfm-688', 'BBBK', '1814', '2007-07-01 09:05:22');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('346-nzk-382', 'BSTS', '0116', '2017-12-22 00:32:01');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('149-isy-541', 'BSOQ', '5819',  '2008-03-15 01:00:41');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('497-dpm-396', 'BRRB', '2871', '2019-04-22 01:09:59');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('399-psg-942', 'ZXYI', '3953', '2008-01-04 13:24:56');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('907-anw-514', 'ZVFS', '5681', '2010-11-28 00:29:22');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('061-meo-439', 'BPKX', '0190', '2003-08-10 22:52:36');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('134-zqa-081', 'ZZXF', '9411', '2004-03-05 10:03:38');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('907-anw-514', 'BKZF', '3788', '2019-04-16 00:44:37');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('774-ejz-507', 'ABJF', '7245', '2013-03-08 09:02:49');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('044-owi-640', 'BKVQ', '9037', '2016-08-30 08:29:16');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('751-zla-785', 'BJQA', '9391','2003-11-02 12:48:53');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('061-meo-439', 'BJOW', '9195',  '2007-05-05 17:40:51');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('689-eac-874', 'BBBK', '1814', '2019-09-15 06:46:42');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('662-xne-157','BCOI', '1663', '2012-08-23 19:52:31');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('159-zhu-507', 'BKDY', '9224', '2015-10-26 20:05:24');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('014-pms-687', 'BRSH', '9819', '2007-01-26 00:16:49');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('162-hqa-752', 'BIMW', '4328', '2000-11-29 06:23:12');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('928-kau-489', 'BKDY', '9224', '2006-04-09 12:50:53');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('894-hdc-244','BKVQ', '9037', '2009-03-18 09:02:34');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('361-nmp-751', 'ZYJD', '1482','2022-07-05 03:00:44');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('894-hdc-244', 'ZVFS', '5681','2015-06-21 00:46:51');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('951-uxm-072', 'ZYJD', '1482', '2022-09-19 09:46:36');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('648-asc-849', 'BRSH', '9819', '2007-10-10 19:23:18');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('736-mtz-051', 'BKVQ', '9037', '2012-02-06 17:40:20');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('048-tmk-454', 'BFMA', '9766','2011-03-20 11:08:43');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('738-vvc-525', 'BMNC', '8737', '2007-12-08 17:07:06');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('136-vql-065', 'BLEJ', '8881', '2022-05-19 19:02:51');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('253-ojd-858', 'BFGG', '4263', '2017-04-05 09:53:49');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('541-nlg-797', 'BRTB', '0128', '2017-08-26 07:50:50');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('756-sth-728', 'BKZF', '3788', '2005-07-13 12:08:11');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('792-bfq-394', 'ZSAL', '9891', '2021-03-01 09:03:36');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('098-vfl-325', 'BCPD', '2801','2019-12-18 08:56:51');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('191-vir-059', 'BEWF', '7753', '2020-07-15 05:11:52');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('854-vzb-038', 'BIMW', '4328', '2017-01-06 02:58:16');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('001-kgz-498', 'ZZXF', '9411', '2004-06-12 06:12:36');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('660-zxd-821', 'BKVQ', '9037', '2001-11-12 04:27:32');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('907-anw-514', 'BGQK', '3817','2019-11-07 07:47:33');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('001-kgz-498', 'BCOI', '1663', '2014-09-18 07:40:29');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('848-niu-003', 'BDWP', '8765', '2002-03-19 22:24:33');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('700-nad', 'BCOI', '1663', '2019-03-29 17:26:25');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('738-vvc-525', 'BDWP', '8765', '2010-04-09 19:20:50');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('072-gch-306', 'BLEJ', '8881', '2014-07-13 17:57:50');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('689-eac-874', 'BFMA', '9766', '2017-10-05 10:38:59');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('951-uxm-072', 'BKVQ', '9037',  '2008-08-01 09:14:36');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('792-bfq-394', 'ZZJP', '2491', '2019-08-11 05:26:59');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('674-ysu-659', 'ZZJP', '2491', '2006-06-04 03:25:02');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('379-tqa-901', 'ZZXF', '9411', '2010-07-28 16:19:30');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('488-xfr-095', 'BKZF', '3788', '2005-08-03 14:39:47');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('497-dpm-396', 'BKVQ', '9037',  '2001-05-21 20:02:23');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('335-boi-403', 'BSOQ', '5819',  '2000-04-15 07:09:02');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('689-eac-874', 'BKVQ', '9037',  '2000-10-01 03:46:34');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('529-cih-170','BKZF', '3788','2019-09-13 05:51:18');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('520-onz-868', 'BFGG', '4263', '2007-10-28 15:49:44');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('014-pms-687', 'BGQK', '3817', '2021-10-10 08:29:21');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('911-iku-076', 'BFGG', '4263','2002-09-15 21:30:53');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('564-ihr-703', 'BFMA', '9766', '2021-06-30 13:19:36');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('756-sth-728', 'BCPD', '2801','2004-03-07 18:12:30');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('346-nzk-382', 'ZZJP', '2491', '2012-05-11 22:51:46');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('648-asc-849', 'BNKZ', '5558', '2001-02-02 16:55:50');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('238-ntw-925', 'BRJL', '8225', '2003-10-07 18:27:33');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('134-zqa-081', 'BRRB', '2871', '2004-02-11 19:57:35');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('833-gzw-944', 'AKFW', '1016','1999-05-31 09:50:25');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('762-ywh-585', 'BKVQ', '9037', '2011-05-27 05:45:29');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('399-psg-942', 'ALAS', '5790', '2008-11-20 11:10:24');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('310-cqn-446', 'BPKX', '0190', '2001-09-16 19:58:55');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('136-vql-065', 'BCPD', '2801','2021-08-17 18:39:31');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('538-ncr-647', 'BCOI', '1663', '2004-10-28 01:04:39');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('061-meo-439', 'ZZWJ', '4853', '2020-07-30 02:01:29');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('911-iku-076', 'BGAN', '7893', '2014-10-14 09:27:40');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('792-bfq-394', 'BFMA', '9766', '2011-12-20 17:14:13');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('497-dpm-396', 'ZZJP', '2491', '2014-07-04 10:45:25');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('688-pfm-688', 'AMJD', '5770', '2012-06-12 12:50:26');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('340-igt-367', 'ZYCE', '3115', '2006-08-28 15:15:03');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('335-boi-403','BZQX', '6040', '2002-06-22 07:06:24');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('774-ejz-507', 'BZKF', '9909','2018-07-27 14:28:00');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('538-ncr-647', 'BYMX', '3804', '2015-04-18 23:36:28');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('257-dwu-165', 'AMPO', '8227', '2012-10-07 19:10:16');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('730-ldf-468', 'BYLW', '6163', '2007-09-02 10:19:03');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('001-kgz-498', 'BXWR', '2853',  '2018-06-16 04:25:17');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('848-niu-003', 'ZYJD', '1482', '2014-12-19 04:20:02');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('564-ihr-703', 'ZYCE', '3115',  '2009-03-12 04:25:45');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('980-sgv-254', 'ZYCE', '3115', '2005-10-13 17:09:06');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('951-uxm-072','AJUH', '0291', '2014-04-14 21:49:54');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('340-igt-367', 'AKFF', '6623','2001-07-11 06:11:00');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('485-suw-285', 'AKFW', '1016', '2013-10-04 06:25:39');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('677-mef-089', 'ZUGE', '0648', '2019-01-02 08:19:00');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('162-hqa-752','ZUFR', '0718', '2006-07-16 13:23:55');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('014-pms-687', 'BFMA', '9766',  '2011-02-04 06:09:19');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('730-ldf-468', 'ZYCE', '3115', '2015-10-05 07:17:49');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('998-zyp-523', 'BXLS', '9539', '2003-11-01 18:02:31');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('677-mef-089', 'BZQX', '6040','2015-07-21 12:22:30');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('964-rzz-277', 'BAAA', '7596', '1999-01-05 21:16:19');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('399-psg-942', 'ZUGE', '0648', '2011-03-04 12:02:53');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('162-hqa-752', 'ZQDX', '7005', '2006-08-08 06:03:17');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('165-pjg-471', 'ZVFS', '5681', '2006-02-09 19:37:19');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('688-pfm-688', 'BRJL', '8225', '2018-05-08 08:14:23');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('001-kgz-498','ACEH', '0941', '2013-02-26 04:02:28');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('854-vzb-038', 'ADEU', '6883', '2022-03-05 01:11:36');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('145-kup-479', 'BWVY', '1263','2014-06-18 12:52:44');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('928-kau-489', 'AIRK', '5532', '2002-06-14 12:05:45');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('238-ntw-925', 'BXLS', '9539', '2016-02-06 20:30:53');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('461-fib-609','BRDK', '4122', '2003-10-19 21:56:25');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('145-kup-479', 'BNKZ', '5558','2013-12-15 14:13:07');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('564-ihr-703', 'BMVD', '2108', '2008-08-29 07:26:41');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('964-rzz-277', 'ZZJP', '2491', '2021-02-14 02:02:16');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('470-mre-229', 'ZRNE', '2615', '2012-09-27 04:48:25');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('253-ojd-858', 'BWUD', '7649','2006-11-05 23:55:15');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('688-pfm-688', 'ZUFR', '0718', '2019-01-07 12:07:09');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('753-jlx-238', 'ZRNE', '2615', '2021-10-02 07:59:44');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('648-asc-849', 'ZRNE', '2615', '2002-10-08 09:56:06');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('660-zxd-821', 'BWUD', '7649','2015-06-03 11:37:13');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('730-ldf-468', 'AMPO', '8227', '2021-02-21 16:56:29');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('762-ywh-585', 'BWKB', '4051', '2016-09-29 21:17:19');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('106-bjs-091', 'BRDK', '4122', '2017-06-12 18:48:05');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('340-igt-367', 'BLEJ', '8881', '2012-11-08 23:33:46');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('894-hdc-244', 'AUZZ', '4505','2003-08-07 01:22:45');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('297-dla-907', 'AUDR', '5657', '2005-04-29 17:15:54');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('854-vzb-038', 'APFB', '7635', '2017-03-17 07:45:11');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('478-yjr-076', 'AUPL', '3736',  '2002-09-13 01:09:19');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('461-fib-609','BWUD', '7649', '2020-07-23 05:33:57');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('001-kgz-498','BWKB', '4051', '2022-02-18 09:39:26');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('044-owi-640', 'BWAT', '9482', '2021-11-25 11:26:45');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('833-gzw-944', 'AVDD', '6490', '2020-12-30 00:21:39');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('730-ldf-468', 'ARIS', '7076', '2015-01-25 23:03:20');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('919-adw-261', 'AVOI', '6834','2014-10-22 07:25:04');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('699-kuh-297', 'ZUGE', '0648', '2015-11-20 07:51:22');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('984-wwy-346', 'BSOQ', '5819', '2015-04-20 08:11:31');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('564-ihr-703', 'BSHL', '3071', '1999-10-14 16:41:35');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('894-hdc-244', 'BQNL', '1481', '2021-06-27 10:23:42');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('478-yjr-076','ZUGE', '0648', '2018-05-24 15:09:16');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('142-flp-971', 'BWUD', '7649', '2018-05-31 20:32:41');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('488-xfr-095', 'BKVQ', '9037', '1999-02-25 09:26:12');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('162-hqa-752', 'ZZJP', '2491','2007-08-23 20:10:14');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('238-ntw-925', 'AJUH', '0291', '2001-05-31 16:40:49');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('949-zjg-539', 'AMPO', '8227', '2018-11-29 03:02:57');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('257-dwu-165', 'APFB', '7635', '2001-03-31 13:30:04');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('688-pfm-688', 'BQNL', '1481', '2022-09-11 09:01:23');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('688-pfm-688', 'BTAX', '5830', '2020-10-17 21:53:19');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('688-pfm-688', 'BWAT', '9482', '2005-08-10 19:19:05');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('191-vir-059', 'AIRK', '5532', '2019-07-15 10:41:18');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('488-xfr-095', 'AJIB', '5561', '2020-02-29 03:57:30');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('057-zhi-627', 'AJUH', '0291', '2008-10-09 09:04:30');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('162-hqa-752','AKFF', '6623', '2005-07-17 23:53:17');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('836-ymi-756', 'BFGG', '4263', '2020-01-14 06:20:33');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('648-asc-849', 'BQJL', '7201', '2002-11-21 06:43:32');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('564-ihr-703', 'ZRNE', '2615', '2010-02-27 07:10:45');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('149-isy-541', 'BTAX', '5830', '2009-03-01 15:18:19');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('520-onz-868', 'ZSAL', '9891', '2001-12-26 12:53:39');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('335-boi-403', 'AGBL', '3689', '2008-12-30 15:12:07');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('751-zla-785', 'ZQJS', '3535', '2008-03-22 17:51:08');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('688-pfm-688', 'ABJF', '7245', '2008-11-22 12:30:48');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('048-tmk-454', 'ZQDX', '7005','2009-07-09 21:40:04');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('107-btc-275', 'BSYN', '3235', '1999-03-03 01:04:41');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('379-tqa-901', 'BKRJ', '0565', '2015-04-16 07:30:46');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('346-nzk-382', 'AGBL', '3689', '2007-06-21 02:34:57');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('751-zla-785', 'BSHL', '3071', '2018-10-27 13:30:31');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('057-toq-736', 'AMPO', '8227', '2020-07-20 07:24:58');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('688-pfm-688', 'AVOI', '6834','2019-06-28 23:19:45');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('106-bjs-091', 'BSYN', '3235','2019-08-22 21:21:15');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('485-suw-285', 'APFB', '7635', '2015-09-09 13:00:04');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('919-adw-261', 'ANFY', '9323', '2000-04-03 13:56:24');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('057-toq-736', 'AVSD', '4423',  '2013-09-16 12:34:34');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('072-gch-306', 'ZQJS', '3535', '2010-01-24 03:48:35');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('662-xne-157', 'BPYP', '9976', '2003-04-15 16:59:42');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('728-zfa-701', 'AWNI', '7777', '2007-12-30 23:00:10');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('911-iku-076', 'ZQDX', '7005', '2018-09-30 18:55:54');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('257-dwu-165', 'ZZJP', '2491', '2006-04-18 03:32:51');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('774-ejz-507', 'AEHF', '3027', '2008-10-08 07:50:07');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('588-nmx-784', 'ZZWJ', '4853', '2010-11-11 22:31:57');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('335-boi-403', 'ZZWJ', '4853', '2003-03-08 20:48:59');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('751-zla-785', 'BZQX', '6040',  '2018-11-23 03:37:52');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('165-pjg-471', 'BAAA', '7596','2010-03-06 13:57:47');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('188-awq-308', 'BPUU', '6137',  '2002-06-14 17:56:35');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('392-uhz-406', 'BMNC', '8737', '2010-07-01 21:42:20');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('984-wwy-346', 'BMBL', '0249',  '2018-10-25 07:03:56');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('072-gch-306', 'ZSAL', '9891', '2022-07-23 17:33:26');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('001-kgz-498', 'BMVD', '2108', '2011-02-08 18:33:53');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('998-zyp-523','BFGG', '4263', '2013-08-03 23:13:22');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('346-nzk-382', 'BRTB', '0128', '2008-03-10 01:37:33');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('162-hqa-752', 'BLEJ', '8881', '2013-04-06 07:39:55');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('529-cih-170', 'BKRJ', '0565', '2001-09-30 04:09:58');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('340-igt-367', 'BKPU', '4838', '1999-08-07 00:56:12');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('564-ihr-703', 'BPUU', '6137',  '2005-05-21 21:44:16');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('145-kup-479', 'BMNC', '8737', '2005-06-12 17:44:48');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('688-pfm-688', 'BKPU', '4838','2009-02-03 13:50:28');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('485-suw-285', 'BMBL', '0249',  '2000-03-30 13:13:58');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('044-owi-640', 'BSHL', '3071','2004-01-16 09:45:16');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('688-pfm-688', 'BAAA', '7596', '2009-01-10 20:45:27');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('165-pjg-471','AKFW', '1016', '2011-04-30 14:11:46');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('107-btc-275', 'ALAS', '5790', '2006-01-16 17:06:14');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('664-vvt-091', 'ZQDX', '7005', '2020-12-19 00:26:16');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('497-dpm-396', 'BZQX', '6040', '2000-11-20 19:38:58');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('677-mef-089', 'BRTB', '0128', '2006-07-27 10:06:13');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('067-anp-920', 'BKDY', '9224', '2009-10-13 22:49:24');
insert into Previews (customer, moviePrefix, movieSuffix, timestamp) values ('191-gvc-966', 'BJQA', '9391', '2007-09-30 23:28:39');




insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('001-kgz-498', 'BPYP', '9976', '2021-02-21 19:25:24', 7087);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('520-onz-868', 'BKZF', '3788', '2021-08-11 17:14:14', 835);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('984-wwy-346', 'ZZJP', '2491', '2004-05-18 03:13:47', 5115);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('253-ojd-858', 'BWUD', '7649', '2008-07-02 20:25:09', 9860);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('136-vql-065', 'BKZF', '3788', '2016-11-13 01:36:44', 3466);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('188-awq-308', 'BKZF', '3788', '1999-09-18 01:03:54', 1015);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('392-uhz-406', 'AVOI', '6834', '2021-11-18 07:05:04', 8011);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('069-eid-493', 'ZRNE', '2615', '2015-02-17 13:58:35', 203);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('911-iku-076', 'BLEJ', '8881','2015-08-13 00:19:23', 3391);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('106-bjs-091', 'BPYP', '9976', '2003-08-24 22:48:33', 7974);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('699-kuh-297','BMVD', '2108','2002-10-06 15:23:45', 9360);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('335-boi-403', 'BSOQ', '5819', '2002-03-31 17:50:54', 7834);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('756-sth-728', 'BSTS', '0116','2010-10-25 01:53:41', 2122);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('379-tqa-901', 'ZQJS', '3535', '2007-04-28 07:14:16', 8364);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('529-cih-170','ZUBI', '8560', '2020-08-19 18:36:45', 5618);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('674-ysu-659', 'BBFE', '6191',  '2021-01-13 19:37:43', 3790);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('484-ogz-688', 'BBXG', '1968', '1999-01-28 15:25:49', 5224);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('134-zqa-081', 'ZTUI', '8982','2019-02-11 18:17:27', 8509);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('541-nlg-797', 'ZUBI', '8560', '2017-10-05 09:30:03', 3496);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('854-vzb-038', 'BCOI', '1663',  '2011-08-10 07:30:27', 6102);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('470-mre-229', 'BAXP', '6142', '2002-11-29 06:38:27', 2103);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('484-ogz-688', 'BCFE', '8180', '2000-05-10 23:53:47', 8302);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('072-gch-306', 'BBFE', '6191',  '2011-09-01 19:20:24', 6830);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('529-cih-170', 'BBBK', '1814', '2022-04-07 10:22:14', 4209);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('535-xbq-689', 'AVOI', '6834', '2017-10-05 15:31:22', 2043);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('022-wuc-936', 'ZRNE', '2615', '2010-08-02 06:04:21', 9099);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('854-vzb-038', 'ZUGE', '0648', '2017-07-06 19:09:56', 6588);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('588-nmx-784', 'BCPD', '2801', '2004-10-06 23:38:34', 7711);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('145-kup-479', 'ZUFR', '0718', '2018-06-26 03:58:45', 906);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('057-zhi-627', 'ZUFR', '0718', '2004-12-17 15:54:48', 1685);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('399-psg-942', 'BAAA', '7596', '2017-09-27 02:09:40', 9240);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('346-nzk-382', 'ZUGE', '0648', '2006-08-28 19:51:35', 9535);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('159-zhu-507', 'BAXP', '6142','1999-09-03 05:18:21', 8787);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('397-oui-372', 'BLEJ', '8881', '2022-05-24 09:36:10', 2997);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('136-vql-065', 'AUZZ', '4505','2012-09-20 17:05:17', 2163);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('738-lzs-935', 'ZYCE', '3115', '2010-12-30 22:57:52', 5707);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('485-suw-285', 'ZVFS', '5681',  '2020-02-16 18:43:22', 8506);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('188-awq-308', 'ZWSO', '7667', '2021-02-02 22:04:42', 6167);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('738-lzs-935', 'ZXHG', '9777', '2019-03-23 09:54:37', 4097);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('044-owi-640', 'ZXYI', '3953', '2006-07-04 15:42:16', 8730);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('188-awq-308', 'BAAA', '7596', '2006-09-29 01:01:05', 3903);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('057-toq-736', 'AZFT', '0236', '2002-07-31 14:57:38', 4794);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('061-meo-439', 'ZYCE', '3115', '2001-02-06 10:07:53', 3842);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('044-owi-640', 'ZYJD', '1482',  '2008-01-08 07:40:59', 7687);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('191-gvc-966', 'ZZJP', '2491', '2019-10-30 12:30:59', 4177);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('361-nmp-751','ZZWJ', '4853','2005-11-10 15:45:55', 2150);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('014-pms-687', 'ZZWJ', '4853', '1999-04-14 01:10:08', 4598);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('022-wuc-936', 'BDJX', '4600',  '2001-02-17 05:20:56', 7099);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('564-ihr-703', 'BCPD', '2801', '2009-05-31 10:07:39', 5903);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('067-anp-920', 'ZZJP', '2491', '2011-07-19 16:08:38', 7913);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('057-zhi-627','BCRU', '8105', '1999-10-17 11:51:36', 9370);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('848-niu-003', 'ZZXF', '9411', '2010-01-05 11:49:23', 2668);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('728-zfa-701', 'BDNA', '7116','2019-10-18 14:32:06', 7649);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('057-zhi-627', 'BDKV', '4154','2012-08-19 17:20:25', 1012);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('257-dwu-165', 'ZZJP', '2491', '2013-05-19 12:16:00', 1554);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('257-dwu-165', 'ZUGE', '0648', '2021-12-07 20:06:19', 8484);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('188-awq-308',  'BSOQ', '5819', '2006-03-23 08:01:35', 2845);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('254-qjq-328', 'BDJX', '4600',  '2015-12-31 07:36:19', 9957);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('894-hdc-244', 'BKVQ', '9037', '2019-11-06 18:48:52', 1925);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('470-mre-229','BFMA', '9766',  '2000-05-19 18:16:16', 6285);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('461-fib-609', 'BFGG', '4263', '2019-10-05 08:22:29', 2596);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('191-gvc-966', 'BEWF', '7753', '2019-11-29 18:43:38', 8660);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('738-vvc-525','BDWP', '8765', '2012-04-18 22:40:44', 3177);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('346-nzk-382', 'BDOW', '0505', '2000-04-08 20:11:07', 627);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('677-mef-089', 'BDNA', '7116', '2014-06-17 05:15:23', 5941);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('921-rox-723', 'AUZZ', '4505', '2003-05-24 20:29:20', 3952);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('257-dwu-165', 'AUDR', '5657', '2022-01-29 14:17:13', 8221);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('254-qjq-328', 'AUDR', '5657', '2012-11-01 00:00:16', 5057);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('741-qyq-244', 'AUPL', '3736',  '2009-01-25 14:27:32', 8553);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('854-vzb-038',  'BSOQ', '5819', '2004-02-07 13:02:41', 6986);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('238-ntw-925', 'BSHL', '3071', '2006-12-09 00:17:58', 8897);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('674-ysu-659','AVVY', '0658', '2003-12-03 09:37:18', 1850);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('774-ejz-507','BKDY', '9224', '2012-01-08 06:03:18', 1858);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('751-zla-785', 'BKPU', '4838', '2013-12-05 06:17:11', 1096);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('361-nmp-751','BKRJ', '0565', '2009-04-06 19:52:31', 4587);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('310-cqn-446', 'BKPU', '4838','2004-08-24 03:44:04', 8107);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('593-ymt-349', 'AWNI', '7777', '2009-04-03 12:45:33', 4280);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('674-ysu-659', 'AWCB', '0302', '1999-09-29 13:09:23', 3429);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('136-vql-065','ZZJP', '2491', '2012-10-23 01:36:23', 451);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('936-nbm-141', 'AXGI', '2905','2003-11-14 16:16:39', 7811);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('660-gnc-951', 'AXUZ', '5250', '2021-08-10 09:18:45', 3701);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('361-nmp-751', 'BFMA', '9766',  '2018-07-24 09:39:23', 216);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('585-hyw-659', 'BGQK', '3817',  '2015-05-07 17:07:36', 2567);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('529-cih-170', 'BIMW', '4328', '2004-08-14 19:57:45', 7399);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('593-ymt-349', 'BJOW', '9195','2001-06-04 05:19:31', 5004);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('936-nbm-141', 'AWCB', '0302', '2002-02-21 09:38:25', 368);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('106-bjs-091','BJQA', '9391', '2001-09-15 17:32:38', 8764);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('014-pms-687', 'BJQA', '9391', '2018-04-23 21:24:00', 2828);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('736-mtz-051', 'BGQK', '3817',  '2018-07-02 21:15:55', 5680);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('014-pms-687','BGAN', '7893', '2017-10-26 08:07:32', 1962);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('399-psg-942', 'BGAN', '7893', '2005-01-29 07:05:59', 7711);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('485-suw-285', 'AYRS', '6381', '2017-06-02 09:03:32', 1707);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('836-ymi-756', 'AXUZ', '5250', '2020-11-11 03:46:52', 7132);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('399-psg-942', 'ZRNE', '2615', '2018-04-03 17:37:15', 8615);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('836-ymi-756', 'AUPL', '3736',  '2021-05-17 06:13:47', 5384);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('470-mre-229', 'AUPL', '3736',  '2018-03-01 02:46:34', 8579);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('149-isy-541', 'BWUD', '7649', '2013-09-22 22:57:40', 6742);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('098-vfl-325', 'BFMA', '9766',  '1999-06-07 08:49:43', 1226);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('751-zla-785', 'AZFT', '0236', '2019-02-15 10:25:13', 1260);
insert into Streams (customer, moviePrefix, movieSuffix, timestamp, duration) values ('057-toq-736', 'AYRS', '6381', '2008-12-03 03:02:38', 6010);





--
-- Indexes for table `Customer`
--
ALTER TABLE `Customer`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bestFriend` (`bestFriend`),
  ADD KEY `CustomerSubscriptionFK` (`subscriptionLevel`);

--
-- Indexes for table `Movie`
--
ALTER TABLE `Movie`
  ADD PRIMARY KEY (`prefix`,`suffix`);

--
-- Indexes for table `Previews`
--
ALTER TABLE `Previews`
  ADD PRIMARY KEY (`customer`,`moviePrefix`,`movieSuffix`),
  ADD KEY `moviePrefix` (`moviePrefix`,`movieSuffix`);

--
-- Indexes for table `Streams`
--
ALTER TABLE `Streams`
  ADD PRIMARY KEY (`customer`,`moviePrefix`,`movieSuffix`,`timestamp`),
  ADD KEY `moviePrefix` (`moviePrefix`,`movieSuffix`);

--
-- Indexes for table `Subscription`
--
ALTER TABLE `Subscription`
  ADD PRIMARY KEY (`level`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Customer`
--
ALTER TABLE `Customer`
  ADD CONSTRAINT `Customer_ibfk_1` FOREIGN KEY (`bestFriend`) REFERENCES `Customer` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `CustomerSubscriptionFK` FOREIGN KEY (`subscriptionLevel`) REFERENCES `Subscription` (`level`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `Previews`
--
ALTER TABLE `Previews`
  ADD CONSTRAINT `Previews_ibfk_1` FOREIGN KEY (`customer`) REFERENCES `Customer` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Previews_ibfk_2` FOREIGN KEY (`moviePrefix`,`movieSuffix`) REFERENCES `Movie` (`prefix`, `suffix`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `Streams`
--
ALTER TABLE `Streams`
  ADD CONSTRAINT `Streams_ibfk_1` FOREIGN KEY (`customer`) REFERENCES `Customer` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Streams_ibfk_2` FOREIGN KEY (`moviePrefix`,`movieSuffix`) REFERENCES `Movie` (`prefix`, `suffix`) ON DELETE RESTRICT ON UPDATE CASCADE;
COMMIT;


