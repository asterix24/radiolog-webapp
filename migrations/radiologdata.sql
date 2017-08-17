-- 1 up
create table if not exists radiologdata (
  id            serial primary key,
  label         text,
  description   text,
  address       int,
  timestamp     timestamp,
  lqi           int,
  rssi          int,
  uptime        timestamp,
  tempcpu       int,
  vrefcpu       int,
  ntc0          int,
  ntc1          int,
  photores      int,
  pressure      int,
  temppressure  int
);

-- 1 down
drop table if exists radiologdata;
