#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

# == Schema Information
#
# Table name: event_participations
#
#  id                     :integer          not null, primary key
#  active                 :boolean          default(FALSE), not null
#  additional_information :text(65535)
#  qualified              :boolean
#  created_at             :datetime
#  updated_at             :datetime
#  application_id         :integer
#  event_id               :integer          not null
#  person_id              :integer          not null
#
# Indexes
#
#  index_event_participations_on_application_id          (application_id)
#  index_event_participations_on_event_id                (event_id)
#  index_event_participations_on_event_id_and_person_id  (event_id,person_id) UNIQUE
#  index_event_participations_on_person_id               (person_id)
#

Fabricator(:event_participation, class_name: 'Event::Participation') do
  person
  event
end
