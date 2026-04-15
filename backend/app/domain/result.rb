# frozen_string_literal: true

Result = Struct.new(:success?, :value, :error, keyword_init: true)
