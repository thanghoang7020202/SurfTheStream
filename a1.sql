CREATE TABLE MovieEmployee (
	moviePrefix VARCHAR(4) NOT NULL,
	movieSuffix VARCHAR(4) NOT NULL,
	employeeName VARCHAR(100) NOT NULL,
	role ENUM('Actor','Production','Other') NOT NULL,
  	startDate DATE NULL,
	PRIMARY KEY(moviePrefix, movieSuffix, employeeName, role),
	FOREIGN KEY (moviePrefix, movieSuffix) REFERENCES Movie(prefix, suffix) ON UPDATE CASCADE ON DELETE RESTRICT
);
