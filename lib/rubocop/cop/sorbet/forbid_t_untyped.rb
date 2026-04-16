# frozen_string_literal: true

require "rubocop"

module RuboCop
  module Cop
    module Sorbet
      # Disallows using `T.untyped` anywhere.
      #
      # @example
      #
      #   # bad
      #   sig { params(my_argument: T.untyped).void }
      #   def foo(my_argument); end
      #
      #   # good
      #   sig { params(my_argument: String).void }
      #   def foo(my_argument); end
      #
      # @example AllowUntypedHashValues: false (default)
      #
      #   # bad
      #   sig { returns(T::Hash[Symbol, T.untyped]) }
      #   def metadata; end
      #
      # @example AllowUntypedHashValues: true
      #
      #   # good (T.untyped in value position of T::Hash)
      #   sig { returns(T::Hash[Symbol, T.untyped]) }
      #   def metadata; end
      #
      #   # bad (T.untyped in key position of T::Hash — still flagged)
      #   sig { returns(T::Hash[T.untyped, String]) }
      #   def metadata; end
      #
      class ForbidTUntyped < RuboCop::Cop::Base
        MSG = "Do not use `T.untyped`."
        RESTRICT_ON_SEND = [:untyped].freeze

        # @!method t_untyped?(node)
        def_node_matcher(:t_untyped?, "(send (const nil? :T) :untyped)")

        # @!method t_hash_receiver?(node)
        def_node_matcher(:t_hash_receiver?, "(const (const {nil? cbase} :T) :Hash)")

        def on_send(node)
          return unless t_untyped?(node)
          return if allow_untyped_hash_values? && hash_value_position?(node)

          add_offense(node)
        end

        private

        def allow_untyped_hash_values?
          cop_config.fetch("AllowUntypedHashValues", false)
        end

        def hash_value_position?(node)
          parent = node.parent
          parent&.send_type? &&
            parent.method?(:[]) &&
            t_hash_receiver?(parent.receiver) &&
            parent.arguments[1].equal?(node)
        end
      end
    end
  end
end
