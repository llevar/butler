run_tracking_db_name: run_tracking
run_tracking_db_url: postgresql://{{ pillar['postgres.user'] }}:{{ pillar['postgres.password'] }}@{{ pillar['postgres.host'] }}:{{ pillar['postgres.port'] }}/pillar['run_tracking_db_name']