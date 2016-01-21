# Lita-related code
module Lita
  # Plugin-related code
  module Handlers
    # Resolve-related routes
    class PagerdutyResolve < Handler
      namespace 'Pagerduty'

      include ::PagerdutyHelper::Incident
      include ::PagerdutyHelper::Regex
      include ::PagerdutyHelper::Utility

      route(
        /^pager\sresolve\sall$/,
        :resolve_all,
        command: true,
        help: {
          t('help.resolve_all.syntax') => t('help.resolve_all.desc')
        }
      )

      route(
        /^pager\sresolve\smine$/,
        :resolve_mine,
        command: true,
        help: {
          t('help.resolve_mine.syntax') => t('help.resolve_mine.desc')
        }
      )

      route(
        /^pager\sresolve\s#{INCIDENT_ID_PATTERN}$/,
        :resolve,
        command: true,
        help: {
          t('help.resolve.syntax') => t('help.resolve.desc')
        }
      )

      # rubocop:disable Metrics/AbcSize
      def resolve_all(response)
        incidents = fetch_all_incidents
        return response.reply(t('incident.none')) unless incidents.count > 0
        completed = []
        incidents.each do |incident|
          result = resolve_incident(incident.id)
          completed.push(incident.id) if result == "#{incident.id}: Incident resolved"
          response.reply(t('all.resolved', list: completed.join(',')))
        end
      end
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/AbcSize
      def resolve_mine(response)
        email = fetch_user(response.user)
        return response.reply(t('identify.missing')) unless email
        incidents = fetch_my_incidents(email)
        return response.reply(t('incident.none_mine')) unless incidents.count > 0
        completed = []
        incidents.each do |incident|
          result = resolve_incident(incident.id)
          completed.push(incident.id) if result == "#{incident.id}: Incident resolved"
          response.reply(t('all.resolved', list: completed.join(',')))
        end
      end
      # rubocop:enable Metrics/AbcSize

      def resolve(response)
        incident_id = response.match_data['incident_id']
        return if incident_id == 'all' || incident_id == 'mine'
        response.reply(resolve_incident(incident_id))
      end
    end

    Lita.register_handler(PagerdutyResolve)
  end
end
