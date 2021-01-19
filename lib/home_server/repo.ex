defmodule HomeServer.Repo do
  use Ecto.Repo,
    otp_app: :home_server,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Reverse a preload.
  ## Example
      site = Repo.get!(Site, 1) |> Repo.preload(:user)
      Repo.forget(site, :user)
  ## References
  + https://stackoverflow.com/a/52323877
  + https://stackoverflow.com/a/49997873
  + https://github.com/thoughtbot/ex_machina/issues/295#issuecomment-433264227
  """
  def forget_all(struct) do
    associations = resolve_associations(struct)
    forget(struct, associations)
  end

  def forget(struct, associations) when is_list(associations) do
    associations
    |> Enum.reduce(struct, fn association, struct ->
      forget(struct, association)
    end)
  end

  def forget(struct, association) do
    %{
      struct
      | association => build_not_loaded(struct, association)
    }
  end

  defp resolve_associations(%{__struct__: schema}) do
    schema.__schema__(:associations)
  end

  defp build_not_loaded(%{__struct__: schema}, association) do
    %{
      cardinality: cardinality,
      field: field,
      owner: owner
    } = schema.__schema__(:association, association)

    %Ecto.Association.NotLoaded{
      __cardinality__: cardinality,
      __field__: field,
      __owner__: owner
    }
  end
end
