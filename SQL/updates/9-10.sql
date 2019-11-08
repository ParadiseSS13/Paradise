#Updating the SQL from version 9 to version 10. -t0epic4u
#Adding new table for enhanced ban evasion detection
#Adding ckey as the PK and boolean for logic in the code

CREATE TABLE `high_risk` (
  `ckey` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE `high_risk`
  ADD PRIMARY KEY (`ckey`);
COMMIT; 