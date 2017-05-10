# Perform sed substitutions on `postgresql.conf`
s/shared_buffers = 128MB/shared_buffers = 256MB/
s/#max_wal_size = 1GB/max_wal_size = 4GB/
s/#work_mem = 4MB/work_mem = 64MB/
s/#maintenance_work_mem = 64MB/maintenance_work_mem = 512MB/
