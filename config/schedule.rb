every 1.hour do
    rake "cron_jobs:recalc_updatenfts"
  end