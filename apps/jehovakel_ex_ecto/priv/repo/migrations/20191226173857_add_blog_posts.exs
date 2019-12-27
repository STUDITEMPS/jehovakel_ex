defmodule JehovakelExEcto.Repo.Migrations.AddBlogPosts do
  use Ecto.Migration

  def change do
    create table("blog_posts", primary_key: true) do
      add(:title, :string)
      add(:text, :text)
      add(:written_at, :datetimetz)
      add(:comments, {:array, :map}, default: [])

      add(:lock_version, :integer, default: 1)

      timestamps()
    end
  end
end
