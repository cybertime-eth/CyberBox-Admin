namespace :cron_jobs do
    desc 're-calculate every updated NFTs'
    task recalc_updatenfts: :environment do
        helper.cronJobRefreshing()
    end
end