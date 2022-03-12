# frozen_string_literal: true

# Copyright (c) 2021, hitobito AG. This file is part of
# hitobito and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https ://github.com/hitobito/hitobito.

class AddTwoFactorAuthenticationAttrsToPerson < ActiveRecord::Migration[6.0]
  def change
    add_column :people, :two_factor_authentication, :integer, null: true
    add_column :people, :encrypted_two_fa_secret, :text, limit: 300, null: true
  end
end
