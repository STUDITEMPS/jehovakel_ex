defmodule JehovakelExEcto.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias JehovakelExEcto.Repo

      import Ecto
      import Ecto.Query
      import JehovakelExEcto.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(JehovakelExEcto.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(JehovakelExEcto.Repo, {:shared, self()})
    end

    :ok
  end
end
