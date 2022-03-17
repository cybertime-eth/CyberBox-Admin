namespace :cron_jobs do
    desc 're-calculate every updated NFTs'
    task recalc_updatenfts: :environment do
        Rails.logger.info('[CRON_JOB:CHECK_NFTS START]')
        contract = Contract.first
        contract.contractCronFetch()
        Rails.logger.info('[CRON_JOB:CHECK_NFTS END]')
    end
end