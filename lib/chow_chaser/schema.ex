defmodule ChowChaser.Schema do
  @moduledoc """
  Base abstraction for schema modules.
  """

  @callback changeset(struct(), map()) :: Ecto.Changeset.t()

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset

      @behaviour ChowChaser.Schema

      def prepare_bulk_upsert(params) do
        Enum.reduce_while(params, {:ok, []}, fn param, {:ok, acc} ->
          case upsert_params(param) do
            {:ok, struct} -> {:cont, {:ok, [struct | acc]}}
            {:error, changeset} -> {:halt, {:error, changeset}}
          end
        end)
      end

      defp upsert_params(params) do
        case params |> create_changeset() |> apply_action(:create) do
          {:ok, struct} ->
            {:ok, Map.take(struct, data_fields()) |> Map.merge(timestamp_placeholders())}

          {:error, changeset} ->
            {:error, changeset}
        end
      end

      defp create_changeset(params), do: changeset(struct(__MODULE__), params)

      defp timestamp_placeholders do
        %{inserted_at: {:placeholder, :now}, updated_at: {:placeholder, :now}}
      end

      defp data_fields do
        __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:primary_key)
      end
    end
  end
end
