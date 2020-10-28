defmodule Timex.Ecto.Test do
  use JehovakelExEcto.RepoCase, async: true
  import Ecto.Query
  use Timex

  alias JehovakelExEcto.BlogPost, as: Post

  test "integrates successfully with Ecto" do
    datetime = Timex.now()
    datetimetz = Timezone.convert(datetime, "Europe/Berlin")

    %Post{
      title: "My first post",
      text: "I am testing, whether it works",
      written_at: datetimetz,
      comments: [
        %Post.Comment{
          text: "My first comment",
          written_at: datetimetz
        }
      ]
    }
    |> Repo.insert!()

    [
      %Post{
        title: "My first post",
        text: "I am testing, whether it works",
        written_at: deserialized_datetimetz,
        comments: [
          %Post.Comment{
            text: "My first comment",
            written_at: deserialized_embedded_datetimetz
          }
        ]
      }
    ] = Repo.all(Post)

    assert Timex.compare(datetimetz, deserialized_datetimetz, :seconds) == 0

    assert Timex.compare(datetimetz, deserialized_embedded_datetimetz, :seconds) == 0

    query =
      from(post in Post,
        where:
          post.written_at ==
            type(
              ^Timezone.convert(datetime, "Europe/Berlin"),
              Timex.Ecto.DateTimeWithTimezone
            )
      )

    [%Post{written_at: deserialized_datetimetz}] = Repo.all(query)
    assert Timex.compare(datetimetz, deserialized_datetimetz, :seconds) == 0
  end

  test "load time with time zone daylight saving switch" do
    {:ok, datetime, _} = "2019-10-27 02:15:00+00" |> DateTime.from_iso8601()
    in_db = {datetime, "Europe/Berlin"}

    assert {:ok, %DateTime{std_offset: winter_time_offset} = datetime} =
             Timex.Ecto.DateTimeWithTimezone.load(in_db)

    assert winter_time_offset == 0
  end
end
