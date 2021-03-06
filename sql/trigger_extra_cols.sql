-- this functionality is deprecated

\set VERBOSITY 'terse'
set client_min_messages = 'warning';

create or replace function pgq.insert_event(queue_name text, ev_type text, ev_data text, ev_extra1 text, ev_extra2 text, ev_extra3 text, ev_extra4 text)
returns bigint as $$
begin
    raise warning 'insert_event(q=[%], t=[%], d=[%], 1=[%], 2=[%], 3=[%], 4=[%])',
        queue_name, ev_type, ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4;
    return 1;
end;
$$ language plpgsql;

create table trigger_extra_columns (nr int4 primary key, col1 text, col2 text,
    _pgq_ev_type text, _pgq_ev_extra1 text, _pgq_ev_extra2 text default 'e2',
    _pgq_ev_extra3 text default 'e3', _pgq_ev_extra4 text default 'e4');

create trigger extra_trig_0 after insert or update or delete on trigger_extra_columns
for each row execute procedure pgq.jsontriga('jsontriga');
create trigger extra_trig_1 after insert or update or delete on trigger_extra_columns
for each row execute procedure pgq.logutriga('logutriga');
create trigger extra_trig_2 after insert or update or delete on trigger_extra_columns
for each row execute procedure pgq.sqltriga('sqltriga');

-- test insert
insert into trigger_extra_columns (nr, col1, col2, _pgq_ev_type, _pgq_ev_extra1) values (1, 'col1', 'col2', 'xt', 'E1');

-- test update
update trigger_extra_columns set col1 = 'col1x', col2='col2x', _pgq_ev_extra1='X1'  where nr=1;

-- test delete
delete from trigger_extra_columns where nr=1;

-- restore
drop table trigger_extra_columns;
\set ECHO none
\i functions/pgq.insert_event.sql

