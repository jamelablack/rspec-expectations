module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the implementation for `have_attributes`.
      # Not intended to be instantiated directly.
      class HaveAttributes < BaseMatcher
        # @private
        attr_reader :respond_to_failed

        def initialize(expected)
          @expected = expected
          @values = {}
          @respond_to_failed = false
        end

        # @api private
        # @return [Boolean]
        def matches?(actual)
          @actual = actual
          @negated = false
          return false unless respond_to_attributes?
          perform_match(:all?)
        end

        # @api private
        # @return [Boolean]
        def does_not_match?(actual)
          @actual = actual
          return false unless respond_to_attributes?
          perform_match(:none?)
        end

        # @api private
        # @return [String]
        def description
          described_items = surface_descriptions_in(expected)
          improve_hash_formatting "have attributes #{described_items.inspect}"
        end

        # @api private
        # @return [String]
        def failure_message
          respond_to_failure_message_or do
            "expected #{actual.inspect} to #{description} but had attributes #{ formatted_values }"
          end
        end

        # @api private
        # @return [String]
        def failure_message_when_negated
          respond_to_failure_message_or { super }
        end

      private

        def cache_all_values
          @values = {}
          expected.each do |attribute_key, _attribute_value|
            actual_value = @actual.__send__(attribute_key)
            @values[attribute_key] = actual_value
          end
        end

        def perform_match(predicate)
          cache_all_values
          expected.__send__(predicate) do |attribute_key, attribute_value|
            actual_has_attribute?(attribute_key, attribute_value)
          end
        end

        def actual_has_attribute?(attribute_key, attribute_value)
          values_match?(attribute_value, @values.fetch(attribute_key))
        end

        def respond_to_attributes?
          matches = respond_to_matcher.matches?(actual)
          @respond_to_failed = !matches
          matches
        end

        def respond_to_matcher
          @respond_to_matcher ||= RespondTo.new(*expected.keys).with(0).arguments
        end

        def respond_to_failure_message_or
          if respond_to_failed
            respond_to_matcher.failure_message
          else
            improve_hash_formatting(yield)
          end
        end

        def formatted_values
          improve_hash_formatting(@values.inspect)
        end
      end
    end
  end
end
