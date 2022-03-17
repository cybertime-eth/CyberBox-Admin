class Contract < ApplicationRecord

    def contractCronFetch
        helpers.cronJobRefreshing()
    end
end