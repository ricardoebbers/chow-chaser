defmodule Socrata.Record do
  @moduledoc """
  Abstracts the records on the Mobile Food Facility Permit dataset.

  Filters only the relevant fields used in the application.
  """

  defstruct [
    :address,
    :applicant,
    :food_items,
    :latitude,
    :location_description,
    :longitude,
    :object_id,
    :status
  ]

  @type t :: %__MODULE__{
          address: String.t(),
          applicant: String.t(),
          food_items: String.t(),
          latitude: String.t(),
          location_description: String.t(),
          longitude: String.t(),
          object_id: String.t(),
          status: String.t()
        }

  @doc """
  Creates a new record from a row.

  Expects the row to be a list of tuples with the field name and the value, where the field name
  is one of the ones returned by calling `fields/0`.
  """
  @spec new(row :: list({String.t(), String.t()})) :: t()
  def new(row) do
    fields =
      row
      |> Enum.map(fn {field, value} ->
        key =
          field
          |> Macro.underscore()
          |> String.to_existing_atom()

        {key, value}
      end)

    struct(__MODULE__, fields)
  end

  @doc """
  Converts a record to a map to be used as the `params` of `Ecto.Changeset.cast/4`.
  """
  @spec to_params(t()) :: map()
  def to_params(%__MODULE__{} = record) do
    %{
      address: record.address,
      applicant: record.applicant,
      items: record.food_items,
      latitude: record.latitude,
      location_description: record.location_description,
      longitude: record.longitude,
      object_id: record.object_id,
      status: record.status
    }
  end

  @doc """
  Returns the fields of a record as camelized strings.
  """
  @spec fields :: list(String.t())
  def fields do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.map(&Macro.camelize(Atom.to_string(&1)))
  end
end
