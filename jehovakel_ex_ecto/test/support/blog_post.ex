defmodule JehovakelExEcto.BlogPost do
  use Ecto.Schema

  schema "blog_posts" do
    field(:title, :string)
    field(:text, :string)
    field(:written_at, Timex.Ecto.DateTimeWithTimezone)

    embeds_many :comments, Comment do
      field(:text, :string)
      field(:written_at, Timex.Ecto.DateTimeWithTimezone)
    end

    field(:lock_version, :integer, default: 1)

    timestamps()
  end
end
