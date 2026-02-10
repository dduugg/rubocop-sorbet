# frozen_string_literal: true

require "rubocop"

module RuboCop
  module Cop
    module Sorbet
      # Checks for redundant `T.let` declarations where the first argument
      # is a simple literal (not a collection like Array or Hash) and the
      # second argument is the matching class name. Sorbet can infer the types
      # of simple literals automatically, so wrapping them in `T.let` is
      # redundant.
      #
      # @example
      #   # bad
      #   MAX_RETRIES = T.let(3, Integer)
      #   GREETING = T.let("hello", String)
      #   RATE = T.let(1.5, Float)
      #   PATTERN = T.let(/foo/, Regexp)
      #   STATUS = T.let(:active, Symbol)
      #
      #   # good
      #   MAX_RETRIES = 3
      #   GREETING = "hello"
      #   RATE = 1.5
      #   PATTERN = /foo/
      #   STATUS = :active
      #
      #   # good — collections still need T.let
      #   NAMES = T.let(["alice", "bob"], T::Array[String])
      #   OPTIONS = T.let({ verbose: true }, T::Hash[Symbol, T::Boolean])
      #
      #   # good — type is not the literal's own class
      #   value = T.let("hello", T.nilable(String))
      #
      #   # good — instance variables need T.let for Sorbet to track their type
      #   @max_retries = T.let(3, Integer)
      #
      #   # good — local variables may need T.let so Sorbet allows reassignment
      #   count = T.let(0, Integer)
      class RedundantTLetForLiteral < Base
        extend AutoCorrector

        MSG = "Redundant `T.let` for %{type} literal. Sorbet can infer this type automatically."

        # @!method t_let_with_literal_and_class?(node)
        def_node_matcher :t_let_with_literal_and_class?, <<~PATTERN
          (casgn _ _ (send (const nil? :T) :let $literal? (const nil? $_)))
        PATTERN

        # Maps AST literal node types to the class name Sorbet would infer.
        LITERAL_TYPE_TO_CLASS = {
          dstr: :String,
          float: :Float,
          int: :Integer,
          regexp: :Regexp,
          str: :String,
          sym: :Symbol,
        }.freeze

        def on_casgn(node)
          t_let_with_literal_and_class?(node) do |literal_node, class_name|
            next unless LITERAL_TYPE_TO_CLASS[literal_node.type] == class_name

            t_let_node = node.children[2]
            add_offense(t_let_node, message: format(MSG, type: class_name)) do |corrector|
              corrector.replace(t_let_node, literal_node.source)
            end
          end
        end
      end
    end
  end
end
