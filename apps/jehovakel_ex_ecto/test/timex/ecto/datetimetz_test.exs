if Code.ensure_loaded?(Postgrex) do
  defmodule EctoTest.User do
    use Ecto.Schema

    defmodule Embedded do
      use Ecto.Schema

      embedded_schema do
        field(:datetimetz_test, Timex.Ecto.DateTimeWithTimezone)
      end
    end

    schema "users" do
      field(:name, :string)
      field(:datetimetz_test, Timex.Ecto.DateTimeWithTimezone)
      embeds_many(:embedded_test, EctoTest.User.Embedded)

      timestamps()
    end
  end

  defmodule EctoTest.App do
    use Application

    def start(_type, _args) do
      import Supervisor.Spec

      children = [
        worker(EctoTest.Repo, [])
      ]

      Supervisor.start_link(children, name: __MODULE__, strategy: :one_for_one)
    end
  end

  defmodule EctoTest.Migrations.Setup do
    use Ecto.Migration

    def change do
      create table(:users, primary_key: true) do
        add(:name, :string)
        add(:datetimetz_test, :datetimetz)
        add(:embedded_test, :map, default: [])

        timestamps()
      end
    end
  end

  defmodule Timex.Ecto.Test do
    use ExUnit.Case, async: true
    use Timex

    alias EctoTest.{User, Repo}

    import Ecto.Query

    setup_all do
      Application.ensure_all_started(:postgrex)
      Application.ensure_all_started(:ecto)
      EctoTest.App.start(:normal, [])

      Ecto.Migrator.run(
        Repo,
        [{0, Timex.Ecto.DateTimeWithTimezone.Migration}, {1, EctoTest.Migrations.Setup}],
        :up,
        all: true
      )

      Ecto.Adapters.SQL.Sandbox.mode(EctoTest.Repo, :manual)
    end

    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoTest.Repo)
    end

    test "integrates successfully with Ecto" do
      datetime = Timex.now()
      datetimetz = Timezone.convert(datetime, "Europe/Berlin")

      u = %User{
        name: "Paul",
        datetimetz_test: datetimetz,
        embedded_test: [
          %User.Embedded{
            datetimetz_test: datetimetz
          }
        ]
      }

      Repo.insert!(u)

      query =
        from(u in User,
          select: u
        )

      [
        %User{
          datetimetz_test: deserialized_datetimetz,
          embedded_test: [
            %User.Embedded{
              datetimetz_test: deserialized_embedded_datetimetz
            }
          ]
        }
      ] = Repo.all(query)

      assert Timex.compare(datetimetz, deserialized_datetimetz, :seconds) == 0
      assert Timex.compare(datetimetz, deserialized_embedded_datetimetz, :seconds) == 0

      query =
        from(u in User,
          where:
            u.datetimetz_test ==
              type(
                ^Timezone.convert(datetime, "Europe/Berlin"),
                Timex.Ecto.DateTimeWithTimezone
              ),
          select: u
        )

      [%User{datetimetz_test: deserialized_datetimetz}] = Repo.all(query)
      assert Timex.compare(datetimetz, deserialized_datetimetz, :seconds) == 0
    end
  end
end
