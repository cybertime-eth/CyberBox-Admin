namespace :cron_jobs do
    desc 're-calculate every updated NFTs'
    task recalc_updatenfts: :environment do
        Rails.logger.info('[CRON_JOB:CHECK_NFTS START]')
        ApplicationController.helpers.cronJobRefreshing()
        Rails.logger.info('[CRON_JOB:CHECK_NFTS END]')
    end
end