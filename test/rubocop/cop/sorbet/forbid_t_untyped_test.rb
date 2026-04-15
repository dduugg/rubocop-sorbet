# frozen_string_literal: true

require "test_helper"

module RuboCop
  module Cop
    module Sorbet
      class ForbidTUntypedTest < ::Minitest::Test
        MSG = "Sorbet/ForbidTUntyped: Do not use `T.untyped`."

        def setup
          @cop = ForbidTUntyped.new
        end

        def test_adds_offense_for_simple_usage
          assert_offense(<<~RUBY)
            T.untyped
            ^^^^^^^^^ #{MSG}
          RUBY
        end

        def test_adds_offense_when_used_within_type_alias
          assert_offense(<<~RUBY)
            FOO = T.type_alias { T.untyped }
                                 ^^^^^^^^^ #{MSG}
          RUBY
        end

        def test_adds_offense_when_used_within_type_signature
          assert_offense(<<~RUBY)
            sig { params(x: T.untyped).returns(T.untyped) }
                                               ^^^^^^^^^ #{MSG}
                            ^^^^^^^^^ #{MSG}
            def foo(x)
            end
          RUBY
        end

        def test_adds_offense_when_used_within_t_bind
          assert_offense(<<~RUBY)
            def foo(x)
              T.bind(self, T::Array[T.untyped])
                                    ^^^^^^^^^ #{MSG}
            end
          RUBY
        end
      end

      class ForbidTUntypedAllowUntypedHashValuesTest < ::Minitest::Test
        MSG = "Do not use `T.untyped`."

        def target_cop
          ForbidTUntyped
        end

        def setup
          @cop = target_cop.new(cop_config({ "AllowUntypedHashValues" => true }))
        end

        def test_no_offense_for_t_untyped_as_hash_value_type
          assert_no_offenses(<<~RUBY)
            sig { returns(T::Hash[Symbol, T.untyped]) }
            def metadata; end
          RUBY
        end

        def test_adds_offense_for_t_untyped_as_hash_key_type
          assert_offense(<<~RUBY)
            sig { returns(T::Hash[T.untyped, String]) }
                                  ^^^^^^^^^ #{MSG}
            def metadata; end
          RUBY
        end

        def test_adds_offense_for_direct_t_untyped
          assert_offense(<<~RUBY)
            sig { params(x: T.untyped).void }
                            ^^^^^^^^^ #{MSG}
            def foo(x); end
          RUBY
        end

        def test_adds_offense_for_t_untyped_in_t_array
          assert_offense(<<~RUBY)
            sig { returns(T::Array[T.untyped]) }
                                   ^^^^^^^^^ #{MSG}
            def items; end
          RUBY
        end

        def test_adds_offense_for_t_untyped_in_both_key_and_value_positions
          assert_offense(<<~RUBY)
            sig { returns(T::Hash[T.untyped, T.untyped]) }
                                  ^^^^^^^^^ #{MSG}
            def metadata; end
          RUBY
        end

        def test_no_offense_for_nested_hash_with_untyped_value
          assert_no_offenses(<<~RUBY)
            sig { returns(T::Hash[Symbol, T::Hash[String, T.untyped]]) }
            def metadata; end
          RUBY
        end

        def test_no_offense_for_nilable_hash_with_untyped_value
          assert_no_offenses(<<~RUBY)
            sig { returns(T.nilable(T::Hash[Symbol, T.untyped])) }
            def metadata; end
          RUBY
        end

        def test_no_offense_for_union_type_hash_with_untyped_value
          assert_no_offenses(<<~RUBY)
            sig { returns(T.any(T::Hash[Symbol, T.untyped], NilClass)) }
            def metadata; end
          RUBY
        end
      end

      class ForbidTUntypedDefaultConfigTest < ::Minitest::Test
        MSG = "Sorbet/ForbidTUntyped: Do not use `T.untyped`."

        def setup
          @cop = ForbidTUntyped.new
        end

        def test_adds_offense_for_t_untyped_as_hash_value_type_by_default
          assert_offense(<<~RUBY)
            sig { returns(T::Hash[Symbol, T.untyped]) }
                                          ^^^^^^^^^ #{MSG}
            def metadata; end
          RUBY
        end
      end
    end
  end
end
