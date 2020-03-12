USE quiz;

DROP PROCEDURE IF EXISTS comparetable;
DELIMITER //
CREATE PROCEDURE comparetable()
BEGIN
DECLARE Mtime DATETIME;
DECLARE MRequestor VARCHAR(20);
DECLARE MRole VARCHAR(20);
DECLARE MComponent VARCHAR(20);
DECLARE MRequest_type VARCHAR(20);
DECLARE MViolation_type VARCHAR(20);
DECLARE MScore VARCHAR(20);

DECLARE ORows INT; 
DECLARE AB INT; 
DECLARE Counter1 INT;

DECLARE Model CURSOR FOR
		 	SELECT Time, Requestor, Role, Component, Request_Type, Violation_Type, Score
			FROM model
            WHERE Score = 'TRUE';
                        

SET Counter1 = 0;

OPEN Model;
	select found_rows() into ORows;
	O_Loop: LOOP
		IF Counter1 < ORows THEN
			FETCH Model INTO Mtime, MRequestor, MRole, MComponent, MRequest_type, MViolation_type, MScore;
				select count(*) into AB from access_rule
					where ID = MRequestor and Role = MRole and Component = MComponent
						and Request_Type = MRequest_type and (cast(Mtime as time) between Allowed_Start_Time AND Allowed_End_Time);
					
			IF AB < 1 THEN
				INSERT INTO discrepancies values (Mtime, MRequestor, MRole, MComponent, MRequest_type, MViolation_type, MScore);
                DELETE FROM model WHERE Time = Mtime;
			END IF;
				SET Counter1 = Counter1 + 1;
		ELSE
					LEAVE O_Loop;
		END IF;
	END LOOP ;
CLOSE Model;
END//
DELIMITER ;

call comparetable();