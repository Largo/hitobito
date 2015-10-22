# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

if Settings.email.retriever.config.present?
  Mail.defaults do
    retriever_method(Settings.email.retriever.type.to_sym,
                     Settings.email.retriever.config.to_hash)
  end
end
