defmodule ChowChaser.Factory.ItemFactory do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      alias ChowChaser.Models.Item

      def item_factory do
        %Item{
          name: sequence(:item_name, &"Food Item #{&1}")
        }
      end
    end
  end
end
