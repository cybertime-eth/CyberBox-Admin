class Contract < ApplicationRecord

    def contractCronFetch
        helper.cronJobRefreshing()
    end
end