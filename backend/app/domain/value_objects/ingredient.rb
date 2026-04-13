# frozen_string_literal: true

module ValueObjects
  class Ingredient
    attr_reader :name, :amount, :unit

    def initialize(name:, amount:, unit:)
      @name   = name.to_s.strip
      @amount = amount.to_f
      @unit   = unit.to_s.strip
      freeze
    end

    def ==(other)
      other.is_a?(Ingredient) &&
        name == other.name &&
        amount == other.amount &&
        unit == other.unit
    end

    alias eql? ==

    def hash
      [name, amount, unit].hash
    end

    def to_s
      unit.empty? ? "#{amount} #{name}" : "#{amount} #{unit} #{name}"
    end
  end
end
