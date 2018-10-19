#!/bin/bash
IP=172.18.18.119
PORT=4000
COUNT=20
 mysql -u root -h ${IP} -P ${PORT} << EOF
use people;

#新增
INSERT INTO people.t_people_new (peopleid, community, month, deviceid, isconfirm, flag)
SELECT new.peopleid, new.community ,new.time, new.deviceid, 1, new.flag
FROM(
SELECT peopleid, community, DATE_FORMAT(capturetime ,'%Y%m') AS time,deviceid, 1, flag
FROM people.t_people_recognize
WHERE flag = 2 AND DATE_FORMAT(capturetime ,'%Y%m') =DATE_FORMAT(DATE_SUB(NOW(),INTERVAL 1 MONTH),'%Y%m')
GROUP BY peopleid, deviceid
HAVING COUNT(peopleid) >=${COUNT} AND COUNT(deviceid)>=${COUNT}
)AS new ,t_people_recognize WHERE new.peopleid=t_people_recognize.peopleid AND t_people_recognize.flag=10;
#实名
INSERT INTO people.t_people_new (peopleid,month,deviceid,isconfirm,flag)
SELECT peopleid,DATE_FORMAT(capturetime ,'%Y%m') ,deviceid,1,flag
FROM t_people_recognize AS pr
WHERE pr.flag = 1 AND DATE_FORMAT(capturetime ,'%Y%m')=DATE_FORMAT(DATE_SUB(NOW(),INTERVAL 1 MONTH),'%Y%m')
GROUP BY peopleid, deviceid
HAVING COUNT(peopleid) >=${COUNT} AND COUNT(deviceid)>=${COUNT};
EOF
