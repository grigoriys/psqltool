#!/bin/bash
#
#
#
runsql()
 {
   SASPQUERY="update settings set value = $1 where id in 
           (select s.id from settings s left outer join customer_settings cs on cs.setting_id = s.id,
           (select cs.parent_id, s.name, s.value from settings s left outer join customer_settings cs on cs.setting_id = s.id) login
            where login.value = $2
            and (cs.parent_id = login.parent_id or
           (cs.parent_id is null and login.parent_id is null))
           and ((login.name = 0 and s.name = 2) or
           (login.name = 22 and s.name = 23) or
           (login.name = 51 and s.name = 52) or
           (login.name = 70 and s.name = 71)
));
"
echo ${SASPQUERY}
}