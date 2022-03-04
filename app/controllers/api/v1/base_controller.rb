# frozen_string_literal: true

module Api
    module V1
      class BaseController < ApplicationController
        protect_from_forgery with: :null_session


        def render_presenters(entities, klass = nil)
          klass ||= entities.first.class
          klass = klass.to_s
          data  = {
            klass.underscore.pluralize.to_sym =>
              entities.map do |entity|
                "#{klass}Presenter".constantize.new(
                  presenter_data(entity)
                ).to_h
              end
          }
          # Rails.logger.ap(data) if Rails.env.development?
          render json: data
        end

        def presenter_data(entity)
          { model: entity }
        end
      end
    end
end